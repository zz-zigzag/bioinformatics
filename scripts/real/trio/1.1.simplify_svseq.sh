#!/bin/bash

if [ ! -d ./res ]; then
    mkdir res
fi

for filename in `ls out.svseq.*`
do
    grep 'range' $filename > ./res/$filename
done
