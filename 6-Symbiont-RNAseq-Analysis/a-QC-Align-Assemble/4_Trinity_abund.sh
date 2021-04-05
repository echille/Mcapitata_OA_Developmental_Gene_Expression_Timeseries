#!/bin/bash
#SBATCH --job-name="Trinity"
#SBATCH -t 336:00:00
#SBATCH --export=/opt/software/Trinity/2.12.0-foss-2019b-Python-3.7.4/trinityrnaseq-v2.12.0/util/,/opt/software/Bowtie2/2.3.5.1-GCC-8.3.0/bin,/opt/software/RSEM/1.3.3-foss-2019b/bin
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --exclusive
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=erin_chille@uri.edu
#SBATCH -D /data/putnamlab/erin_chille/mcap2019/data/symbiont/Trinity_psymTrans/3_Trinity
#SBATCH --mem=500GB
#SBATCH -q putnamlab

module load Trinity/2.12.0-foss-2019b-Python-3.7.4
module load RSEM/1.3.3-foss-2019b

## Align planula samples against symbiont-separated assembly

echo "Preparing reference for alignment and abundance estimation" $(date)
/opt/software/Trinity/2.12.0-foss-2019b-Python-3.7.4/trinityrnaseq-v2.12.0/util/align_and_estimate_abundance.pl --transcripts symb_Trinity.fasta --est_method RSEM --aln_method bowtie2  --SS_lib_type RF --trinity_mode --prep_reference

#echo "Running the alignment and abundance estimation." $(date)
#This allows sample-specific abundance estimation if running in parallel
/opt/software/Trinity/2.12.0-foss-2019b-Python-3.7.4/trinityrnaseq-v2.12.0/util/align_and_estimate_abundance.pl --transcripts symb_Trinity.fasta --seqType fq --samples_file sample_list.txt --est_method RSEM --aln_method bowtie2 --SS_lib_type RF --trinity_mode

## Building Isoform and Gene CountExpression Matrix
echo "Building gene expression matrices"
/opt/software/Trinity/2.12.0-foss-2019b-Python-3.7.4/trinityrnaseq-v2.12.0/util/abundance_estimates_to_matrix.pl --est_method RSEM  --quant_files RSEM_results_list.txt --gene_trans_map symb_Trinity.fasta.gene_trans_map --name_sample_by_basedir

echo "Mission complete." $(date)
