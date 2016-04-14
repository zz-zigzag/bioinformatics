sample=NA12878
bam=${sample}_S1.bam
queue=qtest
thread=4
downsample="_0.25"

#allow diff
diffP=0.3
diffM=1000
diff="-e $diffP -m $diffM"

