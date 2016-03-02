#!/bin/bash

. *env*
#DeletionFeatures
#SimpleFeature
extract="DeletionFeatures -D $diff"

cov=""
if [ x$1 != x ]
then
	cov=_$1
fi

for i in `seq 1 22`
do
#<<o
	if [ x$i == x1 -o x$i == x2 -o x$i == x10 -o x$i == x16 ]
	then
		continue
	fi
#o
    chr=chr$i
    echo ${sample}_$chr$cov.bam 101 300 70 out.integrated.${sample}_$chr.cmp > list_$chr$cov
    echo bsub -q $queue -o %J.${sample}_$chr$cov.feature.out $extract -b list_$chr$cov
    bsub -q $queue -o %J.${sample}_$chr$cov.feature.out $extract -b list_$chr$cov
done
