#!/bin/bash

echo "Input sample number range [l r]:"
read a b

. env.sh

for i in $(seq $a $b)
do
{

	#pindel default
	echo "${i}_${chr}.bam $mflen ${i}" > tempPindel.txt
	echo "pindel -f /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -i tempPindel.txt -o ./result/pindel/default/${i}_${chr} -T $thread -c $chr"
	pindel -f /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -i tempPindel.txt -o ./result/pindel/default/${i}_${chr} -T $thread -c $chr
}
done

rm tempPindel.txt

