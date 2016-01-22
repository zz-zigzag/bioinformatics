#!/bin/bash

. 0.0.env.sh

function format() {
	filename=out.${1}.${prefix}
	case $1 in
		pindel) awk '{if($3>=50 && $3<1000000) print $8"\t"$10"\t"$11 }' $filename | sort -n -k 2 > ${filename}.format;;
		svseq) awk '{ if($6-$3>=51 && $6-$3<1000000) print $2"\t"$3"\t"$6 }' $filename | sort -n -k 2 > ${filename}.format;;
		breakdancer) grep -v '#' $filename | grep DEL  | awk '{ if($5-$2>=51 && $5-$2<1000000) print $1"\t"$2"\t"$5+1 }'  | sort -n -k 2 -o ${filename}.format;;
		delly) vcf_del $filename ${filename}.format > /dev/null && awk '{ if($3-$2>=51 && $3-$2<1000000) print $1"\t"$2"\t"$3 }' ${filename}.format | sort -n -k 2 -o ${filename}.format;;
		integrate) sort -n -k 2 $filename -o $filename.format;;
	esac
	
	if [ $1 != integrate ]; then
		cat ${filename}.format >> out.integrate.${prefix}
	#else
		#merge_deletions $filename.format $filename.format.merge && mv $filename.format.merge $filename.format
	fi
}


for bam in $(ls *.bam)
do
	prefix=${bam%.ILL*}
	> out.integrate.${prefix}
	
	for caller in ${callers[@]}
	do
		format $caller
	done
done
