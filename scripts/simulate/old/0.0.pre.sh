#!/bin/bash

. env.sh

vcf_del -c ${chr} -i 50 -f union.2010_06.deletions.sites.vcf format.site.vcf 
DonorSim -D -v format.site.vcf -n ${number} -c ${chr} -r $ref/ncbi36/${chr}.fa -p 0.5
