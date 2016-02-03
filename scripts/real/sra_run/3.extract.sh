#!/bin/bash

if [ $# -lt 1 ];
then
	echo "Usage: extract.sh <chromosome name>"
else
	
	#extract
	for name in `ls *.bam | awk -F . '{printf $1"\n"}' `
	do
		echo "samtools view -b ${name}.bam $1 > ${name}_${1}.bam"
		samtools view -b -h -@8 ${name}.bam $1 > ${name}_${1}.bam
	done

	#merge
	echo "samtools merge ${1}.bam *_${1}.bam"
	samtools merge ${1}.bam *_${1}.bam
	rm *_${1}.bam
	
	#MarkDuplicates
	echo "java -jar $picard MarkDuplicates INPUT=${1}.bam OUTPUT=${i}_nodup.bam METRICS_FILE=${i}_metrics.txt REMOVE_DUPLICATES=true CREATE_INDEX=true"
	java -jar $picard MarkDuplicates INPUT=${1}.bam OUTPUT=${1}_nodup.bam METRICS_FILE=${1}_metrics.txt REMOVE_DUPLICATES=true CREATE_INDEX=true
	
	rm ${1}.bam
	mv ${1}_nodup.bam ${1}.bam
	mv ${1}_nodup.bai ${1}.bam.bai
	
fi
