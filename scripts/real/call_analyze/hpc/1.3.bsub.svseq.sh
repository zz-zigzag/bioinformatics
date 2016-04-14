#!/bin/bash

. *env*

for chr in `seq 1 12`
do
	#i=`expr $chr / 2`
	#i=`expr 16 + $i`
	chr=chr$chr
	echo bsub -q $queue -o %J.svseq.${sample}_${chr}${downsample}.out "svseq -r $hg19 -b ${sample}_${chr}${downsample}.bam -c $chr --o out.svseq.${sample}_$chr " 
	bsub -q $queue -o %J.svseq.${sample}_${chr}${downsample}.out "svseq -r $hg19 -b ${sample}_${chr}${downsample}.bam -c $chr --o out.svseq.${sample}_$chr " 
done
