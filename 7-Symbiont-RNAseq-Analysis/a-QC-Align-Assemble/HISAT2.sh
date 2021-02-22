#!/bin/bash
#SBATCH --job-name="alignment"
#SBATCH -t 100:00:00
#SBATCH --export=NONE
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=erin_chille@uri.edu
#SBATCH -D /data/putnamlab/erin_chille/mcap2019/huffmyer
#SBATCH --mem=127GB

echo "Loading necessary programs" $(date)

module load HISAT2/2.1.0-foss-2018b #Alignment to reference genome: HISAT2
module load SAMtools/1.9-foss-2018b #Preparation of alignment for assembly: SAMtools

hisat2-build -f symbiont_genome_cat.fasta symbiont_ref

echo "Aligning paired end reads to the reference genome" $(date)
#Has the R1 in array1 because the sed in the for loop changes it to an R2. SAM files are of both forward and reverse reads
array1=($(ls *_R1_001.clean.fastq.gz))

# This then makes it into a bam file
# And then also sorts the bam file because Stringtie takes a sorted file for input
# And then removes the sam file because I don't need it anymore

for i in ${array1[@]}; do
        echo "HISAT2 PE ${i}" $(date)        
        hisat2 -p 8 --rf --dta -q -x symbiont_ref -1 ${i} -2 $(echo ${i}|sed s/_R1/_R2/) -S ${i}.sam
        samtools sort -@ 8 -o ${i}.bam ${i}.sam
        rm ${i}.sam
        echo "${i} bam-ified!" $(date)
done
