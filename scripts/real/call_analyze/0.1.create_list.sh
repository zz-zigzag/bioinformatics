#!/bin/bash

. *env*

if [ -f $sample_chr_list ]; then
	mv $sample_chr_list $sample_chr_list.old
fi

if [ -f $sample_list ]; then
	mv $sample_list $sample_list.old
fi

for file in `ls *.bam`
do
	echo ${file%.ILLUMINA*} >> $sample_chr_list
#	echo ${file%.bam} >> $sample_chr_list
done

cat $sample_chr_list | cut -d . -f 1 | sort -u > $sample_list

