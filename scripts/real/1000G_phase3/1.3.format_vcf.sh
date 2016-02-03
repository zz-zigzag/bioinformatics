#!/bin/sh

for sample in `cat list.sample`
do
		vcf_del -gf -c 20 -n $sample integrated.vcf ${sample}.chrom20.vcf
		vcf_del -gf -c 11 -n $sample integrated.vcf ${sample}.chrom11.vcf
done
