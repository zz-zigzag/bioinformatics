#!/bin/bash

. *env*

for sample_chr in `cat $sample_chr_list`
do
	awk '{print $4}' out.merged_candidate.${sample_chr}.cmp | paste - ${sample_chr}.*normalized > ${sample_chr}.feature
done
