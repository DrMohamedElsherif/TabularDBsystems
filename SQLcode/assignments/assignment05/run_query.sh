#!/bin/bash


## THIS BASH SCRIPT RUNS THE EXECUTABLE VERSION (query_mmap_t) OF THE 'query_mmap_threads.c' file (REQUIRED BY EXERCISE01) TO OUTPUT RUNTIME INFORMATION WITHOUT 
## USING THE 'time' COMMAND, AND SAVES OUTPUT AS .tsv FILE IN 'outputfiles' FOLDER AT 'assignment05/outputfiles/exercise01'.
## e.g usage (./run_query.sh 128), where 128 is the T value.

# HINT: 'query_mmap_threads.c file' IS STILL EXECUTABLE ON ITS OWN BUT WILL NEED 'time' COMMAND TO OBTAIN THE RUNTIME VALUES. 
# THE query_mmap_threads.c TAKES THREAD NUMBER (T) AS ARGUMENT.
#  e.g usage (time ./query_mmap_t resources/lineitem.csv 128), where 128 is the T value.


CSV_FILE="resources/lineitem.csv"
OUTPUT_DIR="outputfiles/exercise01"
OUTPUT_FILE="$OUTPUT_DIR/timing_results.tsv"  # This will save runs output for plotting later in python for visualization

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

THREADS=$1
if [ -z "$THREADS" ]; then
  echo "Usage: $0 <num_threads>"
  exit 1
fi

# Initialize file
if ! awk 'NR==2 && $1 == 1' "$OUTPUT_FILE" >/dev/null 2>&1; then
  echo -e "Threads\tRuntime\tSpeedup\tEfficiency" > "$OUTPUT_FILE"
  BASELINE=$( { /usr/bin/time -p ./query_mmap_t "$CSV_FILE" 1; } 2>&1 | awk '/real/ {print $2}' )
  echo -e "1\t$BASELINE\t1.0\t1.0" >> "$OUTPUT_FILE"
else
  BASELINE=$(awk 'NR==2 {print $2}' "$OUTPUT_FILE")
fi

# This takes the query_mmap_t.c file (required by the Assignment) and run it with enhanced output
# HINT: query_mmap_t.c file is executable on its own also. but will need the time command and 
# supports entering the thread number as an argument.
RUNTIME=$( { /usr/bin/time -p ./query_mmap_t "$CSV_FILE" "$THREADS"; } 2>&1 | awk '/real/ {print $2}' )
SPEEDUP=$(awk "BEGIN {print $BASELINE / $RUNTIME}")
EFFICIENCY=$(awk "BEGIN {print $SPEEDUP / $THREADS}")

echo -e "$THREADS\t$RUNTIME\t$SPEEDUP\t$EFFICIENCY" >> "$OUTPUT_FILE"
echo "Logged: Threads=$THREADS | Runtime=${RUNTIME}s | Speedup=$SPEEDUP | Efficiency=$EFFICIENCY"

#### Implementation is inspired from the BASHing course of Prof Dr. Martin Raden, Uni-Tübingen. ####