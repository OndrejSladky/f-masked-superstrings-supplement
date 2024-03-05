#! /bin/bash

set -e
set -o pipefail
set -u

export OUTPUT_DIR="../../data/subsampled/"
mkdir -p $OUTPUT_DIR

GENOME=$1

function subsample {
    k="$2"
    r="$3"
    g="$1"
    if [ -f ${OUTPUT_DIR}${g}_subsampled_k${k}_r${r}.fa.xz ]; then
        echo "${OUTPUT_DIR}${g}_subsampled_k${k}_r${r}.fa.xz already exists"
        return
    fi
	echo "running subsampling for g=$g, k=$k, r=$r"
	./subsample_kmers.py -k $k -r $r ../../data/${g}.fa.xz \
		| pv -l \
		| xz -9 -T1 \
		> ${OUTPUT_DIR}${g}_subsampled_k${k}_r${r}.fa.xz
    echo "created ${OUTPUT_DIR}${g}_subsampled_k${k}_r${r}.fa.xz"
}

export -f subsample

s=""
for kk in {9..23..2}
do
    ## the first rate is effectively just one, randomly chosen k-mer
	for rr in "0.001" "0.01" "0.1" "0.2" "0.3" "0.4" "0.5" "0.6" "0.7" "0.8" "0.9" # PV: omitting very small rates: "0.000000001" "0.0001"  "0.05" 
    do
		s+="$kk\n$rr\n"
	done
    if [ ! -e "${OUTPUT_DIR}${GENOME}_subsampled_k${kk}_r1.0.fa.xz" ]; then
        ln -s ../../data/${GENOME}.fa.xz "${OUTPUT_DIR}${GENOME}_subsampled_k${kk}_r1.0.fa.xz" 2>/dev/null && echo "created ${OUTPUT_DIR}${GENOME}_subsampled_k${kk}_r1.0.fa.xz"
    fi
done
# add 31
for rr in "0.001" "0.01" "0.1" "0.2" "0.3" "0.4" "0.5" "0.6" "0.7" "0.8" "0.9" # PV: omitting very small rates: "0.000000001" "0.0001"  "0.05" 
do
	s+="31\n$rr\n"
done
if [ ! -e "${OUTPUT_DIR}${GENOME}_subsampled_k31_r1.0.fa.xz" ]; then
	ln -s ../../data/${GENOME}.fa.xz "${OUTPUT_DIR}${GENOME}_subsampled_k31_r1.0.fa.xz" 2>/dev/null && echo "created ${OUTPUT_DIR}${GENOME}_subsampled_k31_r1.0.fa.xz"
fi

#echo "s=$s"

printf $s \
	| parallel --max-args=2 -j10 subsample $GENOME
