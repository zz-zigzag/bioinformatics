#!/bin/bash

. *env*

for chr in `seq 1 22`
do
	chr=chr${chr}
	echo "bsub -q $queue -o %J.split_bam.out \"samtools view -b -h $bam ${chr} > ${sample}_${chr}.bam && samtools index  ${sample}_${chr}.bam\" "
	bsub -q $queue -o %J.split_bam.out "samtools view -b -h $bam ${chr} > ${sample}_${chr}.bam && samtools index  ${sample}_${chr}.bam"
done
