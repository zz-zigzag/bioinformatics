callers=("pindel" "svseq" "breakdancer" "delly" "integrated")
exclude=("1" "2" "10" "16")
sample=NA12878

benchmark_vcf=benchmark.vcf
#benchmark_vcf=vcf

#allow diff
diffP=0.3
diffM=1000
diff="-e $diffP -m $diffM"

#libsvm train
C=("32" "16" "8" "4" "2" "1")

#G=("0.5" "2" "3")
G=("0.01" "0.1" "0.5" "1" "2" "3")

flag=merged
