#!/bin/bash

echo "Input sample number range [l r]:"
read a b

. env.sh

for i in $(seq $a $b)
do
{
	#simluate reads
	echo "art_illumina -i ${i}_${chr}.fa -l $readlen -f $fold  -o ${i}_${chr}_ -m $mflen -s $sdev -p -na -qs 10 -qs2 10"
	art_illumina -i ${i}_${chr}.fa -l $readlen -f $fold  -o ${i}_${chr}_ -m $mflen -s $sdev -p -na -qs 10 -qs2 10 


	#align reads
	echo "bwa mem -t $thread $ref/ncbi36/$chr.fa  ${i}_${chr}_1.fq ${i}_${chr}_2.fq > ${i}_${chr}.sam"
	bwa mem -t $thread $ref/ncbi36/$chr.fa  ${i}_${chr}_1.fq ${i}_${chr}_2.fq > ${i}_${chr}.sam
	
	#bwa aln -t 8 $ref/ncbi36/$chr.fa ${i}_${chr}_left.fq > ${i}_${chr}_left.sai
	#bwa aln -t 8 $ref/ncbi36/$chr.fa ${i}_${chr}_right.fq > ${i}_${chr}_right.sai
	#bwa sampe $ref/ncbi36/$chr.fa ${i}_${chr}_left.sai ${i}_${chr}_right.sai ${i}_${chr}_left.fq ${i}_${chr}_right.fq > ${i}_${chr}.sam 
	
	echo "samtools view -b ${i}_${chr}.sam > ${i}_${chr}.bam"
	samtools view -b ${i}_${chr}.sam > ${i}_${chr}.bam
	rm ${i}_${chr}.sam
	
	#remove singletons
	echo "samtools view -F 0x04 -b ${i}_${chr}.bam > ${i}_${chr}_filtered.bam"
	samtools view -F 0x04 -b ${i}_${chr}.bam > ${i}_${chr}_filtered.bam
	rm ${i}_${chr}.bam
	
	#sort sample
	echo "java -jar $picard SortSam I=${i}_${chr}_filtered.bam O=${i}_${chr}_sorted.bam SORT_ORDER=coordinate CREATE_INDEX=True"
	java -jar $picard SortSam I=${i}_${chr}_filtered.bam O=${i}_${chr}_sorted.bam SORT_ORDER=coordinate CREATE_INDEX=True
	rm ${i}_${chr}_filtered.bam
	
	#remove duplicates
	echo "java -jar $picard MarkDuplicates INPUT=${i}_${chr}_sorted.bam OUTPUT=${i}_${chr}_nodup.bam METRICS_FILE=${i}_${chr}.txt REMOVE_DUPLICATES=true CREATE_INDEX=true "
	java -jar $picard MarkDuplicates INPUT=${i}_${chr}_sorted.bam OUTPUT=${i}_${chr}_nodup.bam METRICS_FILE=${i}_${chr}.txt REMOVE_DUPLICATES=true CREATE_INDEX=true
	rm ${i}_${chr}_sorted.bam ${i}_${chr}_sorted.bai
	mv ${i}_${chr}_nodup.bam ${i}_${chr}.bam
	mv ${i}_${chr}_nodup.bai ${i}_${chr}.bam.bai
	
	echo "${i}_${chr}.bam $mflen $sdev" >> bamlist.txt
	
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

