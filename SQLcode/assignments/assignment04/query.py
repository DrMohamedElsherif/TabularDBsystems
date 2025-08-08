#!/usr/bin/env python3

import sys

min_val = None

with open(sys.argv[1], 'r') as file:
    for line in file:
        columns = line.split('|')
        if int(columns[0]) < 2000000:
            current = int(columns[4])
            if min_val is None or current < min_val:
                min_val = current

print(min_val)