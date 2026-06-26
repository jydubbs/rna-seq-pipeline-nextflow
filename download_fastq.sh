#!/bin/bash
#SBATCH --job-name=sra_fastq
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G
#SBATCH --time=12:00:00
#SBATCH --output=sra_fastq_%j.out
#SBATCH --error=sra_fastq_%j.err

module purge
module load sra-tools/3.0.3-gcc-12.2.0

mkdir -p data/raw
mkdir -p tmp

for SRR in SRR37447630 SRR37447632 SRR37447633 SRR37447625 SRR37447626 SRR37447627
do
    echo "Processing $SRR"

    prefetch $SRR

    fasterq-dump \
        ${SRR}/${SRR}.sra \
        --split-files \
        --threads 4 \
        -t tmp \
        -O data/raw
    echo "done $SRR"
done
