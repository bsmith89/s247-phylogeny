#!/usr/bin/env python3

from Bio.AlignIO import read, write
from tqdm import tqdm
import sys
import numpy as np

def contains_none(col, values):
    col_set = set(col)
    val_set = set(values)
    empty_set = set()
    return col_set & val_set == empty_set

def main():
    alignment = read(sys.stdin, 'fasta')
    remove_chars = np.asarray(list(sys.argv[1]))
    length = alignment.get_alignment_length()

    for start in range(length):
        if contains_none(alignment[:,start], remove_chars):
            break

    for end in range(length - 1, -1, -1):
        if contains_none(alignment[:,end], remove_chars):
            break

    out = alignment[:, start:end + 1]
    write(out, sys.stdout, 'fasta')

if __name__ == '__main__':
    main()
