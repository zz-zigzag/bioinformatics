
#donor/individual
mflen=300
sdev=50
readlen=100
thread=8
chr=20
fold=10
number=10
vcf=~/NGS_Data/phase1-simulate/union.2010_06.deletions.sites.vcf

#allow diff
diffP=0.2
diffM=1000
diff="-e $diffP -m $diffM"

#sh dir
dir=../sh

#SV callers
callers=("pindel" "svseq" "breakdancer" "delly" "integrate")
