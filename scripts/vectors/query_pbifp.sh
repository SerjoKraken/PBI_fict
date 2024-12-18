#!/bin/sh

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <EXECUTABLE> <INDEX_FILE> <OUTPUT_DIR> (QUERY_FILES)"
  exit 1
fi

EXECUTABLE=$1
INDEX_FILE=$2
OUTPUT_DIR=$3

PERCENTAGES=(1 2 3 4 5 6 7 8 9 10 15 20 30 40 50)

mkdir -p $OUTPUT_DIR

shift 3

for query_file in $@; do
  route_file=$(echo "$query_file" | sed 's/.*\///')
  mkdir -p $OUTPUT_DIR/$route_file
  for i in ${PERCENTAGES[@]}; do
      echo "Running $EXECUTABLE $INDEX_FILE $(echo "scale=2; $i / 100" | bc) < $query_file > $OUTPUT_DIR/$query_file/$i"
      # In the output stream, we have to take the specific file name of the query file
      $EXECUTABLE $INDEX_FILE $(echo "scale=2; $i / 100" | bc) < $query_file > $OUTPUT_DIR/$route_file/$i
  done
done


