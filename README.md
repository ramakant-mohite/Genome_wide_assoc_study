# Ancestry PCA Pipeline (COVID-19 GWAS Study)

## Overview

This repository provides a reproducible implementation of the ancestry principal component analysis (PCA) workflow used in a COVID-19 GWAS.

### Objectives

- Place study samples within a global ancestry framework
- Identify population outliers
- Generate principal components for GWAS covariate adjustment

<h2>PCA Plot</h2>

<p>PCA plot (PC1 vs PC2):</p>

<img src="./plots/PCA.png" width="600">

---

## Study Context

India remains underrepresented in large-scale genomic studies. This work investigates whether population-specific genetic variation contributes to COVID-19 severity and evaluates how reference panel choice influences GWAS resolution.

Kaushik, Mohite et al., 2026
PLOS Neglected Tropical Diseases
https://doi.org/10.1371/journal.pntd.0014020

---

## Reproducibility Note

- Designed for methodological reproducibility (not byte-level replication)
- Core analytical logic preserved
- Minor simplifications for usability
- Outputs may vary across software versions

---

## Data Availability

- Study dataset: https://doi.org/10.6084/m9.figshare.29650937
- 1000 Genomes reference (PLINK format):
  https://www.cog-genomics.org/plink/2.0/resources

---

## Pipeline Overview

1000 Genomes + Study data
↓
Variant filtering (biallelic SNPs; A/C/G/T only)
↓
Removal of strand-ambiguous SNPs (A/T, C/G)
↓
Duplicate variant removal
↓
Autosomal filtering (chr 1–22)
↓
SNP intersection (rsID-based)
↓
Dataset merging
↓
LD pruning
↓
PCA computation (joint analysis)
↓
Visualization

---

## PCA Strategy

PCA is performed jointly on the merged dataset of study samples and 1000 Genomes reference individuals.

- Global ancestry inference
- Detection of population outliers
- Generation of covariates for association models

Projection-based PCA is not implemented but can be incorporated if required.

---

## PCA Interpretation

- PC1 (~50%) separates African vs non-African populations
- PC2 (~24%) captures Eurasian structure

Study samples cluster predominantly within the South Asian (SAS) super-population.

A minor shift toward European clusters is observed, consistent with known admixture patterns in South Asian populations. No discrete outliers are evident.

---

## Variance Explained

Scree plot available at:
./plots/PCS_scree.png

---

## Rationale for Preprocessing Steps

- Strand-ambiguous SNPs (A/T, C/G) prevent allele alignment errors
- Duplicate variants ensure consistent SNP representation
- LD pruning removes local correlation structure
- Joint PCA with reference panel enables biological interpretation

---

## Running the Pipeline

bash scripts/01_1000G_qc.sh
bash scripts/02_study_qc.sh
bash scripts/03_merge.sh
bash scripts/04_ld_prune.sh
bash scripts/05_pca.sh
Rscript scripts/06_pca_plot.R

Metadata preparation:
docs/metadata.md

---

## Outputs

- PCA coordinates: .eigenvec, .eigenval
- Plots:
  plots/PCA.png
  plots/PCS_scree.png

---

## Author

Ramakant Mohite
