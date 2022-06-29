#!/bin/bash
./filter_based_on_index.pl
fastq_quality_trimmer -t 35 -l 100 -i SNP44859_S262_L001_R1.demultiplex.fastq -o SNP44859_S262_L001_R1.filtered.fastq -Q33 -v
fastq_quality_trimmer -t 35 -l 100 -i SNP44859_S262_L001_R2.demultiplex.fastq -o SNP44859_S262_L001_R2.filtered.fastq -Q33 -v
./find_pairs.pl
Rscript dada2_assignment.R
./make_table.pl
Rscript genus_plot.R
