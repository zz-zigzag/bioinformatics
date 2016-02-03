#!/bin/bash

if [ ! -d ./res ]; then
    mkdir res
fi

for filename in $(ls *_D)
do
    grep ChrID $filename > ./res/${filename%_D}
done
