#!/bin/bash

if [ $# != 1 ]
then
	echo "Usage: downsample <sample_data>"
	return 
fi

filename=$1
num=`wc -l $filename | awk '{print $1}'`



foo()
{
	shuf -n `echo $num*$1|bc` $filename > train_$1
}
for i in `seq 1 9`
do
	foo 0`echo $i*0.1|bc`
done

foo 0.75
foo 0.25

grep ^0 train_1 > train_label_0
grep ^1 train_1 > train_label_1

a=`wc -l train_label_0 | awk '{print $1}'`
b=`wc -l train_label_1 | awk '{print $1}'`

if [ $a -lt $b ];
then
	shuf -n $a train_label_1 | cat - train_label_0 | shuf > balance_data
else
	shuf -n $b train_label_0 | cat - train_label_1 | shuf > balance_data
fi
