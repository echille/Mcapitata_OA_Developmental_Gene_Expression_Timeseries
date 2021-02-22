#!/bin/bash
#SBATCH --job-name="huffmyer_stringtie"
#SBATCH -t 100:00:00
#SBATCH --export=NONE
#SBATCH --exclusive
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=ashuffmyer@uri.edu
#SBATCH -D /data/putnamlab/erin_chille/mcap2019/huffmyer
#SBATCH --mem=100GB

module load StringTie/2.1.1-GCCcore-7.3.0
module load gffcompare/0.11.5-foss-2018b
module load Python/2.7.15-foss-2018b

echo "Starting assembly" $(date)

#StringTie reference-guided assembly
#Has the R1 in array1 because of the naming convention from alignment with HISAT2. However, these BAM files contain both forward and reverse reads.
array1=($(ls *_R1_001.clean.fastq.gz.bam))

#Running with the -e option to compare output to exclude novel genes. Also output a file with the gene abundances
for i in ${array1[@]}; do
        stringtie -A gene_abund/${i}gene_abund.tab --rf -e -G symbiont.gff -o ${i}.gtf ${i}
        echo "StringTie-assembly-to-ref ${i}" $(date)
done
echo "Assembly complete!" $(date)

echo "Starting assembly analysis..." $(date)

#Merge GTFs to form full GTF for analysis of assembly accuracy and precision
stringtie --merge -G symbiont.gff -o stringtie_merged.gtf mergelist.txt
echo "Stringtie merge" $(date)

#Compute the accuracy and precision of assembly
gffcompare -r symbiont.gff -G stringtie_merged.gtf -o merged
echo "GFFcompare complete! Starting gene count matrix assembly..." $(date)

#Compile the gene count matrix
python ./prepDE.py -g gene_count_matrix.csv -i sample_list.txt
echo "Hooray!!! Gene count matrix complete!" $(date)
