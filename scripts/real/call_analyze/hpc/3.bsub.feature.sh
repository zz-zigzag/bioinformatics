#!/bin/bash

. *env*

extract="SVfeature -D $diff"


for i in `seq 1 22`
do
    chr=chr$i
    echo ${sample}_$chr$downsample.bam 101 300 70 out.integrated.${sample}_$chr$downsample.format > list_$chr$downsample
    echo bsub -q $queue -o %J.${sample}_$chr$downsample.feature.out $extract -b list_$chr$downsample
    bsub -q $queue -o %J.${sample}_$chr$downsample.feature.out $extract -b list_$chr$downsample
done
