#! /bin/bash

## run this script like that:
## singularity exec /projects/fs1/common/software/SingSingCell/1.5/SingleCells_v1.5.sif ./exampleScript.sh

#ls /projects/fs1/stefanl/

INDEX="/projects/fs1/common/genome/lunarc/10Xindexes/alevin_fry/human/refdata-gex-GRCh38-2020-A-splici"
MAP="/projects/fs1/common/genome/lunarc/10Xindexes/alevin_fry/human/refdata-gex-GRCh38-2020-A/splici_fl146_t2g_3col.tsv"

#R1="/projects/fs1/stefanl/MattiasMagnusson/Pravan_Prabhala/2020_146_Pavan/Fastq_Raw/sample_19/sample_19_S9_L001_R1_001.fastq.gz /projects/fs1/stefanl/MattiasMagnusson/Pravan_Prabhala/2020_146_Pavan/Fastq_Raw/sample_19/sample_19_S9_L002_R1_001.fastq.gz"

R1="R1FILES"

R2="R2FILES"

#R2="/projects/fs1/stefanl/MattiasMagnusson/Pravan_Prabhala/2020_146_Pavan/Fastq_Raw/sample_19/sample_19_S9_L001_R2_001.fastq.gz /projects/fs1/stefanl/MattiasMagnusson/Pravan_Prabhala/2020_146_Pavan/Fastq_Raw/sample_19/sample_19_S9_L002_R2_001.fastq.gz"

TARGET="OUTPATH"


if [ ! -f $TARGET ]
then
	salmon alevin -i $INDEX -p 16 -l ISR --chromium --sketch -1 $R1 -2 $R2 -o $TARGET
else
	echo "salmon alevin alredy finished"
fi

if [ ! -f $TARGET-quant ]
then
	alevin-fry generate-permit-list -d fw -k -i $TARGET -o $TARGET-quant
	alevin-fry collate -t 16 -i $TARGET-quant -r $TARGET
else
        echo "alevin-fry generate-permit-list alredy finished"
fi

if [ ! -f $TARGET-quant_res ]
then
	alevin-fry quant -t 16 -i $TARGET-quant -o $TARGET-quant_res --tg-map $MAP --resolution cr-like --use-mtx
else
        echo "alevin-fry quant alredy finished"
fi

exit 0
