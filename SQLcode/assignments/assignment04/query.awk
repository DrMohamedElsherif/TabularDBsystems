#!/bin/sh

gawk -F'|' \
     'BEGIN  { min = "" }
      $1 < 2000000 { current = $5 + 0;
                     if (min == "" || current < min) min = current }
      END    { print min }' \
     "$1"