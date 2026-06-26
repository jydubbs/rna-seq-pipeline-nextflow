# RNA-seq Pipeline for Lung SCC Treatment Response

## Overview
This repository contains an end-to-end RNA-seq pipeline project for analysing transcriptional changes in the lung squamous cell carcinoma cell line SKMES1 under lung fibroblast secretome treatment versus control.

The workflow automates RNA-seq preprocessing from raw sequencing data and is designed to run reproducibly on both a local machine, and the QMUL Apocrita HPC cluster.

## Dataset
Source: NCBI SRA, BioProject PRJNA1431392

Samples:
- Control: SRR37447630, SRR37447632, SRR37447633
- Treatment: SRR37447625, SRR37447626, SRR37447627

Pipeline workflow:
1. NCBI SRA
2. FASTQ generation (fasterq-dump)
3. Quality trimming (Trim Galore)
4. Genome alignment (HISAT2)
5. BAM sorting (SAMtools sort)
6. BAM indexing (SAMtools index)
7. Gene quantification (featureCounts)
8. gene_counts.txt
9. Differential expression analysis (DESeq2 - planned/pending)

## Project structure
.

├── workflow/

│   └── main.nf

├── scripts/

├── samples.csv

├── run_nextflow.sh

├── download_fastq.sh

├── build_index.sh

├── README.md

Large files are excluded from Git using .gitignore, such as:
- FASTQ files
- BAM files
- HISAT2 index
- featureCounts outputs

## Software
- Nextflow
- Trim Galore
- HISAT2
- SAMtools
- featureCounts (Subread)
- Slurm (Apocrita HPC)

## Running the Pipeline
The workflow is organised into three scripts to separate one-time setup steps from the main analysis.
- download_fastq.sh
Downloads the RNA-seq datasets from the NCBI SRA and converts them to paired-end FASTQ files.
- build_index.sh
Builds the HISAT2 genome index from the reference genome. This step only needs to be performed once for a given reference genome.
- run_nextflow.sh
Submits the Nextflow RNA-seq workflow to the QMUL Apocrita HPC cluster using Slurm.

Run the scripts in the following order:
```bash
sbatch download_fastq.sh
sbatch build_index.sh
sbatch run_nextflow.sh
```

If the pipeline is interrupted, it can be resumed without repeating completed steps using:
```bash
nextflow run workflow/main.nf -resume
```

## Outputs:
results/
├── bam/
│   ├── *.sorted.bam
│   └── *.bai
├── counts/
│   ├── gene_counts.txt
│   └── gene_counts.txt.summary
├── hisat2/
└── trimgalore/

## Current Status
- ✓ Downloaded RNA-seq data from NCBI SRA
- ✓ Built the HISAT2 reference genome index
- ✓ Performed quality trimming using Trim Galore
- ✓ Aligned reads to the reference genome with HISAT2
- ✓ Sorted and indexed BAM files using SAMtools
- ✓ Quantified gene expression using featureCounts
- ✓ Successfully executed the workflow on the QMUL Apocrita HPC cluster
- □ Differential expression analysis with DESeq2 (planned)
