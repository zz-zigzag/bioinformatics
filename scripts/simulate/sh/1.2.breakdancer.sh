#!/bin/sh

. env.sh

for i in $(seq 1 $number)
do
    bam2cfg.pl ${i}_${chr}.bam > ${i}_${chr}.bam.breakdancer.cfg  && breakdancer-max ${i}_${chr}.bam.breakdancer.cfg > out.breakdancer.${i}_${chr}
done

