#!/bin/bash

. *env*

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
	prefix=${bam%.bam}
	benchmark=${prefix}.vcf
	
	for caller in ${callers[@]}
	do
		verify $caller
	done
done

