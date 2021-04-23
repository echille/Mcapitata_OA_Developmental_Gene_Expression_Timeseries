#!/bin/bash
#SBATCH --job-name="KofamScan"
#SBATCH -t 30-00:00:00
#SBATCH --export=/opt/software/kofam_scan/1.3.0-foss-2019b,/opt/software/HMMER/3.3.2-gompi-2019b/bin/
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=erin_chille@uri.edu
#SBATCH --nodes=1 --ntasks-per-node=20
#SBATCH --mem=500GB
#SBATCH -D /data/putnamlab/erin_chille/mcap2019/annotations/

echo "Loading modules" $(date)
module load kofam_scan/1.3.0-foss-2019b
module load libyaml/0.1.5
module unload HMMER/3.3.1-foss-2019b
module load HMMER/3.3.2-gompi-2019b
module list

#echo "Starting analysis... downloading KO database" $(date)
#wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz #download KO database
#wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz
#gunzip ko_list.gz
#tar xf profiles.tar.gz

echo "Beginning mapping" $(date)
/opt/software/kofam_scan/1.3.0-foss-2019b/exec_annotation -o Mcap_KO_annot.txt -k ./ko_list -p ./profiles/eukaryote.hal -E 0.00001 -f detail-tsv --report-unannotated /data/putnamlab/erin_chille/mcap2019/data/ref/Mcap.protein.fa

echo "Analysis complete!" $(date)
