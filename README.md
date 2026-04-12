# RNA-seq Pipeline for Lung SCC Treatment Response

## Overview
This repository contains an end-to-end RNA-seq pipeline project for analysing transcriptional changes in the lung squamous cell carcinoma cell line SKMES1 under lung fibroblast secretome treatment versus control.

## Dataset
Source: NCBI SRA, BioProject PRJNA1431392

Initial test samples:
- Control: SRR37447630
- Treatment: SRR37447625

## Project structure
- `data/` - raw and processed data (not tracked in Git)
- `scripts/` - shell scripts for downloading and running analysis
- `workflow/` - Nextflow workflow files
- `results/` - output files (not tracked in Git)

## Current progress
- Repository initialized
- Project structure created
- Initial SRA sample selection completed
- Download script added

## Usage
Download initial test samples:

```bash
bash scripts/download_data.sh

