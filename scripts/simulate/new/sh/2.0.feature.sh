#!/bin/bash

sh env.sh

if [ $# -lt 3 ]
then 
	echo "Usage: feature.sh <max_diff> <percent_diff> <outprefix> "
else

echo "SVfeature -D -b bam.list -m $1 -e $2 -o simulate_$3"
SVfeature -D -b bam.list -m $1 -e $2 -o simulate_$3

fi
