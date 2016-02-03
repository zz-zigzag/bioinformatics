#!/bin/sh

for i in `seq 1 22`
do
		vcf_del -gf -c $i -n NA12878 integrated.vcf NA12878_chr$i.vcf
done
