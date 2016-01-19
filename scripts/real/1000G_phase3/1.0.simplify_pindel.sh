#!/bin/sh

for filename in $(ls *_D)
do
    awk '$2=="D"' $filename > out.pindel.${filename%_D}
done
