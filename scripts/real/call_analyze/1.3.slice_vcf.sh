#!/bin/bash

. *env*
for sample_chr in $(cat $test_sample_chr_list)
do
    benchmark=${sample_chr}.$benchmark_suffix
    chr=${benchmark#*chrom}
    chr=${chr%.vcf}

    cat chrom${chr}_1 $benchmark | awk '{print $1,$2,$3}' | sort -k2 -n  | uniq -d > $benchmark.1
    cat chrom${chr}_2 $benchmark | awk '{print $1,$2,$3}' | sort -k2 -n  | uniq -d > $benchmark.2
    cat chrom${chr}_3 $benchmark | awk '{print $1,$2,$3}' | sort -k2 -n  | uniq -d > $benchmark.3
    cat chrom${chr}_4 $benchmark | awk '{print $1,$2,$3}' | sort -k2 -n  | uniq -d > $benchmark.4
    cat chrom${chr}_5 $benchmark | awk '{print $1,$2,$3}' | sort -k2 -n  | uniq -d > $benchmark.5

done
