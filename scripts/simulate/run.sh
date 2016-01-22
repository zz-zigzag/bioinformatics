#!/bin/bash

. env.sh

for filename in `cd $dir && ls *.sh `
do
	. $dir/$filename
done 
