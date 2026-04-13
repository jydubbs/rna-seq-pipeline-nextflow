#!/bin/bash
set -e

echo "Starting RNA-seq data download..."

mkdir -p data/raw
cd data/raw

echo "Downloading SRA files..."
prefetch SRR37447630
prefetch SRR37447625

echo "Converting SRA to FASTQ..."
# SKMES1 lung SCC control - subset for pipeline testing
fasterq-dump SRR37447630/SRR37447630.sra --split-files --threads 4 -O data/raw

# SKMES1 lung SCC treated with lung fibroblast secretome - subset for pipeline testing
fasterq-dump SRR37447625/SRR37447625.sra --split-files --threads 4 -O data/raw

echo "Download and conversion complete."
