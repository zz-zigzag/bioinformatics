#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Usage: train_model <train_data> <test_data>"
	exit 1
fi

. *env*

if [ ! -f $range_file ]
then
    echo "need range_file: $range_file "
fi


formatDataToLibsvm $1
svm-scale -r $range_file $1.data > $1.scale
formatDataToLibsvm $2
svm-scale -r $range_file $2.data > $2.scale

n0=`grep ^0 $1 | wc -l `
n1=`grep ^1 $1 | wc -l `
w=`echo "scale=2; $n0/$n1" | bc `


for c in ${C[@]}
do
    for g in ${G[@]}
    do
        echo  "c/g: $c/$g  "
#		svm-train -c $c -g $g -w1 $w -v 10 -q $1.scale
        svm-train -c $c -g $g -w1 $w -q $1.scale
        svm-predict $1.scale $1.scale.model $1.output
        svm-predict $2.scale $1.scale.model $1.output
    done
done
#svm-train -c 32 -g 2 -v 10 train.scale
