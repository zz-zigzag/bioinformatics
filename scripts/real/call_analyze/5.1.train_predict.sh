#!/bin/bash

help()
{
	echo "
Program: train_project
Usage:	 train_predict [options] <sample_data>
Options: -t kernel_type see libsvm[2]"
}

if [ $# -lt 1 ]
then
	help; exit;
fi

t=2
if [ x$3 != x ]
then
	t=$3
fi

if [ $t -lt 0 -o $t -gt 3 ]
then
	help; exit;
fi

. *env*

data=$1

foo()
{
	model=$data.${c}_${g}_$num.model
	case $t in
		0) command="svm-train -t 0 -c $c -w1 $num -q $data $model" ;;
		1) command="svm-train -t 1 -d $d -c $c -w1 $num -q $data $model" ;;
		2) command="svm-train -c $c -g $g -w1 $num -q $data $model" ;;
		3) command="svm-train -t 3 -c $c -g $g -w1 $num -q $data $model" ;;
	esac
	
	echo $command
	if [ ! -f $data.${c}_${g}_$num.model ]; then
		eval $command
	fi
	command=". 5.0.predict.sh $model $num"
	echo $command
	eval $command
}


t0()
{
	for c in ${C[@]}
	do
		wait
		echo  "c: $c" >> $stats_file
		for((j=10;j<=100;j=j+5))
		do
			num=`echo $j*0.1|bc`
			foo &
		done
	done
}


t1()
{
	for d in `seq 1 5`
	do
		for c in ${C[@]}
		do
	   		wait
		    echo  "c/d: $c/$d  " >> $stats_file
			for((j=10;j<=100;j=j+5))
			do
				num=`echo $j*0.1|bc`
				foo &
			done
		done
	done
}

t2()
{
	for c in ${C[@]}
	do
		for g in ${G[@]}
		do
	   		wait
			echo  "c/g: $c/$g  " >> $stats_file
			for((j=10;j<=100;j=j+10))
			do
				num=`echo $j*0.1|bc`
				foo &
			done
		done
	done
}

t3()
{
	for g in ${G[@]}
	do
		for c in ${C[@]}
		do
	   		wait
			echo  "c/g: $c/$g  " >> $stats_file
			for((j=10;j<=100;j=j+5))
			do
				num=`echo $j*0.1|bc`
				foo &
			done
		done
	done
}

t$t
wait

