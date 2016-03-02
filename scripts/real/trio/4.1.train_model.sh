#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Usage: train_model <sample_data>"
	return
fi


C=("32" "16" "8")
G=("0.5" "2" "3")

formatDataToLibsvm $1 $1.data
svm-scale -r train.range $1.data > $1.scale

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
        svm-predict test.scale $1.scale.model $1.output
    done
done
#svm-train -c 32 -g 2 -v 10 train.scale
