#!/bin/bash

thread=`grep 'processor' /proc/cpuinfo | sort -u | wc -l`

for filename in `ls *.sra | awk -F . '{printf $1"\n"}' `
do
	bwa mem -t $thread $ncbi36 ${filename}_1.fastq ${filename}_2.fastq | samtools view -@ $thread -b - | samtools sort -@ $thread - ${filename} && samtools index $filename.bam
done
