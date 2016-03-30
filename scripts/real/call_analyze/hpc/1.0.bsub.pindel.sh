#!/bin/bash

. *env*
for i in `seq 1 22`
do
	chr=chr$i
	echo "${sample}_${chr}.bam 300 ${sample}" > ${sample}_${chr}.pindel.cfg
	echo bsub -q $queue  -n $thread -o %J.pindel.${sample}_${chr}.out "pindel -f $hg19 -i ${sample}_${chr}.pindel.cfg -o out.pindel.${sample}_${chr}  -c $chr -r false -t false -w 0.1 -x 5 -B 0 -T 4"
	bsub -q $queue  -n $thread -o %J.pindel.${sample}_${chr}.out "pindel -f $hg19 -i ${sample}_${chr}.pindel.cfg -o out.pindel.${sample}_${chr}  -c $chr -r false -t false -w 0.1 -x 5 -B 0 -T 4"
done

