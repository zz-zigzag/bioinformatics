#!/bin/sh

. env.sh

for i in $(seq 1 $number)
do
	svseq -r $ref/ncbi36/${chr}.fa -b ${i}_${chr}.bam -c $chr --o out.svseq.${i}_${chr}
done

