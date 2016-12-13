#!/bin/bash


if [ $# -lt 1 ];
then
	echo "Usage: merge.sh <chromosome name>"
else

	#merge
	echo "samtools merge -@8 ${1}.bam *_${1}.bam"
	samtools merge -@8 ${1}.bam *_${1}.bam

	echo "samtools index ${1}.bam"
	samtools index ${1}.bam

fi



