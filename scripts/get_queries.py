#! /usr/bin/env python3

import argparse
import collections
import functools
import itertools
#import mmh3
import logging as G
import os
import re
import sys
import random
import math

import time

from pathlib import Path
from xopen import xopen
from pprint import pprint

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


def encode_kmer(kmer):
    #kmer=kmer.upper()
    rc_kmer = rc(kmer)
    if kmer < rc_kmer:
        canonical_kmer = kmer
    else:
        canonical_kmer = rc_kmer
    return canonical_kmer


def get_kmer_set(seq, k):
    kmer_set = set()
    seq = seq.upper()
    seqs = re.split(r'[^ACGT]', seq)
    for x in seqs:
        for i in range(len(x) - k + 1):
            kmer = x[i:i + k]
            h = encode_kmer(kmer)
            kmer_set.add(h)
    return kmer_set


def read_fasta_kmers(fn, k):
    kmers = set()
    with xopen(fn) as fo:
        for qname, seq, _ in readfq(fo):
            kmers |= get_kmer_set(seq, k)
    return list(kmers)


def main():

    parser = argparse.ArgumentParser(description="Reads the input FASTA file, computes its k-mer set (w.r.t. RCs), shuffles it, and outputs a given number of randomly-chosen k-mers.")

    parser.add_argument(
        'fn',
        metavar='input.fa',
        help='',
    )

    parser.add_argument(
        '-k',
        metavar='int',
        dest='k',
        type=int,
        required=True,
        help='kmer size',
    )

    parser.add_argument(
        '-cap',
        metavar='int',
        dest='cap',
        type=int,
        required=False,
        default=0,
        help="cap the number of kmers"
    )

    parser.add_argument(
        '-print_header',
        metavar='bool',
        dest='print_header',
        type=bool,
        required=False,
        default=False,
    )

    parser.add_argument(
        '-print_RC',
        metavar='bool',
        dest='print_RC',
        type=bool,
        required=False,
        default=False,
    )

    parser.add_argument(
        '-e',
        metavar='exclude.fa',
        dest='excl',
        required=False,
        help='FASTA file with k-mers to exclude',
    )

    args = parser.parse_args()

    kmers = read_fasta_kmers(args.fn, args.k)
    if args.excl is not None:
        kmersExcl = set(read_fasta_kmers(args.excl, args.k))
        kmers = [kmer for kmer in kmers if kmer not in kmersExcl]
    random.seed(42)
    random.shuffle(kmers)
    if args.cap > 0:
        if len(kmers) < args.cap:
            kmers = kmers * math.ceil(args.cap / len(kmers))
        kmers = kmers[:args.cap]

    i = 0
    for x in kmers:
        if args.print_header:
            print(f">{i}")
            i += 1
        print(x)
        if args.print_RC:
            if args.print_header:
                print(f">{i}")
                i += 1
            print(rc(x))



if __name__ == "__main__":
    main()
