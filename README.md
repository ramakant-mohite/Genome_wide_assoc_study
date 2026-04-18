
````md
# Ancestry PCA Pipeline (COVID-19 GWAS Study)

## Overview

This repository provides a reproducible implementation of the ancestry principal component analysis (PCA) workflow used in our COVID-19 GWAS.

The pipeline is reconstructed step-by-step to improve clarity, reusability, and transparency, while preserving the analytical logic of the original study.

**Objectives:**
- Place study samples within a global ancestry framework  
- Identify population outliers  
- Generate principal components for GWAS covariate adjustment  

---

## Study Context

India remains underrepresented in large-scale genomic studies. This work investigates whether population-specific genetic variation contributes to COVID-19 severity and evaluates how reference panel choice influences GWAS resolution.

This repository corresponds to the ancestry analysis component of:

**Kaushik, Mohite et al., 2026**  
*PLOS Neglected Tropical Diseases*  
https://doi.org/10.1371/journal.pntd.0014020  

---

## Reproducibility Note

This implementation is designed for **methodological reproducibility**, not exact byte-level replication.

- Core analytical steps and rationale are preserved  
- Certain implementation details are simplified for usability  
- Outputs may differ slightly due to software versions and parameter tuning  

---

## Data Availability

All datasets used are publicly accessible:

- Study dataset: https://doi.org/10.6084/m9.figshare.29650937  
- 1000 Genomes reference (PLINK format):  
  https://www.cog-genomics.org/plink/2.0/resources  

---

## Pipeline Overview

```text
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
````

---

## PCA Visualization

Principal components (PC1 vs PC2) showing study samples in the context of global populations from the 1000 Genomes Project.

<p align="center">
  <img src="./plots/PCA.png" width="500"/>
</p>

---

## Methodological Framework

PCA is performed **jointly** on the merged dataset of study samples and 1000 Genomes reference individuals.

This approach is standard in GWAS and supports:

* Global ancestry inference
* Detection of population outliers
* Generation of covariates for association models

Projection-based PCA (projection onto fixed reference eigenvectors) is not implemented here but can be incorporated if strict separation between reference and study data is required.

---

## PCA Interpretation

The PCA recapitulates known global population structure:

* **PC1 (~50%)** separates African vs non-African populations
* **PC2 (~24%)** captures Eurasian structure

Study samples cluster predominantly within the **South Asian (SAS)** super-population, consistent with cohort origin.

A mild shift toward European clusters is observed, reflecting known admixture patterns in Indian populations. No discrete outlier samples are evident.

---

## Rationale for Preprocessing Steps

Each preprocessing step mitigates specific technical artifacts:

* **Strand-ambiguous SNPs (A/T, C/G)**
  → Avoid allele alignment errors during merging

* **Duplicate variants**
  → Ensure one-to-one SNP representation across datasets

* **LD pruning**
  → Remove local correlation structure; retain genome-wide signal

* **Joint PCA with reference panel**
  → Enables biological interpretation of clustering

---

## Running the Pipeline

```bash
bash scripts/01_1000G_qc.sh
bash scripts/02_study_qc.sh
bash scripts/03_merge.sh
bash scripts/04_ld_prune.sh
bash scripts/05_pca.sh
Rscript scripts/06_pca_plot.R
```

Metadata preparation (population labels, sample annotation):

```
docs/metadata.md
```

All scripts include inline documentation explaining both command usage and analytical reasoning.

---

## Outputs

* PCA coordinates: `.eigenvec`, `.eigenval`
* Visualization:

  * `plots/PCA.png`
  * `plots/PCS_scree.png`

---

## Author

**Ramakant Mohite**

```
