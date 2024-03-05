#! /usr/bin/env python3

import argparse
import collections
import functools
import itertools
import logging as G
import os
import random
import re
import sys
import subprocess

from pathlib import Path
from xopen import xopen
from pprint import pprint

random.seed(42)

c = {
    "A": "T",
    "C": "G",
    "G": "C",
    "T": "A",
}


def rc(kmer):
    rc_kmer = "".join([c[x] for x in kmer[::-1]])
    return rc_kmer


def readfq(fp):  # this is a generator function
    # From https://github.com/lh3/readfq/blob/master/readfq.py
    last = None  # this is a buffer keeping the last unprocessed line
    while True:  # mimic closure; is it a bad idea?
        if not last:  # the first record or a record following a fastq
            for l in fp:  # search for the start of the next record
                if l[0] in '>@':  # fasta/q header line
                    last = l[:-1]  # save this line
                    break
        if not last: break
        name, seqs, last = last[1:].partition(" ")[0], [], None
        for l in fp:  # read the sequence
            if l[0] in '@+>':
                last = l[:-1]
                break
            seqs.append(l[:-1])
        if not last or last[0] != '+':  # this is a fasta record
            yield name, ''.join(seqs), None  # yield a fasta record
            if not last: break
        else:  # this is a fastq record
            seq, leng, seqs = ''.join(seqs), 0, []
            for l in fp:  # read the quality
                seqs.append(l[:-1])
                leng += len(l) - 1
                if leng >= len(seq):  # have read enough quality
                    last = None
                    yield name, seq, ''.join(seqs)
                    # yield a fastq record
                    break
            if last:  # reach EOF before reading enough quality
                yield name, seq, None  # yield a fasta record instead
                break


_nucl_to_num = {'A': 0, 'C': 1, 'G': 2, 'T': 3}


def encode_kmer(kmer):  # canonical representation
    return min(kmer, rc(kmer))


def subsample_kmers(fn, k, sampling_rate):
    K = set()  # set of canonical k-mers

    with xopen(fn) as fo:
        for name, seq, _ in readfq(fo):
            for i in range(len(seq) - k + 1):
                Q = seq[i:i + k].upper()
                Qenc = encode_kmer(Q)
                K.add(Qenc)

    p = max(int(sampling_rate * len(K)), 1)
    G.info(f"Found {len(K)} kmers for k={k}")
    G.info(
        f"The sampling rate {sampling_rate} corresponds to {p} subsampled kmers"
    )
    l = random.sample(sorted(list(K)), p)
    #l.sort()
    for i, Q in enumerate(l, 1):
        print(f">{i}")
        print(f"{Q}")


def main():

    parser = argparse.ArgumentParser(
        description="Count k-mers in a masked superstring")

    parser.add_argument(
        '-k',
        metavar='int',
        dest='k',
        type=int,
        required=True,
        help='kmer size',
    )

    parser.add_argument(
        '-r',
        metavar='float',
        type=float,
        dest='r',
        required=True,
        help='Sampling rate',
    )

    parser.add_argument(
        'fasta',
        metavar="input.fa[.xz]",
        help='Input fasta file',
    )

    args = parser.parse_args()

    G.basicConfig(
        level=G.INFO,
        format='[%(asctime)s.%(msecs)03d %(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
    )

    G.info(f"Started")

    subsample_kmers(args.fasta, args.k, args.r)

    G.info(f"Finished")


if __name__ == "__main__":
    main()
