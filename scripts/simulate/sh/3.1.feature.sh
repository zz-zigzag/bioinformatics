#!/bin/sh

. env.sh

if [ $# -lt 3 ]
then 
	echo "Usage: feature.sh <max_diff> <percent_diff> <outprefix> "
else
	
SVfeature -D -b pindel.list -m $1 -e $2 -o pindel_$3
SVfeature -D -b svseq.list -m $1 -e $2 -o svseq_$3
SVfeature -D -b delly.list -m $1 -e $2 -o delly_$3
SVfeature -D -b breakdancer.list -m $1 -e $2 -o breakdancer_$3

fi
