#!/bin/bash

echo "Input sample number range [l r]:"
read a b

. env.sh

if [ -f ./bam.list ]; then
	mv bam.list bam_old.list
fi

for i in $(seq $a $b)
do
{
	#simluate reads
	echo "art_illumina -i ${i}_${chr}.fa -l $readlen -f $fold  -o ${i}_${chr}_ -m $mflen -s $sdev -p -na"
	art_illumina -i ${i}_${chr}.fa -l $readlen -f $fold  -o ${i}_${chr}_ -m $mflen -s $sdev -p -na -qs 10 -qs2 10 
	
	echo "${i}_${chr}.bam $readlen $mflen $sdev ${i}_${chr}_S" >> bam.list
}
done
