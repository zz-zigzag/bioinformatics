
# callers used in format and compare result
callers=("pindel" "svseq" "breakdancer" "delly" "integrated")

sample_list=./list/sample.list
sample_chr_list=./list/sample_chr.list
test_sample_chr_list=./list/test_sample_chr.list
sample=NA12878

vcf_file=integrated.vcf

benchmark_suffix=benchmark.vcf
#benchmark_suffix=vcf

#allow diff
diffP=0.3
diffM=1000
diff="-e $diffP -m $diffM"

stats_file=res._e${diffP}_m${diffM}.txt

#libsvm train
C=("32" "16" "8" "4" "2" "1")

#G=("0.5" "2" "3")
G=("0.01" "0.1" "0.5" "1" "2" "3")

flag=merged
