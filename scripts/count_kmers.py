#! /usr/bin/env python3

import argparse
import collections
import functools
import itertools
import logging as G
import os
import re
import sys
import subprocess

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


_nucl_to_num = {'A': 0, 'C': 1, 'G': 2, 'T': 3}


def _kmer_to_num(kmer):
    s = 0
    for i, x in enumerate(kmer.upper()):
        s *= 4
        s += _nucl_to_num[x]
    return s


def encode_kmer(kmer):  # canonical representation
    v1 = _kmer_to_num(kmer)
    v2 = _kmer_to_num(rc(kmer))
    #print(v1, v2)
    return min(v1, v2)


def count_kmers(maskedSuperstring, k):
    K = set()  # set of canonical k-mers

    # first pass - collecting k-mers
    for i in range(len(maskedSuperstring) - k + 1):
        if maskedSuperstring[i].isupper():
            Q = maskedSuperstring[i:i + k].upper()
            Qnum = encode_kmer(Q)
            K.add(Qnum)
            #this works even for tail, short k-mers aren't in K nms.append(maskedSuperstring[i].lower())
    count = len(K)
    return count


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
        '-t',
        action='store_true',
        dest='textFile',
        default=False,
        help=
        'input and output are text files with the masked superstring only (input can be split into more lines)',
    )

    parser.add_argument(
        '-p',
        metavar='superstring.fa[.xz,.gz]',
        dest='fs',
        required=True,
        help='FASTA file with superstring (masked by upper/lower-case letters)',
    )

    args = parser.parse_args()

    G.basicConfig(
        level=G.ERROR,
        format='[%(asctime)s.%(msecs)03d %(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
    )

    # load superstring
    with xopen(args.fs) as fo:
        if args.textFile:  # assuming text file with the masked superstring only (can be split into more lines)
            s = fo.read().replace('\n', '')  # note: assuming UNIX line endings
        else:  # load fasta format
            s = []
            for qname, seq, _ in readfq(fo):
                G.info(f"Appending superstring component {qname}")
                s.append(seq)
            s = "".join(s)
    G.info(f"done loading superstring from {args.fs}")
    #G.info(f"superstring = {s}")

    count = count_kmers(maskedSuperstring=s, k=args.k)
    print(count)
    G.info(f"Finished")


if __name__ == "__main__":
    main()
