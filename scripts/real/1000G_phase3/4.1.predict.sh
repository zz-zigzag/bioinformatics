#!/bin/bash

. 0.0.env.sh

if [ -f ./res.validated.txt ]; then
	mv res.validated.txt res.validated.txt.old
fi

verify="verify_variant $diff \${filename}.format \$benchmark \${filename}.cmp"

i=0
for sample in `cat list.sample `
do
	let i++
	
	prefix=$sample.chrom11
	benchmark=${prefix}.vcf
	filename=out.validated.$prefix
	filename2=out.integrate.$prefix
	easy-predict integrate.chrom11_${i}_normalized train.scale.model $filename
	paste $filename2.format $filename | awk '{if($4==1) print $1"\t"$2"\t"$3}' > $filename.format
	eval $verify >> res.validated.txt
	
	prefix=$sample.chrom20
	benchmark=${prefix}.vcf
	filename=out.validated.$prefix
	filename2=out.integrate.$prefix
	easy-predict integrate.chrom20_${i}_normalized train.scale.model $filename
	paste $filename2.format $filename | awk '{if($4==1) print $1"\t"$2"\t"$3}' > $filename.format
	eval $verify >> res.validated.txt
done

grep chrom11 res.validated.txt > res.validated.chrom11.txt
grep chrom20 res.validated.txt > res.validated.chrom20.txt

status=res._e${diffP}_m${diffM}.txt
echo -n "validated:" >> $status
awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{printf("\t%.4f\t%.4f\n", c/a, d/b)}' res.validated.txt >> $status

