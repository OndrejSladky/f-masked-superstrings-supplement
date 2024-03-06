# Function-assigned masked superstrings - supplementary materials


## Introduction

Here we provide supplementary materials for the paper *Function-Assigned Masked Superstrings as a Versatile and Compact Data Type for $k$-Mer Sets*, including the data sets used and experimental pipelines.

### Citation

TODO

## Methods

### Indexing $f$-masked superstrings - FMSI

Indexing, membership queries, and set operations on $k$-mer sets represented via $f$-masked superstrings
was performed and benchmarked on [FMSI](https://github.com/OndrejSladky/fmsi),
which experimentaly implements membership queries as well as several basic operations on indexed
masked superstrings such as normalization, export and merging, which can be used to perform set operations.


### Used $f$-masked superstrings computed by KmerCamel🐫
To compute the $f$-masked superstrings used for representing the $k$-mer sets, we used [KmerCamel🐫](tps://github.com/OndrejSladky/kmercamel)  (see also the [masked superstrings paper](https://doi.org/10.1101/2023.02.01.526717)).
Specifically we have used the global and local (with $d_{max}=1$) greedy algorithms.

## Experimental evaluation

### Benchmark datasets

* *E. coli* pan-genome, obtained as the union of the genomes from the [661k collection](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.3001421), downloaded from [Phylogenetically compressed 661k collection](https://zenodo.org/records/4602622)
  - *k*-mers were collected and stored in the form of unitigs with $k = 32$ (BCALM 2, version v2.2.3, git commit e57cc46)
  - not provided in this repository due to file size
* *S. pneumoniae* pan-genome - 616 genomes, as provided in [RASE DB *S.
  pneumoniae*](https://github.com/c2-d2/rase-db-spneumoniae-sparc/)
  - *k*-mers were collected and stored in the form of simplitigs (ProphAsm
    v0.1.1, k=32, NS: 158,567, CL: 14,710,895 bp, #kmers: 9,795,318 32-mers)
  - The resulting file:
    [data/spneumo_pangenome_k32.fa.xz](data/spneumo_pangenome_k32.fa.xz)
* *SARS-CoV-2* pan-genome - downloaded from [GISAID](https://gisaid.org/)
  (access upon registration) on Jan 25, 2023 (GISAID version 2023_01_23,
  14,682,066 genomes, 430 Gbp)
  - *k*-mers were collected using JellyFish 2 (v2.2.10, 11,701,570 32-mers) and
    stored in the form of simplitigs (ProphAsm v0.1.1, k=32, NS: 345,866, CL:
    22,423,416 bp, #kmers: 11,701,570 32-mers)
  - The resulting file:
    [data/sars-cov-2_pangenome_k32.fa.xz](data/sars-cov-2_pangenome_k32.fa.xz)
* *C. elegans* (`NC_003279.8`) - downloaded from [NCBI]([https://gisaid.org/](https://www.ncbi.nlm.nih.gov)
  - [data/C.elegans.fna.xz](data/C.elegans.fna.xz)
* *C. briggsae* (`NC_013489.2`) - downloaded from [NCBI]([https://gisaid.org/](https://www.ncbi.nlm.nih.gov)
  - [data/C.briggsae.fna.xz](data/C.briggsae.fna.xz)

### Reproducing expeimental results

After cloning this repository, run the following to download all the dependencies.

```bash 
git submodule update --init
```

#### Experimental evaluation of indexing 

Running the experiments on membership queries besides standard Linux programs requires [Snakemake](https://snakemake.readthedocs.io/en/stable/).

TODO: code to rerun the experiments.

#### Experimental evaluation of set operations

To reproduce the experimental evaluation of set operations, 
decompress [data/C.elegans.fna.xz](data/C.elegans.fna.xz) and [data/C.briggsae.fna.xz](data/C.briggsae.fna.xz) into directory `experiments/02_set_operations/`
and run the following (it requires to have Jellyfish 2 (v2.2.10) installed)

```bash
cd experiments/02_set_operations
python3 run_experiments
```

The input files can possibly be changed in `run_experiments.py` (variables `file1` and `file2` on lines 7 and 8, resp.). The values of *k* tested can be changed in line 118.

## Figures

### Fig. 1 - Comparison on membership queries

The data 

### Fig. 2 - Experiment on set operations

The data for the figure were taken from the [this CSV table](experiments/02_set_operations/results-roundworms.csv), computed on *C. elegans* and *C. briggsae* genomes.

### Additional plots

Additional plots for the experiment with constructing indexes and evaluating membership queries are available in TODO

## Contact

* Ondřej Sladký (ondra.sladky@gmail.com)
* Pavel Veselý (vesely@iuuk.mff.cuni.cz)
* Karel Břinda (karel.brinda@inria.fr)
