#!/bin/bash

for filename in `ls *.sra`
do
	bsub -q qtest -o %J.out "fastq-dump --split-3 $filename"
done
