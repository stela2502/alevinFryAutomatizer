#! /bin/bash

## This script is creating the alevin-fry index based on the CellRanger genome files.

SOURCE="/projects/fs1/common/genome/lunarc/10Xindexes/cellranger/6.0/refdata-gex-GRCh38-2020-A"
TARGET="/projects/fs1/common/genome/lunarc/10Xindexes/alevin_fry/human/refdata-gex-GRCh38-2020-A"
INDEXNAME="GRCh38-2020-A-splici"

if [ ! -f $TARGET ]
then
	mkdir $TARGET
else
	echo "path exists"
fi

if [ ! -f $TARGET/splici_fl146.fa ]
then
	pyroe make-splici $SOURCE/fasta/genome.fa $SOURCE/genes/genes.gtf 151 $TARGET --flank-trim-length 5 --filename-prefix splici
else
	echo "using old pyroe run data" 
fi

if [ ! -f $SOURCE/genes/genes.gff ]
then
	gffread $SOURCE/genes/genes.gtf -o $SOURCE/genes/genes.gff
else
	echo "gff file exists"
fi

if [ ! -f $TARGET/geneid_to_name.txt ]
then
	grep "gene_name" $SOURCE/genes/genes.gff | cut -f9 | cut -d';' -f2,3 | sed 's/=/ /g' | sed 's/;/ /g' | cut -d' ' -f2,4 | sort | uniq > $TARGET/geneid_to_name.txt
else
	echo "geneid_to_name.txt exists"
fi

#ls /projects/fs1/common/genome/lunarc/10Xindexes/alevin_fry/human/refdata-gex-GRCh38-2020-A
#  geneid_to_name.txt  splici_fl146.fa  splici_fl146_t2g_3col.tsv

if [ ! -f $TARGET/../GRCh38-2020-A-splici ]
then
	cd $TARGET/..
	echo "salmon index -t $TARGET/splici_fl146.fa -i $INDEXNAME -p 16"

	salmon index -t $TARGET/splici_fl146.fa -i $INDEXNAME -p 16
else
	echo "salomo index has already been finished"
fi
