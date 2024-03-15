#! /usr/bin/env python3

import argparse
import collections
import os
import re
import sys

import pandas as pd

from pathlib import Path
from xopen import xopen
from pprint import pprint


def sort_tsv(fo):
    df = pd.read_csv(fo,
                     delimiter='\t',
                     na_values=['na', 'NA'],
                     dtype=str,
                     keep_default_na=True)
    df = df.convert_dtypes()
    df["k"] = df['k'].astype('int')
    #df["d"] = df['d'].astype('int')
    df.sort_values(
        [
            'genome',
            'rate',
            'k',
            'S_alg',
            #'d',
            'pref'
        ],
        inplace=True)
    print(df.to_csv(sep="\t", index=False, na_rep='na'), end="")


def main():

    parser = argparse.ArgumentParser(description="")

    parser.add_argument('input_tsv',
                        nargs='?',
                        type=argparse.FileType('r'),
                        default=sys.stdin)

    args = parser.parse_args()

    sort_tsv(args.input_tsv)


if __name__ == "__main__":
    main()
