#!/bin/bash

for filename in $(ls *_D)
do
    grep ChrID $filename > out.pindel.${filename%_D}
done
