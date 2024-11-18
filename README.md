# Towards Efficient k-Mer Set Operations via Function-Assigned Masked Superstrings - supplementary materials

Here we provide supplementary materials for the paper *Towards Efficient k-Mer Set Operations via1
Function-Assigned Masked Superstrings*, including the data sets used and experimental pipelines.

### Citation

> Ondřej Sladký, Pavel Veselý, and Karel Břinda: Towards Efficient *k*-Mer Set Operations via Function-Assigned Masked Superstrings.
> *bioRxiv* 2024.03.06.583483, 2024. [https://doi.org/10.1101/2024.03.06.583483](https://doi.org/10.1101/2024.03.06.583483)

```
@article {sladky2024-f-masked-superstrings,
	author = {Ond{\v r}ej Sladk{\'y} and Pavel Vesel{\'y} and Karel B{\v r}inda},
	title = {Towards Efficient $k$-Mer Set Operations via Function-Assigned Masked Superstrings},
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

* *C. elegans* (`NC_003279.8`) - downloaded from [NCBI](https://www.ncbi.nlm.nih.gov)
  - [data/C.elegans.fna.xz](data/C.elegans.fna.xz)
* *C. briggsae* (`NC_013489.2`) - downloaded from [NCBI](https://www.ncbi.nlm.nih.gov)
  - [data/C.briggsae.fna.xz](data/C.briggsae.fna.xz)



### Reproducing experimental results

After cloning this repository, run the following to download all the dependencies.

```bash 
git submodule update --init
```
After that, CBL, FMSI, and KmerCamel (the submodules) need to be compiled, as described in each of these repositories.
(We note that CBL need to be compiled for each value of *k* separately, for which we provide Bash script `compileCBL.sh`.)

#### Experimental evaluation of set operations

To reproduce the experimental evaluation of set operations, 
decompress [data/C.elegans.fna.xz](data/C.elegans.fna.xz) and [data/C.briggsae.fna.xz](data/C.briggsae.fna.xz) into directory `experiments/set_operations/`
and run the following (it requires to have Jellyfish 2 (v2.2.10) installed)

```bash
cd experiments/set_operations
python3 run_experiments.py
```

The input files can possibly be changed in `run_experiments.py` (variables `file1` and `file2` on lines 7 and 8, resp.). The values of *k* tested can be changed in line 123, and the datasets are specified on line 9.

To evaluate the performance of CBL on the datasets, go to directory `experiments/set_operations` and run `./run_cbl.sh C.briggsae.fna C.elegans.fna <k>`, which generates log files from `/usr/bin/time` on Linux (or `gtime` on the darwin platform)

## Figures

### Fig. 1 - Experiment on set operations

The data for the figure were taken from [experiments/set_operations/results-roundworms.csv](experiments/set_operations/results-roundworms.csv), computed on *C. elegans* and *C. briggsae* genomes.

## Contact

* Ondřej Sladký (ondra.sladky@gmail.com)
* Pavel Veselý (vesely@iuuk.mff.cuni.cz)
* Karel Břinda (karel.brinda@inria.fr)
