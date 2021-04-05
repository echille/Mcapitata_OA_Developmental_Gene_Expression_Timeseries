#!/bin/bash
#SBATCH --job-name="psytrans"
#SBATCH -t 336:00:00
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --exclusive
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=erin_chille@uri.edu
#SBATCH -D /data/putnamlab/erin_chille/mcap2019/data/symbiont/Trinity_psymTrans/2_psymTrans
#SBATCH --mem=500GB
#SBATCH -q putnamlab

module load BLAST+/2.8.1-foss-2018b
module load LIBSVM/3.23-foss-2018b

echo "Separating Host and Symbiont" $(date)

python psytrans.py -A Mcap.protein.fa -B SymbC1.Gene_Models.PEP.fasta -p 20 -t tempDir Mcap_holobiont.fasta

echo "Mission complete!" $(date)
