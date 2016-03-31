#!/bin/bash

. *env*

function format() {
	filename=out.${1}.${sample_chr}
	case $1 in
		pindel) awk '{if($3>=40 && $3<1000000) print $8"\t"$10"\t"$11"\tpindel" }' $filename | sort -n -k 2 > ${filename}.format;;
		svseq) awk '{ if($6-$3>=40 && $6-$3<1000000) print $2"\t"$3"\t"$6"\tsvseq" }' $filename | sort -n -k 2 > ${filename}.format;;
		breakdancer) grep -v '#' $filename | grep DEL  | awk '{ if($5-$2>=40 && $5-$2<1000000) print $1"\t"$2"\t"$5+1"\tbreakdancer" }'  | sort -n -k 2 -o ${filename}.format;;
		delly) vcf_del $filename ${filename}.format > /dev/null && awk '{ if($3-$2>=40 && $3-$2<1000000) print $1"\t"$2"\t"$3"\tdelly" }' ${filename}.format | sort -n -k 2 -o ${filename}.format;;
		integrated) sort -n -k 2 $filename -o $filename.format;;
	esac
	
	if [ $1 != integrated ]; then
		cat ${filename}.format >> out.integrated.${prefix}
	#else
		#intersection -e 0.4 -m 200 $filename.format ${sample_chr}.benchmark.vcf
		#merge_deletions $filename.format $filename.format.merge && mv $filename.format.merge $filename.format
	fi
}


for $sample_chr in $(cat $sample_chr_list)
do
	> out.integrated.${sample_chr}
	
	for caller in ${callers[@]}
	do
		format $caller
	done
done
