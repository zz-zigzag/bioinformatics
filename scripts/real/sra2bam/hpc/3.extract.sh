#!/bin/bash

if [ $# -lt 1 ];
then
	echo "Usage: extract.sh <chromosome name>"
else
	
	#extract
	for name in `ls *.bam | awk -F . '{printf $1"\n"}' `
	do
		bsub -q qtest -n 8 -o %J.out "samtools view -b -h -@8 ${name}.bam $1 > ${name}_${1}.bam && samtools index ${name}_${1}.bam"
#		samtools view -b -@8 -h ${name}.bam $1> ${name}_${1}.bam && samtools index ${name}_${1}.bam
	done

fi
