#!/bin/bash

. 0.0.env.sh

for caller in ${callers[@]}
do
	res=res.${caller}.txt
	if [ -f ./$res ]; then
		mv $res $res.old
	fi
done


function verify() {
	filename=out.${1}.${prefix}
	verify-deletion $diff ${filename}.format $benchmark ${filename}.cmp >> res.${1}.txt
}

for bam in $(ls *.bam)
do
	prefix=${bam%.ILL*}
	benchmark=${prefix}.vcf
	> out.integrate.${prefix}
	
	for caller in ${callers[@]}
	do
		verify $caller
	done
done

for caller in ${callers[@]}
do
	grep chrom11 res.${caller}.txt > res.${caller}.chrom11.txt
	grep chrom20 res.${caller}.txt > res.${caller}.chrom20.txt
done

