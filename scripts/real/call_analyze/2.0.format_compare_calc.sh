#!/bin/bash

. *env*

for caller in ${callers[@]}
do
	res=res.${caller}.txt
	if [ -f ./$res ]; then
		mv $res $res.old
	fi
done


function format() {
	filename=out.${1}.${sample_chr}
	case $1 in
		pindel) awk '{if($3>=50 && $3<1000000 && $16>0) print $8"\t"$10"\t"$11"\tpindel" }' $filename | sort -n -k 2 > ${filename}.format;;
		svseq) awk '{ if($6-$3>=50 && $6-$3<1000000) print $2"\t"$3"\t"$6"\tsvseq" }' $filename | sort -n -k 2 > ${filename}.format;;
		breakdancer) grep -v '#' $filename | grep DEL  | awk '{ if($5-$2>=50 && $5-$2<1000000) print $1"\t"$2"\t"$5+1"\tbreakdancer" }'  | sort -n -k 2 -o ${filename}.format;;
		delly) vcf_del $filename ${filename}.format > /dev/null && awk '{ if($3-$2>=50 && $3-$2<1000000) print $1"\t"$2"\t"$3"\tdelly" }' ${filename}.format | sort -n -k 2 -o ${filename}.format;;
		integrated) sort -n -k 2 $filename -o $filename.format;;
	esac
	
	if [ $1 != integrated ]; then
		cat ${filename}.format >> out.integrated.${sample_chr}
	else
		intersection -e 0.4 -m 200 $filename.format ${sample_chr}.benchmark.vcf
		merge_variation -e 0.2 -m 200 $filename.format $filename.format.merge  && mv $filename.format.merge $filename.format
	fi
}

function verify() {
	filename=out.${1}.${sample_chr}
	verify-deletion $diff ${filename}.format $benchmark ${filename}.cmp >> res.${1}.txt
}


for $sample_chr in $(cat $sample_chr_list)
	benchmark=${sample_chr}.$benchmark_suffix
	> out.integrated.${sample_chr}
	for caller in ${callers[@]}
	do
		format $caller
		verify $caller
	done
done


if [ -f $stats_file ]; then
    mv $stats_file $stats_file.old
fi

for caller in ${callers[@]}
do
	res=res.${caller}.txt
	echo -n "$caller:" >> $stats_file
	awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{printf("\t%d\t%d\t%d|%d\t%.4f\t%.4f\n",a,b,c,d, c/a, d/b)}' $res >> $stats_file
done

