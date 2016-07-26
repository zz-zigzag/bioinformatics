
# callers used in format and compare result
callers=("pindel" "svseq" "breakdancer" "delly" "merged_candidate")
#callers=("pindel" "svseq" "breakdancer" "delly" "cnvnator" "merged_candidate")

sample_list=./list/sample.list
sample_chr_list=./list/sample_chr.list

isTest=0 # 0 or 1
test_sample_chr_list=./list/test_sample_chr.list
sample=NA12878
downsample=_0.25

# vcf
vcf_file=~/NGS_Data/released/1000G.phase3.integrated_sv_map/1000G.phase3.del.genotypes.vcf
needCreatBenchmark=0
benchmark_suffix=benchmark.vcf
#benchmark_suffix=vcf

# slice callset
callset_suffix=
minL=50
maxL=1000000

#allow diff
diffP=0.5
diffM=1000
diff="-e $diffP -m $diffM"


# feature
range_file=range

stats_file=res._e${diffP}_m${diffM}.txt

#libsvm train
C=("32" "8" "2" "1")
#C=("2")
#G=("0.1")
#G=("0.5" "2" "3")
G=("0.2" "0.5" "1" "2")

# others
flag=merged
