#!/bin/bash

. *env*

if [ -f ./$sample_chr_list ]; then
	mv $sample_chr_list $sample_chr_list.old
fi

for file in `ls *.bam`
do
	echo ${file%.ILLUMINA*} >> $sample_chr_list
#	echo ${file%.bam} >> $sample_chr_list
done

