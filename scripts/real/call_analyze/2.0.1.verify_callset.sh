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
	filename=out.${1}.${sample_chr}
	verify-deletion $diff ${filename}.format $benchmark ${filename}.cmp >> res.${1}.txt
}

for $sample_chr in $(cat $sample_chr_list)
do
	benchmark=${sample_chr}.$benchmark_suffix
	
	for caller in ${callers[@]}
	do
		verify $caller
	done
done

