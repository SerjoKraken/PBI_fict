#!/bin/sh

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <EXECUTABLE> <DB> <INDEX-FILES-DIR> <SIZE> [-p <PERMUTANTS>]"
  exit 1
fi

EXECUTABLE=$1
DB=$2
SIZE=$3
INDEX_DIR=$4

DEFAULT_PERMUTANTS=(128 256)

PERMUTANTS=${DEFAULT_PERMUTANTS[@]}


shift 4
while getopts "p:" opt; do
  case $opt in
    p) PERMUTANTS=($OPTARG) ;;
    *) echo "Invalid option -$OPTARG"; exit 1 ;;
  esac
done

mkdir -p $INDEX_DIR

db_name=${DB##*/}

echo "Building indexes for $db_name"

for permutant in ${PERMUTANTS[@]}; do
      INDEX_PATH="$INDEX_DIR/pbi_${permutant}p_${db_name}"

      echo "$EXECUTABLE $DB $INDEX_PATH $SIZE $permutant"

      $EXECUTABLE $DB $INDEX_PATH $SIZE $permutant

      if [ $? -eq 0 ]; then
        echo "Index built successfully in $INDEX_PATH"
      else
        echo "Error building with permutants=$permutant"
      fi

done

echo "PBI indexes built successfully"
