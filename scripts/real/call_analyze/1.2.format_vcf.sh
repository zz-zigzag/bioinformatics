#!/bin/sh

. *env*

for i in `seq 1 22`
do
	vcf_del -g -c $i -n $sample $vcf_file ${sample}_chr$i.vcf
done


<<!
# other case
for sample in `cat $sample_list`
do
	vcf_del -g -c 20 -n $sample $vcf_file ${sample}.chrom20.vcf
	vcf_del -g -c 11 -n $sample $vcf_file ${sample}.chrom11.vcf
done
!


