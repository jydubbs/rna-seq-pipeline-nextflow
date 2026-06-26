# DESeq2 differential expression analysis
# Lung fibroblast secretome vs control

# ----------------
# Load packages
# ----------------

library(DESeq2)
library(ggplot2)
library(pheatmap)

# ----------------
# Set paths
# ----------------

counts_file <- "results/counts/gene_counts.txt"
metadata_file <- "samples.csv"

dir.create("analysis/results", recursive = TRUE, showWarnings = FALSE)
dir.create("analysis/plots", recursive = TRUE, showWarnings = FALSE)

# ----------------
# Load count matrix and metadata
# ----------------

rna <- read.delim(counts_file, comment.char = "#")
metadata <- read.csv(metadata_file, stringsAsFactors = FALSE)

counts <- rna[, 7:ncol(rna)]
rownames(counts) <- rna$Geneid

# Remove ".sorted.bam" suffix from featureCounts column names
colnames(counts) <- sub("\\.sorted\\.bam$", "", colnames(counts))

# Reorder metadata to match count matrix columns
metadata <- metadata[match(colnames(counts), metadata$sample_id), ]
rownames(metadata) <- metadata$sample_id

stopifnot(all(colnames(counts) == rownames(metadata)))

metadata$condition <- factor(metadata$condition)
metadata$condition <- relevel(metadata$condition, ref = "control")

# ----------------
# Create DESeq2 object
# ----------------

dds <- DESeqDataSetFromMatrix(countData = counts, colData = metadata, design = ~ condition)

# Filter low-count genes
dds <- dds[rowSums(counts(dds)) >= 10, ]

# ----------------
# Run DESeq2
# ----------------

dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "lung_fibroblast_secretome", "control"))

res <- res[order(res$padj), ]
res_df <- as.data.frame(res)
res_df$gene_id <- rownames(res_df)

write.csv(res_df, "analysis/results/deseq2_results.csv", row.names = FALSE)

norm_counts <- counts(dds, normalized = TRUE)
write.csv(norm_counts, "analysis/results/normalized_counts.csv")

sig <- subset(res_df, padj < 0.05 & abs(log2FoldChange) > 1)
write.csv(sig, "analysis/results/significant_genes_padj0.05_log2FC1.csv",row.names = FALSE)

summary(res)

# ----------------
# QC and plots
# ----------------

vsd <- vst(dds)

# PCA plot
pca_plot <- plotPCA(vsd, intgroup = "condition")
ggsave("analysis/plots/pca_plot.png", plot = pca_plot, width = 7, height = 5, dpi = 300)

# PCA data for outlier inspection
pcaData <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
write.csv(pcaData, "analysis/results/pca_coordinates.csv", row.names = TRUE)

# Sample correlation heatmap
png("analysis/plots/sample_correlation_heatmap.png", width = 1800, height = 1400, res = 200)
cor_matrix <- cor(assay(vsd))
pheatmap(cor_matrix)
dev.off()

# VST expression distribution boxplot
png("analysis/plots/vst_expression_boxplot.png", width = 1800, height = 1200, res = 200)
boxplot(assay(vsd), las = 2, main = "Variance-stabilized expression", ylab = "VST expression")
dev.off()

# MA plot
png("analysis/plots/ma_plot.png", width = 1600, height = 1200, res = 200)
plotMA(res, main = "DESeq2 MA plot")
dev.off()
