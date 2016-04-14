#!/bin/bash

. *env*

for sample_chr in $(cat $test_sample_chr_list)
do
	filename=${sample_chr}.feature
	formatDataToLibsvm $filename
	echo "svm-scale -r train.range $filename.data > $filename.scale"
	svm-scale -r train.range $filename.data > $filename.scale
done
