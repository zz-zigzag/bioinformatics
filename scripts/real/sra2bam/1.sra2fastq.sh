#!/bin/bash

for filename in `ls *.sra`
do
	fastq-dump --split-3 $filename
done
