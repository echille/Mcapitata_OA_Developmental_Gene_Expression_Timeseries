#!/bin/bash
#SBATCH --job-name="Trinity"
#SBATCH -t 336:00:00
#SBATCH --export=/opt/software/Trinity/2.9.1-foss-2019b-Python-3.7.4/trinityrnaseq-v2.9.1
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --exclusive
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=erin_chille@uri.edu
#SBATCH -D /data/putnamlab/erin_chille/mcap2019/data/symbiont/Trinity_psymTrans/1_Trinity
#SBATCH --mem=500GB
#SBATCH -q putnamlab

module load Trinity/2.12.0-foss-2019b-Python-3.7.4

echo "Starting assembly" $(date)
Trinity --cite
Trinity --version
Trinity --seqType fq --max_memory 125G --bflyCalculateCPU --CPU 10 --samples_file sample_list.txt --SS_lib_type RF --full_cleanup #run assembly
perl /opt/software/Trinity/2.9.1-foss-2019b-Python-3.7.4/trinityrnaseq-v2.9.1/util/TrinityStats.pl Trinity.fasta > Trinity.stats.txt #check run stats
echo "Assembly complete!" $(date)