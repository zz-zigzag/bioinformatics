#!/bin/bash

. 0.0.env.sh
for chr in `seq 1 22`
do
	chr=chr$chr
    bsub -q $queue -o %J.delly.${sample}_${chr}${downsample}.out "delly -t DEL -o out.delly.${sample}_${chr}${downsample} -g $hg19 ${sample}_${chr}${downsample}.bam"
done
