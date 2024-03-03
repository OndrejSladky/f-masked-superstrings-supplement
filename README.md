# Function-assigned masked superstrings - supplementary materials


## Introduction

Here we provide supplementary materials for the paper Function-Assigned Masked Superstrings as a Versatile and Compact Data Type for $k$-Mer Sets, including the used data and pipelines.

### Citation

TODO

## Methods

### Indexing $f$-masked superstrings - FMSI

Indexing, membership queries and set operations on $k$-mer sets represented via $f$-masked superstrings
was performed and benchmarked on [FMSI](https://github.com/OndrejSladky/fmsi),
which experimentaly implements membership queries as well as several basic operations on indexed
masked superstrings such as normalization, export and merging, which can be used to perform set operations.


### Used $f$-masked superstrings computed by KmerCamel🐫
To compute the $f$-masked superstrings used for representing the $k$-mer sets, we used [KmerCamel🐫](tps://github.com/OndrejSladky/kmercamel)  (see also the [masked superstrings paper](https://doi.org/10.1101/2023.02.01.526717)).
Specifically we have used the global and local with $d_{max}=1$ greedy algorithms.

## Experimental evaluation

### Benchmark datasets

TODO

### Reproducing expeimental results

After cloning this repository, run the following to download all the dependencies.

```bash 
git submodule update --init
```

Running the experiments on membership queries besides standard Linux programs requires [Snakemake](https://snakemake.readthedocs.io/en/stable/).

TODO: code to rerun the experiments.

For experiments on set operations, run the following (it requires to have Jellyfish 2 (v2.2.10) installed)

```bash
cd experiments/02_set_operations
python3 run_experiments
```

## Figures

### Fig. 1 - Comparison on membership queries

TODO

### Fig. 2 - Experiment on set operations

The data for the figure were taken from the [this table](experiments/02_set_operations/results.csv)


## Contact

* Ondřej Sladký (ondra.sladky@gmail.com)
* Pavel Veselý (vesely@iuuk.mff.cuni.cz)
* Karel Břinda (karel.brinda@inria.fr)
