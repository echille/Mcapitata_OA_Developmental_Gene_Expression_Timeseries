---
layout: post
title: M. capitata functional annotation pipeline 
Author: Erin Chille 
Last Updated: 2020/10/19 
tags: [ Protocol, annotation, RNASeq, GO, KEGG ]
---

## Overview

**Functional annotation of a *Monitpora capitata* reference genome**

Functional annotation tags putative genes in a reference genome or transcriptome with the known functions of homologous genes in other organisms. Homologous sequences are first found using the program BLAST, which searches the reference sequence against a database of reviewed protein sequences. Once homologous sequences are found, genes are tagged with known Gene Ontology or Kegg Pathway terms for the homologous sequences. Annotation allows us to better understand the biological processes that are linked to genes of interest.

**Necessary Programs and Equipment**

- A high performace computer (i.e. the URI bluewaves server; Instructions to obtain server access [here](https://github.com/Putnam-Lab/Lab_Management/blob/master/Bioinformatics_%26_Coding/Bluewaves/Bluewaves_Setup.md)) with the following programs:
    - [DIAMOND](http://www.diamondsearch.org/) Search Program v2.0.0
    - [InterProScan](https://github.com/ebi-pf-team/interproscan) v.5.46-81.0
        - Requires
            - Java v11.0.2
    - [KofamScan](https://github.com/takaram/kofam_scan) v1.3.0
        - Requires
            - Ruby v2.7.1
            - parallel
            - util-linux v2.34
            - HMMER v3.3.1
- A computer/laptop with  with the following programs:
    - [Blast2GO Basic](https://www.blast2go.com/) GUI v5.2.5
    - R v4.0.2
    - RStudio v1.3.959

---

### Step 1: Find homologous sequences:

#### i) Download/Update nr database

The nr, or non-redundant, database is a comprehensive collection of protein sequences that is compiled by the National Center for Biotechnology Information (NCBI). It contains non-identical sequences from GenBank CDS translations, PDB, Swiss-Prot, PIR, and PRF, and is updated on a daily basis.

**If you are in the Putnam Lab and on bluewaves**  
Go to the *sbatch_executables* subdirectory in the Putnam Lab *shared* folder and run the script, ```make_diamond_nr_db.sh```. This script, created by Erin Chille on August 6, 2020, downloads the most recent nr database in FASTA format from [NCBI](ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz) and uses it to make a Diamond-formatted nr database.   

**If you are not in the Putnam Lab**  
Download the nr database from [NCBI](ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz). Then, use Diamond's ```makedb``` command to format the database in a Diamond-friendly format. You can also use the command ```dbinfo``` to find version information for the database.
```
wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz #download nr database in fasta format
diamond makedb --in nr.gz -d nr
diamond dbinfo -d nr.dmnd
```

#### ii) Run DIAMOND Search

With your updated nr database, you can run DIAMOND. DIAMOND, like NCBI's BLAST tool, is a sequence aligner for protein and translated DNA searches. The tool is optimized for large datasets (>1 million sequences), and is 100x-20,000x faster BLAST without losing sensitivity. 

The commands that I used are below, however, the script I used to execute this on bluewaves is available on my project [repository](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/Scripts/Mcap_diamond.sh). As input, DIAMOND requires your reference sequences (either protein or CDS nucleotides), and a path to your nr database. Below, I output the results to DIAMOND format and then convert to XML. I highly suggest the DIAMOND export format, as it can easily be converted into any other format that you may need for your analysis. 

*It may take a few days depending on the number of sequences you have the M. cap genome (~63,000 genes) took 4.5 days*


**Blastx: Align translated DNA query sequences against a protein reference database**

*Options:*
- **-d** - Path to nr database  
- **-q** - Path to reference fasta file  
- **-o** - Base output name  
- **-f** - Output format. **100**=DIAMOND output.     
- **-b** - Block size in billions of sequence letters to be processed at a time. Larger block sizes increase the use of memory and temporary disk space, but also improve performance. Set at **20**. 20 is the highest recommended value. CPU is about 6x this number (in GB).  
- **--more-sensitive** - slightly more sensitive than the --sensitive mode.  
- **-e** - Maximum expected value to report an alignment. **1E-05** is the cut-off typically used for sequence alignments.  
- **-k** - Maximum top sequences. Set at **1** because I only wanted the top sequence reported for each gene.  
- **--unal** - Report unaligned queries (yes=**1**, no=0). 

**View: Generate formatted output from DAA files**

*Options:*  
- **-a** - Path to input file  
- **-o** - Base output name  
- **-f** - Output format. **5**=XML output. 

```
#Run sequence alignment against the nr database
diamond blastx -d /data/putnamlab/shared/databases/nr.dmnd -q ../data/ref/Mcap.mRNA.fa -o Mcap.annot.200806 -f 100  -b 20 --more-sensitive -e 0.00001 -k1 --unal=1

#Converting format to XML format for BLAST2GO
diamond view -a Mcap.annot.200806.daa -o Mcap.annot.200806.xml -f 5
```
---

### Step 2: Map Gene ontology terms to genome  
*Can be done concurrently with Steps 1 and 3*

#### i) InterProScan

InterProScan searches the database InterPro database that compiles information about proteins' function multiple other resources. I used it to map Kegg and GO terms to my Mcap reference protein sequences.

The commands that I used are below, however, the script I used to execute this on bluewaves is available on my project [repository](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/Scripts/IPS.sh). As input, InterProScan requires reference protein sequences. Below, I output the results to XML format, as it is the most data-rich output file and can be used as input into Blast2GO.

*Note: Many fasta files willl use an asterisk to denote a STOP codon. InterProScan does not accept special characters within the sequences, so I removed them prior to running the program using the code below:*

```
cp Mcap.protein.fa ./Mcap.IPSprotein.fa
sed -i 's/*//g' Mcap.IPSprotein.fa
```

**Interproscan.sh: Executes the InterProScan Program**

*Options:*

- **-version** - displays version number
- **-f** - output format
- **-i** - the input data
- **-b** - the output file base
- **-iprlookup** - enables mapping
- **-goterms** - map GO Terms
- **-pa** - enables Kegg term mapping

```
interproscan.sh -version
interproscan.sh -f XML -i ../data/ref/Mcap.IPSprotein.fa -b ./Mcap.interpro.200824  -iprlookup -goterms -pa 
```

#### ii) Blast2GO

*For more information on Blast2GO, see the user manual, [here](https://insilicogen.com/media/manual/2020/01/16/OmicsBox_User_Manual_v1.2.pdf).*

Blast2GO is a powerful annotation tool that takes the output from BLAST, and matches the IDs of the homologous sequences identified to gene ontology terms in the GO database. To map GO terms to our identified sequences, I used the DIAMOND output XML file as input for Blast2GO mapping. I then combined the output of Blast2GO with the XML file generated from InterProScan. Blast2GO mapping took about 16 hours to complete on Mcap sequences and about 45 minutes for Pacuta sequences.

First, open Blast2GO. Click the down arrow next to "Start" and select "Load BLAST XML"



Merge (add and validate) all GO terms retrieved via InterProScan to the already existing GO annotation.

#### iii) Uniprot

### Step 3: Map Kegg terms to genome  
*Uses KofamScan. Can be done concurrently with Steps 1 and 2. Currently Troubleshooting*



### Step 5: Compilation of the output of different methods

Done in RStudio. See RMarkdown [page](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/RNAseq_Analyses/annot/Mcap_annot_compile.html).