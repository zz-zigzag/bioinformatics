#!/bin/sh

. env.sh

. $dir/2.0.feature.sh $1 $2 diff_${1}_${2}
sh ../sh/3.0.verity_result.sh $1 $2 > res.diff_${1}_${2}.txt
sh ../sh/3.1.feature.sh $1 $2 diff_${1}_${2}

fi
