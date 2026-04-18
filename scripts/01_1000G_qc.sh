#!/bin/bash
set -euo pipefail

# Author: Ramakant Mohite
# Purpose: Preprocess 1000 Genomes Phase 3 (hg38) for PCA and merging
# Tool: PLINK 1.9

# ============================================================
# INPUT
# ============================================================

INPUT=1000G_hg38

echo "[INFO] Checking input files"
ls ${INPUT}.bed ${INPUT}.bim ${INPUT}.fam

echo "[INFO] Preview BIM (verify hg38 coordinates)"
head ${INPUT}.bim

# ============================================================
echo "[STEP 1] Retain high-quality SNPs (biallelic, A/C/G/T)"
# ============================================================

# Rationale:
# - Remove indels and non-standard variants
# - Restrict to biallelic SNPs for stable PCA and merging

plink \
  --bfile ${INPUT} \
  --snps-only just-acgt \
  --biallelic-only strict \
  --allow-extra-chr \
  --make-bed \
  --out 1000G_step1_snps \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee 1000G_step1_snps.log

# ============================================================
echo "[STEP 2] Remove strand-ambiguous SNPs (A/T, C/G)"
# ============================================================

# Rationale:
# - A/T and C/G SNPs are strand ambiguous (reverse complements)
# - Cannot reliably align across datasets → removed pre-merge

awk '($5$6=="AT" || $5$6=="TA" || $5$6=="CG" || $5$6=="GC") && $5!="0" && $6!="0" {print $2}' \
  1000G_step1_snps.bim > ambiguous.snps

plink \
  --bfile 1000G_step1_snps \
  --exclude ambiguous.snps \
  --allow-extra-chr \
  --make-bed \
  --out 1000G_step2_clean \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee 1000G_step2_clean.log

# ============================================================
echo "[STEP 3] Remove duplicated SNP IDs (strict)"
# ============================================================

# Rationale:
# - 1000G contains duplicated rsIDs mapping to multiple loci
# - PLINK operates on SNP IDs, not row instances
# - ID-based extraction retains all duplicates → incorrect
# - Therefore: remove all duplicated SNP IDs

cut -f2 1000G_step2_clean.bim | sort | uniq -d > duplicate_snps.txt

plink \
  --bfile 1000G_step2_clean \
  --exclude duplicate_snps.txt \
  --allow-extra-chr \
  --make-bed \
  --out 1000G_step3_clean \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee 1000G_step3_clean.log

# Verification: duplicates must be zero
echo "[CHECK] Duplicate SNP IDs remaining:"
cut -f2 1000G_step3_clean.bim | sort | uniq -d | wc -l

# ============================================================
echo "[STEP 4] Restrict to autosomes (chr 1–22)"
# ============================================================

# Rationale:
# - Remove X, Y, PAR, MT to avoid sex-driven PCA structure
# - --allow-extra-chr required (PLINK parses BIM before filtering)

plink \
  --bfile 1000G_step3_clean \
  --chr 1-22 \
  --allow-extra-chr \
  --make-bed \
  --out 1000G_final_clean \
  --threads 8 \
  --memory 90000 \
  2>&1 | tee 1000G_step4_autosomes.log

# ============================================================
# FINAL VERIFICATION
# ============================================================

echo "[CHECK] Variant count:"
wc -l 1000G_final_clean.bim

echo "[CHECK] Chromosomes present:"
cut -f1 1000G_final_clean.bim | sort | uniq

echo "[CHECK] Non-autosomal chromosomes (expected 0):"
cut -f1 1000G_final_clean.bim | grep -E 'X|Y|PAR|MT' | wc -l

echo "[DONE] 1000G preprocessing complete"