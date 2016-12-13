#!/bin/bash

echo "Input sample number range [l r]:"
read a b

. env.sh

for i in $(seq $a $b)
do
{
	#svseq deletion
	echo "svseq -r /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -b ${i}_${chr}.bam -c $chr --o ./result/svseq/deletion/${i}_${chr}"
	svseq -r /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -b ${i}_${chr}.bam -c $chr --o ./result/svseq/deletion/${i}_${chr}
}
done

