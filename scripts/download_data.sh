#!/bin/bash
set -e

mkdir -p data/raw
cd data/raw

# SKMES1 lung SCC control
fasterq-dump SRR37447630 --split-files --threads 4

# SKMES1 lung SCC treated with lung fibroblast secretome
fasterq-dump SRR37447625 --split-files --threads 4
