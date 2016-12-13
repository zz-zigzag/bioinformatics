#!/bin/bash

echo "Input sample number range [l r]:"
read a b

. env.sh

for i in $(seq $a $b)
do
	bwa mem -t $thread $ref/ncbi36/$chr.fa ${i}_${chr}_1.fq ${i}_${chr}_2.fq | samtools view -@ $thread -b - | samtools sort -@ $thread - ${i}_${chr} && samtools index ${i}_${chr}.bam
done
