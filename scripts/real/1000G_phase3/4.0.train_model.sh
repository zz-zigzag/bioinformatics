#!/bin/bash

C=("32" "16" "8")
G=("0.5" "2" "3")

formatDataToLibsvm $1 $1.data
svm-scale -r train.range $1.data > $1.scale
for c in ${C[@]}
do
    for g in ${G[@]}
    do
        echo -n "c/g: $c/$g  "
        svm-train -c $c -g $g -v 5 -q $1.scale
        svm-train -c $c -g $g -q $1.scale
        svm-predict $1.scale $1.scale.model $1.output
        svm-predict test.scale $1.scale.model $1.output
    done
done
#svm-train -c 32 -g 2 -v 10 train.scale
