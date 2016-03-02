#!/bin/bash

. 0.0.env.sh

extract="SimpleFeature -D $diff"
#DeletionFeatures
#SVfeature

#$extract -b pindel.chrom11.list -o pindel.chrom11
#$extract -b pindel.chrom20.list -o pindel.chrom20

#$extract -b svseq.chrom11.list -o svseq.chrom11
#$extract -b svseq.chrom20.list -o svseq.chrom20

#$extract -b delly.chrom11.list -o delly.chrom11
#$extract -b delly.chrom20.list -o delly.chrom20

#$extract -b breakdancer.chrom11.list -o breakdancer.chrom11
#$extract -b breakdancer.chrom20.list -o breakdancer.chrom20

$extract -b list1 
