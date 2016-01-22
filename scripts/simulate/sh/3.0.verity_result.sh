#!/bin/bash

. env.sh

if [ -f ./pindel.list ]; then
	mv pindel.list pindel_old.list
fi
if [ -f ./svseq.list ]; then
	mv svseq.list svseq_old.list
fi
if [ -f ./delly.list ]; then
	mv delly.list delly_old.list
fi
if [ -f ./breakdancer.list ]; then
	mv breakdancer.list breakdancer_old.list
fi

if [ $# -lt 2 ]
then 
	echo "Usage: verity_result.sh <max_diff> <percent_diff> "
else
verify="verify_variant -m $1 -e $2 \$filename.format \$benchmark \$filename.cmp"

for i in $(seq 1 $number)
do
	benchmark=${i}_${chr}_V
	
	filename=out.pindel.${i}_${chr}_D
	grep D $filename | awk '{print $8"\t"$10"\t"$11 }' | sort -n -k 2 > ${filename}.format
	eval $verify
	echo "${i}_${chr}.bam $readlen $mflen $sdev ${filename}.cmp" >> pindel.list
	
	filename=out.svseq.${i}_${chr}
	grep range $filename | awk '{ print $2"\t"$3"\t"$6 }' | sort -n -k 2 > ${filename}.format
	eval $verify
	echo "${i}_${chr}.bam $readlen $mflen $sdev ${filename}.cmp" >> svseq.list
	
	filename=out.delly.${i}_${chr}.vcf
	vcf_del $filename ${filename}.format > /dev/null && sort -n -k 2 ${filename}.format -o ${filename}.format
	eval $verify
	echo "${i}_${chr}.bam $readlen $mflen $sdev ${filename}.cmp" >> delly.list
	
	filename=out.breakdancer.${i}_${chr}
	grep ^$chr $filename | awk '{ print $1"\t"$2"\t"$5 }'  | sort -n -k 2 > ${filename}.format
	eval $verify
	echo "${i}_${chr}.bam $readlen $mflen $sdev ${filename}.cmp" >> breakdancer.list
	
	echo 
done
fi
