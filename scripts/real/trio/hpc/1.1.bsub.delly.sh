#!/bin/bash

. 0.0.env.sh
for chr in `seq 1 22`
do
	chr=chr$chr
    bsub -q $queue -o %J.${sample}_${chr}.delly.out "delly -t DEL -o out.delly.${sample}_${chr} -g $hg19 ${sample}_${chr}.bam"
done
