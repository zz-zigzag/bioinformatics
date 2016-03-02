#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Usage: down-sampling <percent[0.5]>"
	return
fi

. *env*
for i in `seq 1 22`
do
	chr=chr$i
	bsub -q $queue -o %J.downsampling.${sample}_${chr}.out "samtools view -hb -s $1 ${sample}_${chr}.bam > ${sample}_${chr}_$1.bam"
done

