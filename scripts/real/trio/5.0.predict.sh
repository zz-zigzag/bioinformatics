#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Usage: train_predict <sample_data> <tempFILEID>"
	return
fi
model=$1
FILEID=""
if [ x$2 != x ]
then
	FILEID=$2
fi

. *env*

if [ -f ./res.validated_$FILEID.txt ]; then
	mv res.validated_$FILEID.txt res.validated.txt_$FILEID.old
fi



for i in $(seq 1 22)
do
	if [ x$i != x6 -a x$i != x7 -a x$i != x8 -a x$i != x9 ]
	then
		continue
	fi
	chr=chr$i
	prefix=${sample}_$chr
	benchmark=${prefix}.$benchmark_vcf
	val=out.validated.$prefix
	int=out.integrated.$prefix
	filename=${prefix}.bam_normalized
	if [ ! -f ./$filename.scale ]
	then
		formatDataToLibsvm $filename $filename.data
		svm-scale -r train.range $filename.data > $filename.scale
	fi
	svm-predict $filename.scale $model ${val}_$FILEID
	paste $int.format ${val}_$FILEID | awk '{if($5==1) print $1"\t"$2"\t"$3}' > ${val}_$FILEID.format
	verify-deletion $diff ${val}_$FILEID.format $benchmark ${val}_$FILEID.cmp >> res.validated_$FILEID.txt
done
status=res._e${diffP}_m${diffM}.txt
#echo -n "$FILEID" >> $status
awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{printf("%.4f\t%.4f\n", c/a, d/b)}' res.validated_$FILEID.txt >> $status	


