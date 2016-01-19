#!/bin/bash

help()
{
	echo "
Program: asperdown.sh (download files from ncbi/ebi)
Version: 0.2.0
Contact: zz_zigzag <zz_zigzag@outlook.com>

Usage:   asperadown.sh [options] <LIST-FILE> <MAX-RATE(default [$max_rate]bps)> 
Options: -n        download from ncbi-sra(ftp.ncbi.nlm.nih.gov/130.14.250.13)
         -e        download from ebi-ena(fasp.sra.ebi.ac.uk/193.62.192.6)
         -s url/ip site to download
         -u string user to sign in the site
         -r        max rate of speed[100m]bps
         -h        display this help"
}

if [ $# -lt 2 ]
then 
	help; exit 1;
fi


max_rate=100m

while test $# -ne 0; do
case $1 in
	-n) url=ftp.ncbi.nlm.nih.gov; user=anonftp; shift 1 ;;
	-e) url=fasp.sra.ebi.ac.uk; user=era-fasp; shift 1 ;;
	-s) url=$2; shift 2 ;;
	-u) user=$2; shift 2 ;;
	-r) max_rate=$2; shift 2 ;;
	-h) help; exit 1;;
	-*) echo "$0: invalid option: $1"; exit 1;;
	*) break;;
esac
done

if [ -z $url ] || [ -z $user ] ; 
then 
	help
	exit 1
fi

echo "ascp -k2 -T -l$max_rate -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh --mode recv --host $url --user $user --file-list $1 ."
ascp -k2 -T -l$max_rate -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh --mode recv --host $url --user $user --file-list  $1 .

