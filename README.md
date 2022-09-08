# alevinFryAutomatizer

The aim of this small project was to get a lot of samples re-mapped using the alevin-fry program.

I have installed the program in a singularity image that I uploaded to our GDPR compliant server.
I have created the alevin-fry index using the refdata-gex-GRCh38-2020-A.sh using the 10X genome information.

The logics itself tries to be as flexible as possible.

The Perl script itself only modifies two other scripts:
1. the exampleScript.sh that contains the alevin fry command lines
2. the sbatchScriptFor_exampleScript.sh that starts the singularity with my image and runs the sample specific scripts.


Our server works with slurm workload manager. Therefore this system utilizes the sbatch functionality.
But I hope the logics is flexible enough to be adapted to any other worklowd manager.

This is a very brutal hack but extremely flexible. I hope you can use this for your own work.


## Usage on aurora-ls2

To use the script on aurora-ls2 (aurora does not work) you 'just' need to know where it is stored ;-):

```
/projects/fs1/common/genome/lunarc/10Xindexes/alevin_fry/human/
```

To use the script is rather anoying:

```
perl  /projects/fs1/common/genome/lunarc/10Xindexes/alevin_fry/human/createLotsOfScripts.pl \
	-script /projects/fs1/common/genome/lunarc/10Xindexes/alevin_fry/human/exampleScript.sh \
	-sbatch /projects/fs1/common/genome/lunarc/10Xindexes/alevin_fry/human/sbatchScriptFor_exampleScript.sh \
	-samples ~/NAS/path2fastq/samples.tsv # or wherever you have that \
	-outpath ~/NAS/path2alevin_fry_results \
	> ~/NAS/path2alevin_fry_results/mappAllSamples.sh
```

Of cause you can copy and modify both the exampleScript.sh as well as the sbatchScriptFor_exampleScript.sh and use the scrips logic
for anything else you need sname and R1/R2 fastq.gz files for.

The samples table is quite simple, too. It is a tab separated table with filename in the first column and sample name in the second.
The files are only used if they contain either R1 or R2 and are merged over the sample names into single scripts.
All scripts will be created in the outpath. I strongly recommand to put the scripts output (sbatch commands) into a mapp.sh in this outpath, too.

To start the mapping you can easily run this sbatch script like that:

```
chmod +x ~/NAS/path2alevin_fry_results/mappAllSamples.sh
sbatch ~/NAS/path2alevin_fry_results/mappAllSamples.sh
```


