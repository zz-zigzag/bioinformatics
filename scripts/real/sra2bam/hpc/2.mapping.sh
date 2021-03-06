#!/bin/bash

#thread=`grep 'processor' /proc/cpuinfo | sort -u | wc -l`
thread=8

for filename in `ls *.sra | awk -F . '{printf $1"\n"}' `
do
	bsub -q qtest -n $thread -o %J.out "bwa mem -t $thread $ncbi36 ${filename}_1.fastq ${filename}_2.fastq | samtools view -@$thread -b - | samtools sort -@$thread - ${filename} && samtools index $filename.bam"
done
