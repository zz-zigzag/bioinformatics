#!/bin/bash

. *env*


if [ -f $stats_file ]; then
    mv $stats_file $stats_file.old
fi

for caller in ${callers[@]}
do
	res=res.${caller}.txt
	echo -n "$caller:" >> $stats_file
	awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{printf("\t%d\t%d\t%d|%d\t%.4f\t%.4f\n",a,b,c,d, c/a, d/b)}' $res >> $stats_file
done
