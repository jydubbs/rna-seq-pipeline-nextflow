#!/bin/bash
#SBATCH --job-name=rnaseq_nf
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=rnaseq_nf_%j.out
#SBATCH --error=rnaseq_nf_%j.err

module purge
module load nextflow

nextflow run workflow/main.nf -resume
