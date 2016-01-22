#!/bin/bash

. env.sh

for i in $(seq 1 $number)
do
	bwa aln -q 15 -t $thread $ref/ncbi36/$chr.fa ${i}_${chr}_1.fq > ${i}_${chr}_1.sai
	bwa aln -q 15 -t $thread $ref/ncbi36/$chr.fa ${i}_${chr}_2.fq > ${i}_${chr}_2.sai
	bwa sampe -a 1500 $ref/ncbi36/$chr.fa ${i}_${chr}_1.sai ${i}_${chr}_2.sai ${i}_${chr}_1.fq ${i}_${chr}_2.fq | samtools view -@ $thread -b - | samtools sort -@ $thread - ${i}_${chr} && samtools index ${i}_${chr}.bam
done
