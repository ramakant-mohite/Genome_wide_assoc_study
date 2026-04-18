#!/bin/bash
set -euo pipefail

# Author: Ramakant Mohite
# Purpose: Prepare study dataset for merge with 1000G and PCA
# Tool: PLINK 1.9

INPUT=GSA_COVID_1KGenomes_qc_imputed

echo "[INFO] Checking input files"
ls ${INPUT}.bed ${INPUT}.bim ${INPUT}.fam

# ============================================================
echo "[STEP 1] Retain biallelic SNPs (A/C/G/T only)"
# ============================================================

plink \
  --bfile ${INPUT} \
  --snps-only just-acgt \
  --biallelic-only strict \
  --allow-extra-chr \
  --make-bed \
  --out study_step1_snps \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee study_step1_snps.log

# ============================================================
echo "[STEP 2] Remove strand-ambiguous SNPs (A/T, C/G)"
# ============================================================

awk '($5$6=="AT" || $5$6=="TA" || $5$6=="CG" || $5$6=="GC") && $5!="0" && $6!="0" {print $2}' \
  study_step1_snps.bim > ambiguous_study.snps

plink \
  --bfile study_step1_snps \
  --exclude ambiguous_study.snps \
  --allow-extra-chr \
  --make-bed \
  --out study_step2_clean \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee study_step2_clean.log

# ============================================================
echo "[STEP 3] Remove duplicated SNP IDs (strict)"
# ============================================================

# Rationale:
# - Duplicate rsIDs map to multiple loci
# - PLINK cannot resolve duplicates by ID
# - Must remove all duplicates for safe merging

cut -f2 study_step2_clean.bim | sort | uniq -d > duplicate_study.snps

plink \
  --bfile study_step2_clean \
  --exclude duplicate_study.snps \
  --allow-extra-chr \
  --make-bed \
  --out study_step3_clean \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee study_step3_clean.log

# Verification (must be zero)
echo "[CHECK] Duplicate SNP IDs remaining:"
cut -f2 study_step3_clean.bim | sort | uniq -d | wc -l

# ============================================================
echo "[STEP 4] Restrict to autosomes (chr 1–22)"
# ============================================================

plink \
  --bfile study_step3_clean \
  --chr 1-22 \
  --allow-extra-chr \
  --make-bed \
  --out study_final_clean \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee study_step4_autosomes.log

# ============================================================
# FINAL CHECK
# ============================================================

echo "[CHECK] Chromosomes present:"
cut -f1 study_final_clean.bim | sort | uniq

echo "[CHECK] Non-autosomal chromosomes (expected 0):"
cut -f1 study_final_clean.bim | grep -E 'X|Y|PAR|MT' | wc -l

echo "[DONE] Study dataset cleaning complete"