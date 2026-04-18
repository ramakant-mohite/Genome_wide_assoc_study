#!/bin/bash
set -e

THREADS=8
MEMORY=80000
INPUT=GSA_COVID_1KGenomes_qc_imputed

echo "========================================"
echo "STEP 2: Study QC (FINAL CLEAN VERSION)"
echo "========================================"

# ------------------------------------------------------------
# Step 1: SNP filtering
# ------------------------------------------------------------
plink --bfile $INPUT \
  --snps-only just-acgt \
  --biallelic-only strict \
  --allow-extra-chr \
  --threads $THREADS \
  --memory $MEMORY \
  --make-bed \
  --out study_step1_snps

# ------------------------------------------------------------
# Step 2: Remove ambiguous SNPs
# ------------------------------------------------------------
awk '{
  a=toupper($5); b=toupper($6);
  if ((a=="A" && b=="T") || (a=="T" && b=="A") || \
      (a=="C" && b=="G") || (a=="G" && b=="C"))
  print $2
}' study_step1_snps.bim > ambiguous.snps

plink --bfile study_step1_snps \
  --exclude ambiguous.snps \
  --allow-extra-chr \
  --threads $THREADS \
  --memory $MEMORY \
  --make-bed \
  --out study_step2_noAmbig

# ------------------------------------------------------------
# Step 3: Remove duplicate rsIDs (AWK)
# ------------------------------------------------------------
awk '!seen[$2]++ {print $2}' study_step2_noAmbig.bim > keep_snps.txt

plink --bfile study_step2_noAmbig \
  --extract keep_snps.txt \
  --allow-extra-chr \
  --threads $THREADS \
  --memory $MEMORY \
  --make-bed \
  --out study_step3_dedup

# ------------------------------------------------------------
# Step 3b: Remove remaining conflicting rsIDs (CRITICAL FIX)
# ------------------------------------------------------------
cut -f2 study_step3_dedup.bim | sort | uniq -d > dup_rsids.txt

plink --bfile study_step3_dedup \
  --exclude dup_rsids.txt \
  --allow-extra-chr \
  --make-bed \
  --out study_step3_final

# ------------------------------------------------------------
# Step 4: Sample QC
# ------------------------------------------------------------
plink --bfile study_step3_final \
  --mind 0.02 \
  --allow-extra-chr \
  --threads $THREADS \
  --memory $MEMORY \
  --make-bed \
  --out study_step4_sampleQC

# ------------------------------------------------------------
# Step 5: Autosomes + MAF
# ------------------------------------------------------------
plink --bfile study_step4_sampleQC \
  --chr 1-22 \
  --maf 0.01 \
  --allow-extra-chr \
  --threads $THREADS \
  --memory $MEMORY \
  --make-bed \
  --out study_final_clean

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------
echo "[QC] Duplicate rsIDs check:"
cut -f2 study_final_clean.bim | sort | uniq -d | wc -l

echo "[QC] Chromosome check:"
cut -f1 study_final_clean.bim | sort | uniq -c

echo "========================================"
echo "FINAL OUTPUT: study_final_clean"
echo "========================================"