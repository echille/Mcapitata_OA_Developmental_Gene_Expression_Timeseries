# *M. capitata* RNAseq QC, Alignment, Assembly Bioinformatic Pipeline

Author: Erin Chille 
Last Updated: 2020/08/15  
Data uploaded and analyzed on the URI HPC [bluewaves](https://web.uri.edu/hpc-research-computing/using-bluewaves/) server 

*The following document contains the bioinformatic pipeline used for cleaning, aligning and assembling our raw RNA sequences. These commands were compiled into bash scripts to run on the bluewaves server and are available on the [project repository](https://github.com/echille/Montipora_OA_Development_Timeseries/tree/master/Scripts)* 

---

### Project overview

![bioinformatic_pipeline.png](https://raw.githubusercontent.com/echille/Montipora_OA_Development_Timeseries/master/_images/bioinformatic_pipeline.png)  

**Bioinformatic tools used in analysis:**  
Quality check: [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), [MultiQC](https://multiqc.info/)  
Quality trimming: [Fastp](https://github.com/OpenGene/fastp)  
Alignment to reference genome: [HISAT2](https://ccb.jhu.edu/software/hisat2/index.shtml)  
Preparation of alignment for assembly: [SAMtools](http://www.htslib.org/doc/samtools.html)  
Transcript assembly and quantification: [StringTie](https://ccb.jhu.edu/software/stringtie/) 

### Prepare work space

---

- Upload raw reads and reference genome to server
- Assess that your files have all uploaded correctly
- Prepare your working directory
- Install all necessary programs

#### Upload raw reads and reference genome to server

This is done with the ```scp``` or "secure copy" linux command. SCP allows the secure transferring of files between a local host and a remote host or between two remote hosts using ssh authorization.

++Secure Copy (scp) Options++:  
- -P - Identifies the port number  
- -r - Recursively copy entire directories
```
scp -r -P xxxx <path_to_raw_reads> echille@kitt.uri.edu:<path_to_storage>
scp -P xxxx <path_to_reference> echille@kitt.uri.edu:<path_to_storage>
```

Check to make sure you have all of your files, and that they all follow the same naming convention. There should be 96 fastq.gz files. First we will look at our list of files in our read storage directory, and then we will count the number of fastq.gz files.
```
ls
ls -l | cat | wc -l
```

#### Assess that your files have all uploaded correctly

Check to make sure the files downloaded correctly using the md5sum command. First store the md5checksum in a file then verify the contents of the new md5sum file.
```
md5sum *.fastq.gz > raw_checksum.md5
md5sum -c raw_checksum.md5
```
- [x] ++Md5 Output++:  
All files "OK"

Check number of reads per file
```
zgrep -c "@GWNJ" *.fastq.gz
```

- [x] ++Raw Read Counts++:  

|Forward raw read|Count|Reverse raw read|Count|
|---|---|---|---|
|119_R1_001.fastq.gz|21430810|119_R2_001.fastq.gz|21430810|
|120_R1_001.fastq.gz|22587714|120_R2_001.fastq.gz|22587714|
|121_R1_001.fastq.gz|19342285|121_R2_001.fastq.gz|19342285| 
|127_R1_001.fastq.gz|23494302|127_R2_001.fastq.gz|23494302|
|128_R1_001.fastq.gz|19003021|128_R2_001.fastq.gz|19003021|
|129_R1_001.fastq.gz|18364685|129_R2_001.fastq.gz|18364685|
|130_R1_001.fastq.gz|19545789|130_R2_001.fastq.gz|19545789|
|131_R1_001.fastq.gz|18473442|131_R2_001.fastq.gz|18473442|
|132_R1_001.fastq.gz|18818657|132_R2_001.fastq.gz|18818657|
|133_R1_001.fastq.gz|20820329|133_R2_001.fastq.gz|20820329|
|134_R1_001.fastq.gz|19009948|134_R2_001.fastq.gz|19009948|
|153_R1_001.fastq.gz|18739012|153_R2_001.fastq.gz|18739012|
|154_R1_001.fastq.gz|25865443|154_R2_001.fastq.gz|25865443|
|155_R1_001.fastq.gz|23884925|155_R2_001.fastq.gz|23884925|
|156_R1_001.fastq.gz|23346656|156_R2_001.fastq.gz|23346656|
|157_R1_001.fastq.gz|19122552|157_R2_001.fastq.gz|19122552|
|158_R1_001.fastq.gz|19082407|158_R2_001.fastq.gz|19082407|
|159_R1_001.fastq.gz|19524641|159_R2_001.fastq.gz|19524641|  
|160_R1_001.fastq.gz|19606641|160_R2_001.fastq.gz|19606641|
|162_R1_001.fastq.gz|19809873|162_R2_001.fastq.gz|19809873|
|163_R1_001.fastq.gz|17708842|163_R2_001.fastq.gz|17708842|
|164_R1_001.fastq.gz|18134442|164_R2_001.fastq.gz|18134442|
|165_R1_001.fastq.gz|22428255|165_R2_001.fastq.gz|22428255|
|166_R1_001.fastq.gz|19475406|166_R2_001.fastq.gz|19475406|
|167_R1_001.fastq.gz|19437286|167_R2_001.fastq.gz|19437286|
|168_R1_001.fastq.gz|20184280|168_R2_001.fastq.gz|20184280|
|169_R1_001.fastq.gz|16229966|169_R2_001.fastq.gz|16229966|
|179_R1_001.fastq.gz|17619983|179_R2_001.fastq.gz|17619983|
|180_R1_001.fastq.gz|16093732|180_R2_001.fastq.gz|16093732|
|181_R1_001.fastq.gz|15181783|181_R2_001.fastq.gz|15181783|
|182_R1_001.fastq.gz|23523998|182_R2_001.fastq.gz|23523998|
|183_R1_001.fastq.gz|15687664|183_R2_001.fastq.gz|15687664|
|184_R1_001.fastq.gz|15938817|184_R2_001.fastq.gz|15938817|
|185_R1_001.fastq.gz|16001863|185_R2_001.fastq.gz|16001863|
|186_R1_001.fastq.gz|17647767|186_R2_001.fastq.gz|17647767|  
|212_R1_001.fastq.gz|18557355|212_R2_001.fastq.gz|18557355|
|215_R1_001.fastq.gz|17131176|215_R2_001.fastq.gz|17131176|
|218_R1_001.fastq.gz|20737823|218_R2_001.fastq.gz|20737823|
|221_R1_001.fastq.gz|18375097|221_R2_001.fastq.gz|18375097|
|359_R1_001.fastq.gz|19316079|359_R2_001.fastq.gz|19316079|
|361_R1_001.fastq.gz|19161682|361_R2_001.fastq.gz|19161682|
|363_R1_001.fastq.gz|23704031|363_R2_001.fastq.gz|23704031|
|365_R1_001.fastq.gz|20178446|365_R2_001.fastq.gz|20178446|
|367_R1_001.fastq.gz|18859459|367_R2_001.fastq.gz|18859459|
|371_R1_001.fastq.gz|19914348|371_R2_001.fastq.gz|19914348|
|373_R1_001.fastq.gz|16196572|373_R2_001.fastq.gz|16196572|
|375_R1_001.fastq.gz|17074897|375_R2_001.fastq.gz|17074897|
|379_R1_001.fastq.gz|18041698|379_R2_001.fastq.gz|18041698|
|1101_R1_001.fastq.gz|21636831|1101_R2_001.fastq.gz|21636831|
|1548_R1_001.fastq.gz|17651137|1548_R2_001.fastq.gz|17651137|
|1628_R1_001.fastq.gz|21647915|1628_R2_001.fastq.gz|21647915|

#### Prepare your working directory

Create your working directory. Within your working directory make subdirectories for scripts, data, and output. Enter the data directory and make a subdirectory to place raw reads and reference files.
```
mkdir mcap2019
cd mcap2019

mkdir scripts
mkdir output
mkdir data

cd data
mkdir raw
mkdir ref
```

Create symbolic links to raw reads and reference sequence
```
ln -s <path_to_raw_reads>/*.fastq.gz ./raw/
ln -s <path_to_reference> ./ref/
```

#### Install all necessary programs

Install programs within your conda environment, when possible.

Create and activate a conda environment. Must have [miniconda](https://docs.conda.io/en/latest/miniconda.html) installed.
```
conda create -n mcap2019
conda activate mcap2019
```

Install all necessary programs within your conda environment
```
conda install fastqc
conda install multiqc
conda install fastp
conda install hisat2
conda install samtools
```

The version of StringTie available on Bioconda is not the most recent version (v2.1.0). The version installed in conda (v2.0) has errors when running with the '-e' option that we need for this next step in StringTie. We will have to install StringTie outside of the conda environment. The following commands will install the latest version and test the binary. This only took about 3 min to run.
```
git clone https://github.com/gpertea/stringtie
cd stringtie
make release
make test
```

### Quality control and read trimming

---

- Initial quality check of raw reads
- Quality-trimming of reads
- Post-trimming quality check of reads

#### Initial quality check of raw reads

*FastQC is a bioinformatic tool that generates sequence quality information of your reads. Multiqc summarizes FastQC analysis logs and summarizes results in an html report.*

Run FastQC in the raw directory.
```
fastqc ./*.fastq.gz
```

Make a data subdirectory for your raw fastqc results and move FastQC results into there. Then compile MultiQC report.
```
mkdir ../fastqc_raw
cd fastqc_raw
mv ../raw/*fastqc* ./
multiqc ./
```

Move the MultiQC report to output directory. Then, from the local host securely copy the MultiQC report to a local directory.
```
mv ./multiqc_report.html ../../ouput/multiqc_report_raw.html

scp -P xxxx echille@kitt.uri.edu:<path_to_output>/multiqc_report_raw.html /Users/user/<path_to_local_directory>
```
- [x] ++Output++:  
*All raw sequences 150 bp*  
![raw_fastqc_per_base_sequence_quality_plot.png](https://raw.githubusercontent.com/echille/Montipora_OA_Development_Timeseries/master/Output/RNAseq/raw_fastqc_plots/raw_fastqc_per_base_sequence_quality_plot.png)
![raw_fastqc_per_sequence_quality_scores_plot.png](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/Output/RNAseq/raw_fastqc_plots/raw_fastqc_per_sequence_quality_scores_plot.png?raw=true)  
![raw_fastqc_per_sequence_gc_content_plot.png](https://raw.githubusercontent.com/echille/Montipora_OA_Development_Timeseries/master/Output/RNAseq/raw_fastqc_plots/raw_fastqc_per_sequence_gc_content_plot.png)  
![raw_fastqc_adapter_content_plot.png](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/Output/RNAseq/raw_fastqc_plots/raw_fastqc_adapter_content_plot.png?raw=true)

#### Quality-trimming of reads

*To clean our reads we will be using a program called FastP, a tool designed to provide fast all-in-one preprocessing for FastQ files.*

++Goals of quality trimming++:  
- Remove adapters
- Remove low-quality reads
- Remove reads with high abundance of unknown bases

Make a subdirectory for cleaned reads within the data directory.
```
mkdir cleaned_reads
```

++FastP Arguments/Options Used++:  
- --in1 - Path to forward read input  
- --in2 - Path to reverse read input  
- --out1 - Path to forward read output  
- --out2 - Path to reservse read output  
- --failed_out - Specify file to store reads that fail filters  
- --qualified_quality_phred - Phred quality >= -q is qualified (20)
- --unqualified_percent_limit - % of bases allowed to be unqualified (10)  
- --length_required - Set required sequence length (100)
- --detect_adapter_for_pe - Adapters can be trimmed by overlap analysis, however, --detect_adapter_for_pe will usually result in slightly cleaner output than overlap detection alone. This results in a slightly slower run time  
- --cut_right - Move a sliding window from front to tail. Use cut_right_window_size to set the window size (5), and cut_right_mean_quality (20) to set the mean quality threshold.  
- --html - The html format report file name

```
sh -c 'for file in "119" "120" "121" "127" "128" "129" "130" "131" "132" "133" "134" "153" "154" "155" "156" "157" "158" "159" "160" "162" "163" "164" "165" "166" "167" "168" "169" "179" "180" "181" "182" "183" "184" "185" "186" "212" "215" "218" "221" "359" "361" "363" "365" "367" "371" "373" "375" "379"
do
fastp --in1 ${file}_R1_001.fastq.gz --in2 ${file}_R2_001.fastq.gz --out1 ../cleaned_reads/${file}_R1_001.clean.fastq.gz --out2 ../cleaned_reads/${file}_R2_001.clean.fastq.gz --failed_out ../cleaned_reads/${file}_failed.txt --qualified_quality_phred 20 --unqualified_percent_limit 10 --length_required 100 detect_adapter_for_pe --cut_right cut_right_window_size 5 cut_right_mean_quality 20
done'
```
#### Post-trimming quality check of reads

Now that we've trimmed the adapters, low-quality reads and reass with many unknown bases, we will again check our sequence quality. first, we will check the trimmed sequence lengths, and then run FastQC again to examine our GC and adapter content, and our phred quality scores.

Check the clean read count.
```
zgrep -c "@GWNJ" *.fastq.gz
```

- [x] ++Clean Read Counts++:  

|Forward clean read|Count|Reverse clean read|Count|
|---|---|---|---|
|119_R1_001.clean.fastq.gz|15735471|119_R2_001.clean.fastq.gz|15735471|
|120_R1_001.clean.fastq.gz|16746988|120_R2_001.clean.fastq.gz|16746988|
|121_R1_001.clean.fastq.gz|14738013|121_R2_001.clean.fastq.gz|14738013|
|127_R1_001.clean.fastq.gz|16571299|127_R2_001.clean.fastq.gz|16571299|
|128_R1_001.clean.fastq.gz|13859037|128_R2_001.clean.fastq.gz|13859037|
|129_R1_001.clean.fastq.gz|13206196|129_R2_001.clean.fastq.gz|13206196|
|130_R1_001.clean.fastq.gz|14162329|130_R2_001.clean.fastq.gz|14162329|
|131_R1_001.clean.fastq.gz|13293825|131_R2_001.clean.fastq.gz|13293825|
|133_R1_001.clean.fastq.gz|14505821|133_R2_001.clean.fastq.gz|14505821|
|132_R1_001.clean.fastq.gz|13809914|132_R2_001.clean.fastq.gz|13809914|
|134_R1_001.clean.fastq.gz|13596112|134_R2_001.clean.fastq.gz|13596112|
|153_R1_001.clean.fastq.gz|13186807|153_R2_001.clean.fastq.gz|13186807|
|154_R1_001.clean.fastq.gz|18637363|154_R2_001.clean.fastq.gz|18637363|
|155_R1_001.clean.fastq.gz|16751962|155_R2_001.clean.fastq.gz|16751962|
|156_R1_001.clean.fastq.gz|16717897|156_R2_001.clean.fastq.gz|16717897|
|157_R1_001.clean.fastq.gz|13851434|157_R2_001.clean.fastq.gz|13851434|
|158_R1_001.clean.fastq.gz|13354481|158_R2_001.clean.fastq.gz|13354481|
|159_R1_001.clean.fastq.gz|14457629|159_R2_001.clean.fastq.gz|14457629|
|160_R1_001.clean.fastq.gz|14489484|160_R2_001.clean.fastq.gz|14489484|
|162_R1_001.clean.fastq.gz|14700108|162_R2_001.clean.fastq.gz|14700108|
|163_R1_001.clean.fastq.gz|13185051|163_R2_001.clean.fastq.gz|13185051|
|164_R1_001.clean.fastq.gz|12773001|164_R2_001.clean.fastq.gz|12773001|
|165_R1_001.clean.fastq.gz|16091087|165_R2_001.clean.fastq.gz|16091087|
|166_R1_001.clean.fastq.gz|14487569|166_R2_001.clean.fastq.gz|14487569|
|167_R1_001.clean.fastq.gz|14479586|167_R2_001.clean.fastq.gz|14479586|
|168_R1_001.clean.fastq.gz|14473684|168_R2_001.clean.fastq.gz|14473684|
|169_R1_001.clean.fastq.gz|11824893|169_R2_001.clean.fastq.gz|11824893|
|179_R1_001.clean.fastq.gz|12913165|179_R2_001.clean.fastq.gz|12913165|
|180_R1_001.clean.fastq.gz|11919642|180_R2_001.clean.fastq.gz|11919642|
|181_R1_001.clean.fastq.gz|11187477|181_R2_001.clean.fastq.gz|11187477|
|182_R1_001.clean.fastq.gz|17048929|182_R2_001.clean.fastq.gz|17048929|
|183_R1_001.clean.fastq.gz|11526429|183_R2_001.clean.fastq.gz|11526429|
|184_R1_001.clean.fastq.gz|12030136|184_R2_001.clean.fastq.gz|12030136|
|185_R1_001.clean.fastq.gz|11744187|185_R2_001.clean.fastq.gz|11744187|
|186_R1_001.clean.fastq.gz|13327721|186_R2_001.clean.fastq.gz|13327721|
|212_R1_001.clean.fastq.gz|13858209|212_R2_001.clean.fastq.gz|13858209|
|215_R1_001.clean.fastq.gz|12766725|215_R2_001.clean.fastq.gz|12766725|
|218_R1_001.clean.fastq.gz|15156983|218_R2_001.clean.fastq.gz|15156983|
|221_R1_001.clean.fastq.gz|13847948|221_R2_001.clean.fastq.gz|13847948|
|359_R1_001.clean.fastq.gz|14742426|359_R2_001.clean.fastq.gz|14742426|
|361_R1_001.clean.fastq.gz|14274364|361_R2_001.clean.fastq.gz|14274364|
|363_R1_001.clean.fastq.gz|17167695|363_R2_001.clean.fastq.gz|17167695|
|365_R1_001.clean.fastq.gz|15092858|365_R2_001.clean.fastq.gz|15092858|
|367_R1_001.clean.fastq.gz|13882376|367_R2_001.clean.fastq.gz|13882376|
|371_R1_001.clean.fastq.gz|14862977|371_R2_001.clean.fastq.gz|14862977|
|373_R1_001.clean.fastq.gz|11650596|373_R2_001.clean.fastq.gz|11650596|
|375_R1_001.clean.fastq.gz|12509060|375_R2_001.clean.fastq.gz|12509060|
|379_R1_001.clean.fastq.gz|13669693|379_R2_001.clean.fastq.gz|13669693|
|1101_R1_001.clean.fastq.gz|16961235|1101_R2_001.clean.fastq.gz|16961235|
|1548_R1_001.clean.fastq.gz|13570117|1548_R2_001.clean.fastq.gz|13570117|
|1628_R1_001.clean.fastq.gz|16640766|1628_R2_001.clean.fastq.gz|16640766|

Run FastQC on clean reads
```
fastqc ./*.fastq.gz
```
Make a data subdirectory for your clean fastqc results and move FastQC results into there. Then compile MultiQC report.
```
mkdir fastqc_clean
cd fastqc_clean
mv ../cleaned_reads/*fastqc* ./
multiqc ./
```

Move the MultiQC report to output directory. Then, from the local host securely copy the MultiQC report to a local directory.
```
mv ./multiqc_report.html ../../ouput/multiqc_report_clean.html

```
```
scp -P xxxx echille@kitt.uri.edu:<path_to_output>/multiqc_report_clean.html /Users/user/<path_to_local_directory>
```
- [x] ++Output++:  
![clean_fastqc_sequence_length_distribution_plot.png](https://raw.githubusercontent.com/echille/Montipora_OA_Development_Timeseries/master/Output/RNAseq/clean_fastqc_plots/clean_fastqc_sequence_length_distribution_plot.png)  
![clean_fastqc_per_base_sequence_quality_plot.png](https://raw.githubusercontent.com/echille/Montipora_OA_Development_Timeseries/master/Output/RNAseq/clean_fastqc_plots/clean_fastqc_per_base_sequence_quality_plot.png)
![clean_fastqc_per_sequence_quality_scores_plot.png](https://raw.githubusercontent.com/echille/Montipora_OA_Development_Timeseries/master/Output/RNAseq/clean_fastqc_plots/clean_fastqc_per_sequence_quality_scores_plot.png)  
![clean_fastqc_per_sequence_gc_content_plot.png](https://raw.githubusercontent.com/echille/Montipora_OA_Development_Timeseries/master/Output/RNAseq/clean_fastqc_plots/clean_fastqc_per_sequence_gc_content_plot.png)  
![clean_fastqc_adapter_content_plot.png](https://raw.githubusercontent.com/echille/Montipora_OA_Development_Timeseries/master/Output/RNAseq/clean_fastqc_plots/clean_fastqc_adapter_content_plot.png)

### Alignment of clean reads to reference genome

---

*HISAT2 is a fast and sensitive alignment program for mapping next-generation DNA and RNA sequencing reads to a reference genome.*

- Index the reference genome
- Alignment of clean reads to the reference genome

Create a subdirectory within data for HISAT2 and symbolically link ot your clean fastq files.
```
mkdir hisat2
cd hisat2
ln -s ../cleaned_reads/*fastq* ./
```

#### Index the reference genome

Index the reference genome in the reference directory.

++HISAT2-build Alignment Arguments Used++:  
- <reference_in> - name of reference files  
- <gt2_base> -  basename of index files to write  
- -f -  reference file is a FASTA file

```
cd ref
hisat2-build -f ../ref/Mcap.genome_assembly.fa ./Mcap_ref
```

#### Alignment of clean reads to the reference genome

Align your reads to the index files. We will do this by writing a script we will call ```McapHISAT2.sh```. This script will also take the output SAM files from our HISAT2 alignment and covert them into the sorted BAM files that are the necessary input for our assembly tool, StringTie. We do this by calling SAMtools in our script.

++HISAT2 Alignment Arguments Used++:   
- -x <hisat2-idx> - Basename of index files to read  
- -1 <m1> - List of forward sequence files  
- -2 <m1> - List of reverse sequence files  
- -S - Name of output files
- -q - Input files are in FASTQ format  
- -p - Number processors
- --rf - Reads are stranded
- --dta - Adds the XS tag to indicate the genomic strand that produced the RNA from which the read was sequenced. As noted by StringTie... "be sure to run HISAT2 with the --dta option for alignment, or your results will suffer."

++SAMtools Options Arguments Used++:  
- -@ - Number threads  
- -o - Output file  

```
nano McapHISAT2.sh
```
```
##!/bin/bash

#Specify working directory
F=/home/echille/mcap2019/data/hisat2

#Aligning paired end reads
#Has the R1 in array1 because the sed in the for loop changes it to an R2. SAM files are of both forward and reverse reads
array1=($(ls $F/*_R1_001.clean.fastq.gz))

# This then makes it into a bam file
# And then also sorts the bam file because Stringtie takes a sorted file for input
# And then removes the sam file because I don't need it anymore

for i in ${array1[@]}; do
        hisat2 -p 8 --rf --dta -q -x Mcap_ref -1 ${i} -2 $(echo ${i}|sed s/_R1/_R2/) -S ${i}.sam
        samtools sort -@ 8 -o ${i}.bam ${i}.sam
    		echo "${i}_bam"
        rm ${i}.sam
        echo "HISAT2 PE ${i}" $(date)
done
```

Now, make the file executable by the user (you) and run the script.
```
chmod u+x McapHISAT2.sh
./McapHISAT2.sh
```
Now we've got some sorted BAM files that can be used in our assembly!!

### Assemble aligned reads and quantify transcripts 

---

*StringTie is a fast and highly efficient assembler of RNA-Seq alignments into potential transcripts.*

- Reference-guided assembly with novel transcript discovery
- Merge output GTF files and assess the assembly performance
- Compilation of GTF-files into gene and transcript count matrices

#### Reference-guided assembly with novel transcript discovery

First, create and enter into StringTie directory. Then create a symbolic link to our reference genome and copy our BAM files to a special directory inside our stringtie directory. This is where our output GTF files will live too.
```
mkdir ../stringtie
cd stringtie
ln -s ../ref/Mcap.GFFannotation.gff ./
mkdir BAM
cd BAM
ln -s ../../hisat2/*.bam ./
cd ../
```

Create the StringTie reference-guided assembly script, ```McapStringTie-assembly.sh``` *inside of the StringTie program directory.*  

++StringTie Arguments Used++:  
- -A - Output gene abundance file
- -p - Specify number of processers
- --rf - Reads are stranded
- -e - Limit the estimation and output of transcripts to only those that match the reference (in this case, our merged GTF)
- -G - Specify annotation file
- -o - Name of output file

```
cd stringtie
mkdir gene_abund #Make directory for gene abundance files
nano ./McapStringTie-assembly.sh
```
```
##!/bin/bash

#Specify working directory
F=/home/echille/mcap2019/data/stringtie

#StringTie reference-guided assembly
#Has the R1 in array1 because of the naming convention in the former script. However, these BAM files contain both forward and reverse reads.
array1=($(ls $F/BAM/*_R1_001.clean.fastq.gz.bam))

for i in ${array1[@]}; do
        ./stringtie -A gene_abund/{i}.gene_abund.tab -p 8 --rf -e -G Mcap.GFFannotation.gff -o ${i}.gtf ${i}
        mv /ref-guided-gtfs/${i}.gtf
        echo "StringTie-assembly-to-ref ${i}" $(date)
done
```

Now, make the file executable by the user and run the script.
```
chmod u+x McapStringTie-assembly.sh
./McapStringTie-assembly.sh
```

#### Assess the performance of the assembly

*Gffcompare is a tool that can compare, merge, annotate and estimate accuracy of GFF/GTF files when compared with a reference annotation*

Using the StringTie merge mode, merge the assembly-generated GTF files to assess how well the predicted transcripts track to the reference annotation file. This step requires the TXT file,  [```mergelist.txt```](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/RNAseq_Analyses/mergelist.txt). This file lists all of the file names to be merged. *Make sure ```mergelist.txt``` is in the StringTie program directory*.

++StringTie Arguments Used++:  
- --merge - Distinct from the assembly usage mode used above, in the merge mode, StringTie takes as input a list of GTF/GFF files and merges/assembles these transcripts into a non-redundant set of transcripts.
- -p - Specify number of processers
- -G - Specify reference annotation file. With this option, StringTie assembles the transfrags from the input GTF files with the reference sequences
- -o - Name of output file
- <mergelist.txt> - File listing all filenames to be merged. Include full path.

```
./stringtie --merge -p 8 -G ../Mcap.GFFannotation.gff -o ../stringtie_merged.gtf mergelist.txt
```

Now we can use the program gffcompare to compare the merged GTF to our reference genome.

++Gffcompare Arguments Used++:  
- -r - Specify reference annotation file
- -G - Compare all the transcripts in our input file ```stringtie_merged.gtf```
- -o - Prefix of all output files

```
gffcompare -r ../Mcap.GFFannotation.gff -G -o ../merged ../stringtie_merged.gtf
```

Some of the output files you will see are... 
- merged.stats
- merged.tracking
- merged.annotated.gtf
- merged.stringtie_merged.gtf.refmap
- merged.loci
- merged.stringtie_merged.gtf.tmap

Move all of the gffcompare output files to the output directory. We are most interested in the files ```merged.annotation.gtf``` and ```merged.stats```. The file ```merged.annotation.gtf``` tells you how well the predicted transcripts track to the reference annotation file and the file ```merged.stats``` file shows the sensitivity and precision statistics and total number for different features (genes, exons, transcripts).  Then, from the local host securely copy ```merged.stats``` to a local directory. Unfortunately, ```merged.annotation.gtf``` is too big to store locally, but we can view it remotely.

```
scp -P xxxx echille@kitt.uri.edu:<path_to_output>/merged.stats /Users/user/<path_to_local_directory>
```

#### Compilation of GTF-files into gene and transcript count matrices

The StringTie program includes a script, ```prepDE.py``` that compiles your assembly files into gene and transcript count matrices. This script requires as input the list of sample names and their full file paths, [```sample_list.txt```](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/RNAseq_Analyses/sample_list.txt). This file will live in StringTie program directory.

Go back into your stringtie directory (the one I should have named assembly). Run ```prepDE.py``` to merge assembled files together into a DESeq2-friendly version.

++StringTie prepDE.py Arguments Used++:  
- -i - Specify that input is a TXT file
- -g - Require output gene count file, default name is ```gene_count_matrix.csv```
- -t - Require output transcript count gene count file, default name is ```transcript_count_matrix.csv```

```
./prepDE.py -g ../gene_count_matrix.csv -i ./sample_list.txt
```

Finally, move your count matrices into the output directory and securely copy them to your local directory, from your local host.
```
cd ../
mv ./*.csv ../../output
```
```
scp -P xxxx echille@kitt.uri.edu:<path_to_output>/*.csv /Users/user/<path_to_local_directory>
``` 


