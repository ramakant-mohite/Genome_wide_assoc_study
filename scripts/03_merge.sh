#!/bin/bash
set -euo pipefail

# Author: Ramakant Mohite
# Purpose: Prepare merged dataset (initial merge only)

echo "[INFO] Checking input files"
ls 1000G_final_clean.bed 1000G_final_clean.bim 1000G_final_clean.fam
ls study_final_clean.bed study_final_clean.bim study_final_clean.fam

# ============================================================
echo "[STEP 1] Identify common SNPs (rsID intersection)"
# ============================================================

cut -f2 1000G_final_clean.bim | sort > snps_1000G.txt
cut -f2 study_final_clean.bim | sort > snps_study.txt

comm -12 snps_1000G.txt snps_study.txt > common.snps

echo "[INFO] Common SNP count:"
wc -l common.snps

# ============================================================
echo "[STEP 2] Extract shared SNPs"
# ============================================================

plink \
  --bfile 1000G_final_clean \
  --extract common.snps \
  --make-bed \
  --out 1000G_common \
  --threads 8 \
  --memory 90000

plink \
  --bfile study_final_clean \
  --extract common.snps \
  --make-bed \
  --out study_common \
  --threads 8 \
  --memory 90000

# ============================================================
echo "[STEP 3] Initial merge (no correction yet)"
# ============================================================

# Note:
# - This step may fail due to strand mismatches
# - If it fails, PLINK will generate:
#     merged_try1-merge.missnp

plink \
  --bfile 1000G_common \
  --bmerge study_common \
  --make-bed \
  --out merged_try1 \
  --threads 8 \
  --memory 90000 || true

echo "[INFO] Merge attempt complete"

# ============================================================
# POST-MERGE CHECK
# ============================================================

wc -l merged_try1.bim
wc -l merged_try1.fam

if [ -f merged_try1-merge.missnp ]; then
  echo "[WARNING] Merge incomplete"
  echo "[INFO] Problematic SNPs listed in: merged_try1-merge.missnp"
else
  echo "[SUCCESS] Merge completed without mismatches"
fi