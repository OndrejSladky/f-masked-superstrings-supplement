# Function-assigned masked superstrings - supplementary materials


## Introduction

Here we provide supplementary materials for the paper *Function-Assigned Masked Superstrings as a Versatile and Compact Data Type for k-Mer Sets*, including the data sets used and experimental pipelines.

### Citation

> Ondřej Sladký, Pavel Veselý, and Karel Břinda: Function-Assigned Masked Superstrings as a Versatile and Compact Data Type for *k*-Mer Sets.
> *bioRxiv* 2024.03.06.583483, 2024. [https://doi.org/10.1101/2024.03.06.583483](https://doi.org/10.1101/2024.03.06.583483)

```
@article {sladky2024-f-masked-superstrings,
	author = {Ond{\v r}ej Sladk{\'y} and Pavel Vesel{\'y} and Karel B{\v r}inda},
	title = {Function-Assigned Masked Superstrings as a Versatile and Compact Data Type for 𝑘-Mer Sets},
	elocation-id = {2024.03.06.583483},
	year = {2024},
	doi = {10.1101/2024.03.06.583483},
	publisher = {Cold Spring Harbor Laboratory},
	URL = {https://www.biorxiv.org/content/early/2024/03/11/2024.03.06.583483},
	eprint = {https://www.biorxiv.org/content/early/2024/03/11/2024.03.06.583483.full.pdf},
	journal = {bioRxiv}
}

```

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
  - not provided in this repository due to file size (ask [@PavelVesely](https://github.com/PavelVesely) if you wish to get this dataset)
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
* *C. elegans* (`NC_003279.8`) - downloaded from [NCBI](https://www.ncbi.nlm.nih.gov)
  - [data/C.elegans.fna.xz](data/C.elegans.fna.xz)
* *C. briggsae* (`NC_013489.2`) - downloaded from [NCBI](https://www.ncbi.nlm.nih.gov)
  - [data/C.briggsae.fna.xz](data/C.briggsae.fna.xz)

For generating negative membership queries to these datasets, we used a 2MB prefix of the FASTA file for chromosome 1 of *H. sapiens* genome (`GRCh38.p14 Primary Assembly`, `NC_000001.11`), downloaded from [NCBI](https://www.ncbi.nlm.nih.gov); see  [data/GRCh38.p14.chromosome1.prefix2M.fasta.xz](data/GRCh38.p14.chromosome1.prefix2M.fasta.xz)


### Reproducing experimental results

After cloning this repository, run the following to download all the dependencies.

```bash 
git submodule update --init
```
After that, CBL, SBWT, BWA, FMSI, KmerCamel, and ProphAsm (the submodules) need to be compiled, as described in each of these repositories.
(We note that CBL need to be compiled for each value of *k* separately.

#### Experimental evaluation of indexing 

Running the experiments on membership queries besides standard Linux programs requires [Snakemake](https://snakemake.readthedocs.io/en/stable/).

First, the datasets evaluated need to be subsampled using script `run_subsampling.sh`, which gets dataset name (without extension .fa.xz) as a parameter. One can specify desired subsampling rates and values of *k* inside `run_subsampling.sh`. This creates compressed FASTA files with subsampled datasets in data/subsampled/. For example, to subsampled the *S. pneumoniae* pan-genome, run the following
```bash
cd scripts
./run_subsampling.sh spneumo_pangenome_k32
```
Furthermore, for generating negative queries, it is required to decompress [data/GRCh38.p14.chromosome1.prefix2M.fasta.xz](data/GRCh38.p14.chromosome1.prefix2M.fasta.xz) into experiments/01_build_and_query_memtime. Then run the experiment using
```bash
cd experiments/01_build_and_query_memtime
make
```
Notes:
- Since the resulting TSV tables are already in the repository, one needs to (re)move them to run the experiments.
- The number of cores provided to Snakemake can be changed in the Makefile (currently we use 4).
- The evaluated values of *k*, subsampling rates *r*, and datasets can all be changed in the [Snakefile](experiments/01_build_and_query_memtime/Snakefile).

#### Maximum memory ratio

In the article we claim that FMSI achieved 1.4-4.5 memory saving compared to SSHash, SBWT, BWA, and CBL on the evaluated datasets.

To reproduce this, run `python3 experiments/01_build_and_query_memtime/analyze_maximum_memory_ratio.py`, which displays minimum, maximum and median values of the ratio across the data for the different algorithms.

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

The data for the figure were taken from the [experiments/01_build_and_query_memtime/99_results/exp_01_build_index_results.tsv](experiments/01_build_and_query_memtime/99_results/exp_01_build_index_results.tsv)

### Fig. 2 - Experiment on set operations

The data for the figure were taken from [experiments/02_set_operations/results-roundworms.csv](experiments/02_set_operations/results-roundworms.csv), computed on *C. elegans* and *C. briggsae* genomes.

### Additional plots

Additional plots for experimental evaluation of membership queries are available in [figures/fig-exp_01_query_memtime/](figures/fig-exp_01_query_memtime/)

## Contact

* Ondřej Sladký (ondra.sladky@gmail.com)
* Pavel Veselý (vesely@iuuk.mff.cuni.cz)
* Karel Břinda (karel.brinda@inria.fr)
