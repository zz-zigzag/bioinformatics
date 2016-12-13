#!/bin/bash

. *env*

# other case
for sample in `cat $sample_list`
do
	vcf_del -g -c 20 -n $sample $vcf_file ${sample}.chrom20.cur.vcf
	vcf_del -g -c 11 -n $sample $vcf_file ${sample}.chrom11.cur.vcf
done


