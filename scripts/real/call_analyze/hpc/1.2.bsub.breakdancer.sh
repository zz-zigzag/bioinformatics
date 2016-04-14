#!/bin/bash
. 0.0.env.sh

for chr in `seq 1 22 `
do
	chr=chr$chr
    bsub -q $queue -o %J.breakdancer.${sample}_${chr}${downsample}.out "bam2cfg.pl -q 20 -g -h ${sample}_${chr}${downsample}.bam > ${sample}_${chr}${downsample}.breakdancer.cfg  && breakdancer-max ${sample}_${chr}${downsample}.breakdancer.cfg > out.breakdancer.${sample}_${chr}${downsample} "
done

