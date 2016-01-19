#!/bin/sh

. env.sh

for i in $(seq 1 $number)
do
	echo "${i}_${chr}.bam $mflen ${i}" > ${i}_${chr}.bam.pindel.cfg
	pindel -f $ref/ncbi36/${chr}.fa -i ${i}_${chr}.bam.pindel.cfg -o out.pindel.${i}_${chr} -T $thread -c $chr -M 2 -E 0.99
done

