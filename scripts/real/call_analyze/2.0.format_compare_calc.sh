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
	filename=out.$1.$sample_chr
	format=$filename.format
	if [ x$callset_suffix == x ]
	then
		case $1 in
			pindel) awk '{if($3>=50 && $3<1000000 && $16>0) print $8"\t"$10"\t"$11"\tpindel" }' $filename | sort -n -k 2 > $format;;
			svseq) awk '{ if($6-$3>=50 && $6-$3<1000000) print $2"\t"$3"\t"$6"\tsvseq" }' $filename | sort -n -k 2 > $format;;
			breakdancer) grep -v '#' $filename | grep DEL  | awk '{ if($5-$2>=50 && $5-$2<1000000) print $1"\t"$2"\t"$5+1"\tbreakdancer" }'  | sort -n -k 2 -o $format;;
			delly) vcf_del $filename $format > /dev/null && awk '{ if($3-$2>=50 && $3-$2<1000000) print $1"\t"$2"\t"$3"\tdelly" }' $format | sort -n -k 2 -o $format;;
			# cnvnator) grep deletion $filename | awk '{print $2}' | sed 's/-/:/g'  | awk -F : '{if ($3-$2<1000000)print $1"\t"$2"\t"$3}' | sort -n -k 2 -o format;;
			merged_candidate) sort -n -k 2 $filename -o $format;;
			delfeature) ;;
		esac
		
		if [ $1 != "merged_candidate" ]; then
			cat $format >> out.merged_candidate.$sample_chr
		else
			if [ x$needCreatBenchmark == x1 ]; then
				intersection -n 2 -e 0.4 -m 200 $filename.format $benchmark
			fi
			merge_variation -e 0.2 -m 200 $filename.format $filename.format.merge  && mv $filename.format.merge $filename.format
		fi
	else
		eval "awk '{if(\$3-\$2>=$minL && \$3-\$2<$maxL) print \$0}' $format > $format$callset_suffix" 
	fi
}

function verify() {
	filename=out.$1.$sample_chr
	format=$filename.format
	verify-deletion $diff $format$callset_suffix $benchmark $filename$callset_suffix.cmp >> res.$1.txt
}

if [ x$isTest == x1 ]; then
	sample_chr_list=$test_sample_chr_list
fi

for sample_chr in $(cat $sample_chr_list)
do
	if [ x$downsample == x1 ]; then
		benchmark=${sample_chr%_*}.$benchmark_suffix
	else
		benchmark=$sample_chr.$benchmark_suffix
	fi
	# benchmark=out.delly.$sample_chr.format 	# for venn
	# benchmark=${sample_chr#*_}.vcf 			# for different {chr1.vcf}, used in trio validated
	if [ x$needFormatCallset == x1 ]; then  	#
		> out.merged_candidate.$sample_chr
		for caller in ${callers[@]}
		do
			format $caller
		done
	fi
	
	for caller in ${callers[@]}
	do
		verify $caller
	done
done


if [ -f $stats_file ]; then
    mv $stats_file $stats_file.old
fi

for caller in ${callers[@]}
do
	res=res.${caller}.txt
	echo -n "$caller" >> $stats_file
	awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{p=c/a; s=d/b; printf("\t%d\t%d\t%d | %d\t%.4f\t%.4f\t%.4f\n",a,b,c,d, p, s, 2*p*s/(p+s))}' $res >> $stats_file
done

