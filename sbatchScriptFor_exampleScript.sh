#! /bin/bash

#SBATCH -n 10 
#SBATCH -N 1
#SBATCH -t 24:00:00
#SBATCH -A lsens2018-3-3
#SBATCH -p dell
#SBATCH -J SSNAME
#SBATCH -o SSNAME.%j.out
#SBATCH -e SSNAME.%j.err

singularity exec ~/common/software/SingSingCell/1.5/SingleCells_v1.5.sif OUTPATH_script.sh 

exit 0
