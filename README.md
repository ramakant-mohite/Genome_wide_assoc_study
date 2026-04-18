# Ancestry PCA Pipeline (COVID-19 GWAS Study)

## Overview

This repository contains a reproducible implementation of the ancestry PCA workflow used in our COVID-19 genetic study.

The pipeline has been reconstructed step-by-step to make it easier to understand, reuse, and adapt for similar GWAS projects, while preserving the core analytical logic of the original study.

The goal is to:

* place study samples in a global ancestry context
* detect potential outliers
* generate principal components for GWAS correction

---

## Study context

India remains underrepresented in global genomic studies. In our work, we investigated whether population-specific genetic variation contributes to COVID-19 severity and outcomes, and how the choice of reference panel influences GWAS resolution.

This repository reflects the ancestry analysis component of:

**Kaushik, Mohite et al., 2026**
*PLOS Neglected Tropical Diseases*
https://doi.org/10.1371/journal.pntd.0014020

---

## Important note

This is a **reproducible implementation** of the ancestry PCA workflow used in the study, with minor simplifications for clarity.

* The core analytical steps and logic are preserved
* Some implementation details have been streamlined for usability
* The aim is transparency and reproducibility, not exact byte-level replication

---

## Data availability

All data used in this workflow are publicly available:

* Study dataset: https://doi.org/10.6084/m9.figshare.29650937
* 1000 Genomes reference (PLINK format):
  https://www.cog-genomics.org/plink/2.0/resources

Raw genotype files are not included due to size constraints.

---

## Pipeline overview

```text
1000 Genomes + Study data
        ↓
SNP filtering (biallelic, A/C/G/T only)
        ↓
Removal of ambiguous SNPs (A/T, C/G)
        ↓
Removal of duplicate variants
        ↓
Autosomal filtering (chr 1–22)
        ↓
SNP intersection (rsID-based)
        ↓
Merge with 1000 Genomes
        ↓
LD pruning
        ↓
PCA computation (joint PCA)
        ↓
Visualization
```

---

## PCA plot

Principal component analysis (PC1 vs PC2) showing study samples in the context of global populations from the 1000 Genomes Project.

<p align="center">
  <img src="plots/PCA.png" width="500">
</p>

---

## Methodological note

Principal component analysis (PCA) is performed **jointly** on the combined dataset of study samples and 1000 Genomes reference individuals.

This approach is standard in GWAS and is sufficient for:

* identifying global ancestry structure
* detecting population outliers
* generating covariates for association analysis

Projection-based PCA (where study samples are projected onto fixed reference PCs) was not used here, but may be explored in future work.

---

## PCA interpretation

The PCA reveals clear global population structure consistent with reference populations from the 1000 Genomes Project.

* PC1 (~50%) separates African populations from non-African populations
* PC2 (~24%) captures Eurasian population structure

Study samples cluster predominantly with the South Asian (SAS) super-population, indicating expected ancestry for the cohort.

A slight spread toward European populations is observed, consistent with known admixture patterns in Indian populations. No distinct population outliers were observed.

---

## Why these steps matter

Each preprocessing step addresses a specific issue in genomic data:

* **Ambiguous SNPs (A/T, C/G)** → can cause strand mismatches during merging
* **Duplicate variants** → removed to ensure consistent SNP representation across datasets (this may slightly reduce marker density but does not affect overall population structure)
* **LD pruning** → ensures PCA reflects genome-wide structure rather than local linkage patterns
* **Joint analysis with 1000 Genomes** → enables biological interpretation of ancestry clusters

---

## Running the pipeline

```bash
bash scripts/01_1000G_qc.sh
bash scripts/02_study_qc.sh
bash scripts/03_merge.sh
bash scripts/04_ld_prune.sh
bash scripts/05_pca.sh
Rscript scripts/06_plot_pca.R
```
See docs/metadata.md for preparing population labels.

Each script includes inline comments explaining both the commands and the reasoning behind them.

---

## Output

* PCA coordinates (`.eigenvec`, `.eigenval`)
* PCA plot
  → `plots/PCA.png`

---

## Downstream use

The top principal components (PC1–PC10) are used as covariates in GWAS to correct for population stratification.

---

## Scope of this repository

This repository focuses on:

* ancestry inference
* PCA-based population structure

Association analysis (GWAS) and within-cohort PCA are handled separately.

---

## Author

Ramakant Mohite
