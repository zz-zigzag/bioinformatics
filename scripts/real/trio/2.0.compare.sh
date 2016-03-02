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
function format() {
	filename=out.${1}.${prefix}
	case $1 in
		pindel) awk '{if($3>=50 && $3<1000000 && $16>0) print $8"\t"$10"\t"$11"\tpindel" }' $filename | sort -n -k 2 > ${filename}.format;;
#		pindel) awk '{if($3>=50 && $3<1000000) print $0"\tpindel" }' $filename | sort -n -k 2 > ${filename}.format;;
		svseq) awk '{ if($6-$3>=50 && $6-$3<1000000) print $2"\t"$3"\t"$6"\tsvseq" }' $filename | sort -n -k 2 > ${filename}.format;;
		breakdancer) grep -v '#' $filename | grep DEL  | awk '{ if($5-$2>=50 && $5-$2<1000000) print $1"\t"$2"\t"$5+1"\tbreakdancer" }'  | sort -n -k 2 -o ${filename}.format;;
		delly) vcf_del $filename ${filename}.format > /dev/null && awk '{ if($3-$2>=50 && $3-$2<1000000) print $1"\t"$2"\t"$3"\tdelly" }' ${filename}.format | sort -n -k 2 -o ${filename}.format;;
		integrated) sort -n -k 2 $filename -o $filename.format;;
	esac
	
	if [ $1 != integrated ]; then
		cat ${filename}.format >> out.integrated.${prefix}
	else
		intersection -e 0.4 -m 200 $filename.format ${prefix}.benchmark.vcf
		merge_variation -e 0.2 -m 200 $filename.format $filename.format.merge  && mv $filename.format.merge $filename.format
	fi
}

for i in $(seq 1 22)
do
<<a
	if [ x$i != x6 -a x$i != x7 -a x$i != x8 -a x$i != x9 ]
	then
		continue
	fi
a
#<<o
	if [ x$i == x1 -o x$i == x2 -o x$i == x10 -o x$i == x16 ]
	then
		continue
	fi
#o
	chr=chr$i
	prefix=${sample}_$chr
	benchmark=${prefix}.$benchmark_vcf
	> out.integrated.${prefix}
	for caller in ${callers[@]}
	do
		format $caller
		verify $caller
	done
done

status=res._e${diffP}_m${diffM}.txt

if [ -f $status ]; then
    mv $status $status.old
fi

for caller in ${callers[@]}
do
	res=res.${caller}.txt
	echo -n "$caller:" >> $status
	awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{printf("\t%.4f\t%.4f\n", c/a, d/b)}' $res >> $status
done

