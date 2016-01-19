#!/bin/bash

. env.sh

if [ -f ./bam.list ]; then
	mv bam.list bam_old.list
fi

for i in $(seq 1 $number)
do
	art_illumina -i ${i}_${chr}.fa -l $readlen -f $fold  -o ${i}_${chr}_ -m $mflen -s $sdev -p -na	
	echo "${i}_${chr}.bam $readlen $mflen $sdev ${i}_${chr}_S" >> bam.list
done
