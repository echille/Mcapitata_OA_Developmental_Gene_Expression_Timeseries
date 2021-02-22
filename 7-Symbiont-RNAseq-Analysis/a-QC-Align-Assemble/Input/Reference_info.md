# Reference information for **Symbiodiniaceae** RNAseq analysis

As the reference file was too large to supply on github. This file contains information on where references files were obtained and prepared.

Reference files (FASTA and GFF) were obtained for *Durusdinium* and *Cladocopium* symbionts from the [OIST Marine Genomics Unit Database](https://marinegenomics.oist.jp/gallery) and concatenated to form a reference for alignment and assembly.

### Durusdinium sp. ver. 1.0:

Entry: [Durusdinium sp. ver. 1.0](https://marinegenomics.oist.jp/symbd/viewer/download?project_id=102)

FASTA: [102_symbd_genome_scaffold.fa.gz](https://marinegenomics.oist.jp/symbd/download/102_symbd_genome_scaffold.fa.gz)

GFF: [102_symbd.gff.gz](https://marinegenomics.oist.jp/symbd/download/102_symbd.gff.gz)

**Citation:**  
Shoguchi, E., Beedessee, G., Hisata, K., Tada, I., Narisoko, H., Satoh, N., Kawachi, M. and Shinzato, C., 2021. A New Dinoflagellate Genome Illuminates a Conserved Gene Cluster Involved in Sunscreen Biosynthesis. *Genome Biology and Evolution*, 13(2), p.evaa235.

### Symbiodinium sp. clade C ver. symbC.v1.0

Entry: [Symbiodinium sp. clade C ver. symbC.v1.0](https://marinegenomics.oist.jp/symb/viewer/download?project_id=40)

FASTA: [symC_scaffold_40.fasta.gz](https://marinegenomics.oist.jp/symb/download/symC_scaffold_40.fasta.gz)

GFF: [40_symb.gff.gz](https://marinegenomics.oist.jp/symb/download/40_symb.gff.gz)

**Citation:**  
Shoguchi, E., Beedessee, G., Tada, I., Hisata, K., Kawashima, T., Takeuchi, T., Arakaki, N., Fujie, M., Koyanagi, R., Roy, M.C. and Kawachi, M., 2018. Two divergent Symbiodinium genomes reveal conservation of a gene cluster for sunscreen biosynthesis and recently lost genes. *BMC genomics*, 19(1), pp.1-11.


### Instructions for Downloading and Concatenating Files:

Use ```curl``` to download in linux. The files are extremely large so be sure that you have enough storage. You may decide to remove the orginal files once they are concatenated.  
```
# FASTA  
curl https://marinegenomics.oist.jp/symbd/download/102_symbd_genome_scaffold.fa.gz | gunzip #CladeD

curl https://marinegenomics.oist.jp/symb/download/symC_scaffold_40.fasta.gz | gunzip #CladeC

# GFF  
curl https://marinegenomics.oist.jp/symbd/download/102_symbd.gff.gz | gunzip #CladeD

clurl https://marinegenomics.oist.jp/symb/download/40_symb.gff.gz | gunzip #Clade C
```

Concatenate FASTA files together and GFF files together. Output names listed here are those used in the scripts for [Alignment](https://github.com/echille/Mcapitata_OA_Developmental_Gene_Expression_Timeseries/blob/main/7-Symbiont-RNAseq-Analysis/a-QC-Align-Assemble/HISAT2.sh) and [Assembly](https://github.com/echille/Mcapitata_OA_Developmental_Gene_Expression_Timeseries/blob/main/7-Symbiont-RNAseq-Analysis/a-QC-Align-Assemble/stringtie.sh).  
```
#Save combined FASTA files to file called symbiont_genome_cat.fasta
cat 102_symbd_genome_scaffold.fa symC_scaffold_40.fasta > symbiont_genome_cat.fasta

#Save combined GFF files to file called symbiont.gff 
cat 102_symbd.gff 40_symb.gff > symbiont.gff 
```
 *Optional:* Remove orginal files
``` 
rm 102_symbd_genome_scaffold.fa
rm symC_scaffold_40.fasta
rm 102_symbd.gff
rm 40_symb.gff
```