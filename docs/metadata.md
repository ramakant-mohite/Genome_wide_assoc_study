```markdown
# Generation of 1000 Genomes Population Metadata

## Overview

To enable interpretation of principal component analysis (PCA), population labels for the 1000 Genomes reference samples were derived from the accompanying sample metadata file (`hg38_corrected.psam`). These labels allow assignment of continental ancestry groups to reference individuals and contextualization of study samples within PCA space.

The final output file:

```

1000G_pop.txt

```

contains:
- `IID` — sample identifier  
- `SuperPop` — continental ancestry (AFR, AMR, EAS, EUR, SAS)  
- `Pop` — subpopulation (e.g., GBR, YRI)

---

## Input data

```

hg38_corrected.psam

```

This file contains sample-level annotations. A representative structure is:

```

#IID    PAT MAT SEX SuperPop Population
HG00096 0   0   1   EUR      GBR

````

---

## Method

Population labels were extracted directly from the `.psam` file using column-based parsing.

### Step 1 — Extract relevant columns

```bash
awk 'NR>1 {print $1, $5, $6}' hg38_corrected.psam > 1000G_pop.txt
````

* `NR>1` skips the header
* `$1` → IID
* `$5` → SuperPop
* `$6` → Population

---

### Step 2 — Add header

```bash
sed -i '1iIID\tSuperPop\tPop' 1000G_pop.txt
```

---

## Output format

```
IID    SuperPop    Pop
HG00096    EUR    GBR
HG00097    EUR    GBR
```

---

## Validation

### Sample count

```bash
wc -l 1000G_pop.txt
```

Expected:

```
3203
```

(3202 samples + header)

---

### Unique populations

```bash
tail -n +2 1000G_pop.txt | cut -f2 | sort | uniq
```

Expected:

```
AFR
AMR
EAS
EUR
SAS
```

---

### Missing values

```bash
awk '$2=="" || $3==""' 1000G_pop.txt | wc -l
```

Expected:

```
0
```

---

## Usage in PCA

The metadata file is merged with PCA output:

```r
meta <- read.table("data/metadata/1000G_pop.txt", header=TRUE)
df <- merge(pca, meta, by="IID", all.x=TRUE)

df$Group <- ifelse(is.na(df$SuperPop), "STUDY", df$SuperPop)
```

* 1000G samples → labeled by ancestry
* Study samples → labeled as `STUDY`

---
