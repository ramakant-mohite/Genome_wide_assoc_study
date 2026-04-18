#!/usr/bin/env Rscript

# ============================================================
# PCA Plotting Script (1000 Genomes + Study Samples)
# Author: Ramakant Mohite
# Description:
#   - Generates PCA scatter plot with 1000 Genomes reference
#   - Overlays study samples
#   - Produces scree plot (variance explained)
#   - Outputs publication-ready figures
# ============================================================

cat("[INFO] Starting PCA plotting pipeline\n")

# -----------------------------
# Check required files
# -----------------------------
required_files <- c("pca_results.eigenvec", "pca_results.eigenval", "1000G_pop.txt") # nolint
missing_files <- required_files[!file.exists(required_files)]

if (length(missing_files) > 0) {
  stop(paste("[ERROR] Missing files:", paste(missing_files, collapse=", ")))
}

# -----------------------------
# Load libraries
# -----------------------------
suppressPackageStartupMessages({
  library(ggplot2)
})

# -----------------------------
# Load PCA data
# -----------------------------
cat("[INFO] Loading PCA data\n")

pca <- read.table("pca_results.eigenvec", header=FALSE, stringsAsFactors=FALSE)
colnames(pca) <- c("FID","IID", paste0("PC",1:20))

meta <- read.table("1000G_pop.txt", header=TRUE, stringsAsFactors=FALSE)

# Merge PCA + metadata
df <- merge(pca, meta, by="IID", all.x=TRUE)

# Assign groups
df$Group <- ifelse(is.na(df$SuperPop), "STUDY", df$SuperPop)

df$Group <- factor(df$Group,
                   levels=c("AFR","AMR","EAS","EUR","SAS","STUDY"))

# -----------------------------
# Variance explained
# -----------------------------
cat("[INFO] Calculating variance explained\n")

eig <- scan("pca_results.eigenval", quiet=TRUE)
var_percent <- eig / sum(eig) * 100

# -----------------------------
# Output directory
# -----------------------------
dir.create("results", showWarnings=FALSE)

# ============================================================
# PCA Plot
# ============================================================
cat("[INFO] Generating PCA plot\n")

p_pca <- ggplot() +

  # Reference populations
  geom_point(
    data=subset(df, Group!="STUDY"),
    aes(PC1, PC2, color=Group),
    size=1,
    alpha=0.35
  ) +

  # Study samples (same style, but included in legend)
  geom_point(
    data=subset(df, Group=="STUDY"),
    aes(PC1, PC2, color=Group),
    shape=21,
    fill="white",
    size=1.6,
    stroke=0.5
  ) +

  scale_color_manual(values = c(
    AFR   = "#F8766D",
    AMR   = "#A3A500",
    EAS   = "#00BF7D",
    EUR   = "#00B0F6",
    SAS   = "#E76BF3",
    STUDY = "black"
  )) +

  theme_classic(base_size=12) +

  labs(
    x = paste0("PC1 (", round(var_percent[1],2), "%)"),
    y = paste0("PC2 (", round(var_percent[2],2), "%)"),
    title = "PCA with 1000 Genomes Reference",
    color = "Population"
  )

# Save PCA
ggsave("results/PCA.png", p_pca, width=6, height=5, dpi=300)

# ============================================================
# Scree Plot
# ============================================================
cat("[INFO] Generating scree plot\n")

df_var <- data.frame(
  PC = 1:length(var_percent),
  Variance = var_percent
)

p_scree <- ggplot(df_var[1:10,], aes(PC, Variance)) +
  geom_point(size=2) +
  geom_line() +
  theme_classic(base_size=12) +
  labs(
    title = "Scree Plot (Top 10 PCs)",
    x = "Principal Component",
    y = "Variance Explained (%)"
  )

# Save scree
ggsave("results/PCA_scree.png", p_scree, width=5, height=4, dpi=300)

# -----------------------------
# Done
# -----------------------------
cat("[DONE] Outputs saved:\n")
cat(" - results/PCA.png\n")
cat(" - results/PCA_scree.png\n")