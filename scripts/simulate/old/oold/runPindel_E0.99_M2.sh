#!/bin/bash

echo "Input sample number range [l r]:"
read a b

. env.sh

for i in $(seq $a $b)
do
{
	#pindel _E0.99_M2
	echo "${i}_${chr}.bam $mflen ${i}" > tempPindel_E.txt
	echo "pindel -f /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -i tempPindel_E.txt -o ./result/pindel/_E0.99_M2/${i}_${chr} -T $thread -E 0.99 -M 2 -c $chr"
	pindel -f /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -i tempPindel_E.txt -o ./result/pindel/_E0.99_M2/${i}_${chr} -T $thread -E 0.99 -M 2 -c $chr
	
}
done
rm tempPindel_E.txt
