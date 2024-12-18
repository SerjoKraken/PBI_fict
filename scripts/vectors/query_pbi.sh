#!/bin/sh

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <EXECUTABLE> <INDEX_FILE> <OUTPUT_DIR> <QUERY_FILE> [-p <PERCENTAGE>]"
  exit 1
fi

EXECUTABLE=$1
INDEX_FILE=$2
OUTPUT_DIR=$3
QUERY_FILE=$4

PERCENTAGE=100

PERCENTAGES=(1 2 3 4 5 6 7 8 9 10 15 20 30 40 50)

# shift 4
# while getopts "p:" opt; do
#   case $opt in
#     d) PERMUTANTS=($OPTARG) ;;
#    *) echo "Invalid option -$OPTARG"; exit 1 ;;
#   esac
# done

mkdir -p $OUTPUT_DIR

#percentages should be 1, 2, ..., 10, 11, ..., 100

for i in $(seq 1 $PERCENTAGE); do
  if ((i % 5 == 0)); then
    echo "Running $EXECUTABLE $INDEX_FILE $(echo "scale=2; $i / 100" | bc) < $QUERY_FILE > $OUTPUT_DIR/$i"
    $EXECUTABLE $INDEX_FILE $(echo "scale=2; $i / 100" | bc) < $QUERY_FILE > $OUTPUT_DIR/$i
  fi 
done

