#!/bin/bash
#SBATCH --job-name=hisat2_index
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=06:00:00
#SBATCH --output=hisat2_index_%j.out
#SBATCH --error=hisat2_index_%j.err

module purge
module load hisat2/2.2.1-gcc-12.2.0-g5omdki

hisat2-build -p 8 reference/GRCh38.primary_assembly.genome.fa reference/genome_index
