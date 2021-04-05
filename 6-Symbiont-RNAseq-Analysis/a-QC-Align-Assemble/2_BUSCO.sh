#!/bin/bash
#SBATCH --job-name="BUSCO"
#SBATCH -t 100:00:00
#SBATCH --export=NONE
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --exclusive
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=XXXXXX
#SBATCH -D XXXXXX
#SBATCH --mem=20GB
#SBATCH -q putnamlab

echo "Starting BUSCO" $(date)

module load BUSCO/4.1.4-foss-2019b-Python-3.7.4

busco --config config.ini -m transcriptome -i Mcap_holobiont.fasta -o alv_busco_out -l busco_downloads/alveolata_odb10 --offline
busco --config config.ini -m transcriptome -i Mcap_holobiont.fasta -o met_busco_out -l busco_downloads/metazoan_odb10 --offline

#concatenate summary output to 1 file
cat alv_busco_out/short_summary.specific.alveolata_odb10.alv_busco_out.txt \
met_busco_out/short_summary.specific.metazoa_odb10.busco_output.txt \
 > Mcap_holobiont_assembly_busco_summary.txt

#copy config file from BUSCO bin

echo "Mission complete!" $(date)