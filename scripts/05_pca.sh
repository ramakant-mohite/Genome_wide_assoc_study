#!/bin/bash
set -euo pipefail

# Author: Ramakant Mohite
# Purpose: PCA + validation for ancestry analysis

INPUT=merged_pruned

echo "[INFO] Checking input files"
ls ${INPUT}.bed ${INPUT}.bim ${INPUT}.fam

# ============================================================
echo "[STEP 5] Principal Component Analysis (PCA)"
# ============================================================

# Rationale:
# - PCA captures genome-wide ancestry structure
# - Performed on LD-pruned SNPs (~57K SNPs retained)
# - Joint PCA (study + 1000G) enables ancestry inference

plink \
  --bfile ${INPUT} \
  --pca 20 \
  --out pca_results \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee pca_results.log

echo "[INFO] PCA complete"

# ============================================================
# VALIDATION BLOCK
# ============================================================

echo "[CHECK 1] Sample count"
wc -l pca_results.eigenvec

# Expected:
# 3810 samples
# (3202 from 1000G + 608 study samples)

# ============================================================

echo "[CHECK 2] Eigenvalue preview"
head pca_results.eigenval

# Observed:
# 275.854
# 133.321
# 50.101
# 31.8443
# ...

# Interpretation:
# PC1 >> PC2 >> PC3 → strong population structure

# ============================================================

echo "[CHECK 3] Variance explained (%)"

TOTAL_VAR=$(awk '{s+=$1} END{print s}' pca_results.eigenval)

awk -v total="$TOTAL_VAR" '{
  printf "PC%-2d: %.2f%%\n", NR, ($1/total)*100
}' pca_results.eigenval | head -10

# Observed:
# PC1 : 50.74%
# PC2 : 24.52%
# PC3 : 9.22%
# PC4 : 5.86%
# PC5 : 0.94%
# ...

# Interpretation:
# PC1 + PC2 ≈ 75% → major ancestry axes captured
# Strong continental-level separation

# ============================================================

echo "[CHECK 4] PC1 / PC2 range"

awk 'NR>1 {print $3}' pca_results.eigenvec | sort -n | \
awk 'NR==1{min=$1} {max=$1} END{print "PC1 range:", min, "to", max}'

awk 'NR>1 {print $4}' pca_results.eigenvec | sort -n | \
awk 'NR==1{min=$1} {max=$1} END{print "PC2 range:", min, "to", max}'

# Observed:
# PC1 range: ~ -0.00009 to 0.032
# PC2 range: ~ 0 to 0.034

# Interpretation:
# - Values are small (expected for normalized PCA)
# - Non-zero spread confirms valid structure
# - No numerical collapse

# ============================================================

echo "[CHECK 5] Sample ID preview"
head pca_results.eigenvec

# Observed:
# HG00096, HG00097, ...

# Interpretation:
# - 1000G reference samples present (HG/NA IDs)
# - Study samples present alongside → merge successful

# ============================================================

echo "[FINAL STATUS]"

# Dataset summary:
# - 3810 samples total
# - ~57,337 LD-pruned SNPs
# - PCA computed on merged dataset (study + 1000G)

# Scientific conclusion:
# - PCA is valid and stable
# - Major ancestry axes captured (PC1, PC2)
# - Dataset ready for visualization and interpretation

echo "[DONE] PCA + validation complete"