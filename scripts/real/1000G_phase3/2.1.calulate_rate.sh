#!/bin/bash

. 0.0.env.sh

status=res._e${diffP}_m${diffM}.txt

if [ -f $status ]; then
    mv $status $status.old
fi

for caller in ${callers[@]}
do
	res=res.${caller}.txt
	echo -n "$caller:" >> $status
	awk '{a+=$2; b+=$3; c+=$4; d+=$5} END{printf("\t%.4f\t%.4f\n", c/a, d/b)}' $res >> $status
done
