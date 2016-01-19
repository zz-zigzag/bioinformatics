#!/bin/sh

. env.sh

echo " vcf_del -c ${chr} -i 50 -f $vcf format.site.vcf"
vcf_del -c ${chr} -i 50 -f $vcf  format.site.vcf 

echo "DonorSim -D -v format.site.vcf -n ${number} -c ${chr} -r $ref/ncbi36/${chr}.fa -p 0.5"
DonorSim -D -v format.site.vcf -n ${number} -c ${chr} -r $ref/ncbi36/${chr}.fa -p 0.5
