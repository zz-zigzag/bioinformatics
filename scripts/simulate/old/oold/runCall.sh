#!/bin/bash

echo "Input sample number range [l r]:"
read a b

. env.sh

for i in $(seq $a $b)
do
{
	##########################################################################
	#call variation
	##########################################################################
	
	#pindel default
	echo "${i}_${chr}.bam $mflen ${i}" > temp${i}.txt
	echo "pindel -f /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -i temp${i}.txt -o ./result/pindel/default/${i}_${chr} -T $thread -c $chr"
	pindel -f /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -i temp${i}.txt -o ./result/pindel/default/${i}_${chr} -T $thread -c $chr
	
	#pindel _E_0.99_M_2
	echo "${i}_${chr}.bam $mflen ${i}" > temp${i}.txt
	echo "pindel -f /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -i temp${i}.txt -o ./result/pindel/_E0.99_M2/${i}_${chr} -T $thread -E 0.99 -M 2 -c $chr"
	pindel -f /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -i temp${i}.txt -o ./result/pindel/_E0.99_M2/${i}_${chr} -T $thread -E 0.99 -M 2 -c $chr
	rm temp${i}.txt
	#svseq deletion
	echo "svseq -r /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -b ${i}_${chr}.bam -c $chr --o ./result/svseq/deletion/${i}_${chr}"
	svseq -r /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -b ${i}_${chr}.bam -c $chr --o ./result/svseq/deletion/${i}_${chr}
	
	#svseq deletion_cutoff2
	echo "svseq -r /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -b ${i}_${chr}.bam -c $chr --o ./result/svseq/deletion_cutoff2/${i}_${chr} --c 2"
	svseq -r /home/zz_zigzag/NGS_Data/Reference/ncbi36/${chr}.fa -b ${i}_${chr}.bam -c $chr --o ./result/svseq/deletion_cutoff2/${i}_${chr} --c 2
}
done

