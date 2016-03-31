#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Usage: train_predict <model> <tempFILEID>"
	return
fi

model=$1
FILEID=""

if [ x$2 != x ]
then
	FILEID=_$2
fi

. *env*

if [ -f ./res.validated$FILEID.txt ]; then
	mv res.validated$FILEID.txt res.validated.txt$FILEID.old
fi



for sample_chr in $(cat $test_sample_chr_list)
do
	benchmark=${sample_chr}.$benchmark_suffix
	val=out.validated.$sample_chr
	int=out.integrated.$sample_chr
	filename=${sample_chr}.feature
	if [ ! -f ./$filename.scale ]
	then
		formatDataToLibsvm $filename $filename.data
		svm-scale -r train.range $filename.data > $filename.scale
	fi
	svm-predict $filename.scale $model ${val}$FILEID
	paste $int.format ${val}$FILEID | awk '{if($5==1) print $1"\t"$2"\t"$3}' > ${val}$FILEID.format
	verify-deletion $diff ${val}$FILEID.format $benchmark ${val}$FILEID.cmp >> res.validated$FILEID.txt
done


if [ x$2 != x ]
then
	#echo -n "${FILEID#_}" >> $stats_file
	awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{printf("\t%.4f\t%.4f\n", c/a, d/b)}'  res.validated$FILEID.txt >> $stats_file	
else
	echo -n "validated:" >> $stats_file
	awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{printf("\t%d\t%d\t%d|%d\t%.4f\t%.4f\n",a,b,c,d, c/a, d/b)}'  res.validated$FILEID.txt >> $stats_file	
fi


