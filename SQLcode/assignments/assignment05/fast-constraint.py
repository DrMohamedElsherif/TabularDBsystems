#!/usr/bin/env python3

import sys

CURRENTDATE = '1995-06-17'
LINEITEM = sys.argv[1]

with open(LINEITEM, 'r') as file:
    for line in file:
        fields = line.split('|') # only split one time at beginning!
        receiptdate = fields[12]
        
        # strings can be compared lexicographically
        # (this had the biggest effect on the speed improvement)
        if receiptdate <= CURRENTDATE:
          if fields[8] not in ('R', 'A'): # tuple for faster membership test
            print("TPC-H constraint violated")
            break # early escape if constraint is violated
                  # since we just check IF constraint is violated NOT how many lines violate it 
            
        else:
          # include N check in same line-loop! (halfed the time already)
          if fields[8] != 'N':
            print("TPC-H constraint violated")
            break # same early escape as above
          
    else:
      print("TPC-H constraint satisfied")
  
  
# time logs:

# running: time python constraint.py lineitem.csv
# > TPC-H constraint satisfied
# real    58,03s
# user    57,33s
# sys     0,68s

# running: time python fast-constraint.py lineitem.csv
# real    2.95s
# user    2.80s
# sys     0.14s

# improvement:
# real    94,92% (19x faster)
# user    94,10% (20x faster)
# sys     79,41% (4x faster)
