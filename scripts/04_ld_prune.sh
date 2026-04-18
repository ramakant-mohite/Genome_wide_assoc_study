#!/bin/bash
set -euo pipefail

# Author: Ramakant Mohite
# Purpose: LD pruning prior to PCA

INPUT=merged_try1   # ← use your actual merged file

echo "[INFO] Checking input files"
ls ${INPUT}.bed ${INPUT}.bim ${INPUT}.fam

# ============================================================
echo "[STEP 1] LD pruning (independent SNP selection)"
# ============================================================

# Rationale:
# - PCA assumes markers are approximately independent
# - LD regions (e.g., HLA) can dominate PCs if not pruned
# - Parameters:
#     window = 200 SNPs
#     step   = 50 SNPs
#     r^2    = 0.2

plink \
  --bfile ${INPUT} \
  --indep-pairwise 200 50 0.2 \
  --out pruned_data \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee pruned_data.log

# ============================================================
echo "[STEP 2] Extract pruned SNP set"
# ============================================================

plink \
  --bfile ${INPUT} \
  --extract pruned_data.prune.in \
  --make-bed \
  --out merged_pruned \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee merged_pruned.log

# ============================================================
# VERIFICATION
# ============================================================

echo "[CHECK] SNPs retained after pruning:"
wc -l pruned_data.prune.in

echo "[CHECK] Final dataset:"
wc -l merged_pruned.bim
wc -l merged_pruned.fam

echo "[DONE] LD pruning complete"