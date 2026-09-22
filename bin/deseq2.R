#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(tximport)
  library(DESeq2)
  library(ggplot2)
})

args <- commandArgs(trailingOnly = TRUE)
quant_dir   <- args[1]   # directory containing one subfolder per sample
metadata_f  <- args[2]   # sample,condition csv
tx2gene_f   <- args[3]   # tx2gene.tsv
outdir      <- args[4]

dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

metadata <- read.csv(metadata_f, stringsAsFactors = FALSE)
metadata$condition <- factor(metadata$condition, levels = c("uninduced", "induced"))

files <- file.path(quant_dir, metadata$sample, "quant.sf")
names(files) <- metadata$sample
stopifnot(all(file.exists(files)))

tx2gene <- read.table(tx2gene_f, header = FALSE, sep = "\t")

txi <- tximport(files, type = "salmon", tx2gene = tx2gene, ignoreTxVersion = TRUE)

dds <- DESeqDataSetFromTximport(txi, colData = metadata, design = ~ condition)
dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "induced", "uninduced"))
res_df <- as.data.frame(res)
res_df$gene <- rownames(res_df)
res_df <- res_df[order(res_df$padj), ]

write.csv(res_df, file.path(outdir, "deseq2_results.csv"), row.names = FALSE)

# Volcano plot
res_df$sig <- with(res_df, !is.na(padj) & padj < 0.05 & abs(log2FoldChange) > 1)
p <- ggplot(res_df, aes(x = log2FoldChange, y = -log10(pvalue), color = sig)) +
  geom_point(alpha = 0.6, size = 1.2) +
  scale_color_manual(values = c("grey60", "firebrick"), guide = "none") +
  theme_minimal(base_size = 14) +
  labs(title = "Differential expression: induced vs uninduced",
       x = "log2 fold change", y = "-log10(p-value)")
ggsave(file.path(outdir, "volcano_plot.png"), p, width = 7, height = 5.5, dpi = 150)

cat("DESeq2 complete. Significant genes (padj<0.05, |log2FC|>1):",
    sum(res_df$sig, na.rm = TRUE), "\n")
