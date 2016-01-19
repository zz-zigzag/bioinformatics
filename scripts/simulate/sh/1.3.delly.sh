#!/bin/sh

. env.sh

for i in $(seq 1 $number)
do
    delly -t DEL -o out.delly.${i}_${chr}.vcf -g $ref/ncbi36/${chr}.fa ${i}_${chr}.bam
done
