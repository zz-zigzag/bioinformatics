#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Usage: train_predict <model> [tempFILEID]"
	exit
fi
model=$1
FILEID=""

if [ x$2 != x ]
then
	FILEID=_$2
fi

. *env*

res_val=res.validated$FILEID.txt
if [ -f ./$res_val ]; then
	mv $res_val $res_val.old
fi



for sample_chr in $(cat $test_sample_chr_list)
do
	benchmark=${sample_chr}.$benchmark_suffix
	validated=out.validated.$sample_chr$FILEID
	val_format=$validated.format
	
	candidate=out.merged_candidate.$sample_chr
	can_format=$candidate.format
	feature=$sample_chr.feature
	if [ x$callset_suffix == x ]
	then
		svm-predict $feature.scale $model $validated
		paste $can_format $validated | awk '{if($5==1) print $1"\t"$2"\t"$3}' > $val_format
	else
		eval "awk '{if(\$3-\$2>=$minL && \$3-\$2<$maxL) print \$0}' $val_format > $val_format$callset_suffix" 
	fi
	verify-deletion $diff $val_format$callset_suffix $benchmark $candidate$FILEID.cmp >> $res_val
done


if [ x$2 != x ]
then
	#echo -n "${FILEID#_}" >> $stats_file
	awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{p=c/a; s=d/b; printf("%.4f\t%.4f\t%.4f\n", c/a, d/b, 2*p*s/(p+s))}'  $res_val >> $stats_file	
else
	echo -n "validated" >> $stats_file
	awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{p=c/a; s=d/b; printf("\t%d\t%d\t%d | %d\t%.4f\t%.4f\t%.4f\n",a,b,c,d, p, s, 2*p*s/(p+s))}'  $res_val >> $stats_file	
fi


