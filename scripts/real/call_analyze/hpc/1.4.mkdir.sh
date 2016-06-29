#!/bin/bash

mkdir -p bsub_out
mv *.out bsub_out/

mkdir -p list used_sh feature

mkdir -p bam/bam_cfg
mv *.cfg bam/bam_cfg
mv *.bam *.bai *.bas bam/

mkdir -p raw_callset/pindel
mv out.pindel* raw_callset/pindel && cd raw_callset/pindel && . ../../1.0.simplify_pindel_callset.sh && tar czvf res.pindel.tar.gz out* && rm out* && cd -

mkdir -p raw_callset/svseq
mv out.svseq* raw_callset/svseq && cd raw_callset/svseq && . ../../1.1.simplify_svseq_callset.sh && tar czvf res.svseq.tar.gz out* && rm out* && cd -

mkdir -p raw_callset/breakdancer
cp out.breakdancer* raw_callset/breakdancer

mkdir -p raw_callset/delly
cp out.delly* raw_callset/delly
