#!/bin/sh

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <EXECUTABLE> <DB> <INDEX-FILES-DIR> <SIZE> [-p <PERMUTANTS>] [-f <FICTICIOUS>] [-m <METHODS>]"
  exit 1
fi

EXECUTABLE=$1
DB=$2
INDEX_DIR=$3
SIZE=$4

DEFAULT_PERMUTANTS=(128 256)
DEFAULT_FICTICIOUS=(2 4 6 8 10 12)
DEFAULT_METHODS=(0 1)

PERMUTANTS=${DEFAULT_PERMUTANTS[@]}
FICTICIOUS=${DEFAULT_FICTICIOUS[@]}
METHODS=${DEFAULT_METHODS[@]}


shift 4
while getopts "p:f:m:" opt; do
  case $opt in
    d) PERMUTANTS=($OPTARG) ;;
    f) FICTICIOUS=($OPTARG) ;;
    m) METHODS=($OPTARG) ;;
    *) echo "Invalid option -$OPTARG"; exit 1 ;;
  esac
done

mkdir -p "$INDEX_DIR"

db_name=${DB##*/}

for permutant in $PERMUTANTS; do
  for ficticious in $FICTICIOUS; do
    for method in $METHODS; do
      INDEX_PATH="$INDEX_DIR/pbifp_${permutant}p_${ficticious}f_${method}m_db_${db_name}"

      echo "Building index with permutant=$permutant, ficticious=$ficticious, method=$method"

      echo "$EXECUTABLE $DB $INDEX_PATH $SIZE $permutant $ficticious $method"

      $EXECUTABLE $DB $INDEX_PATH $SIZE $permutant $ficticious $method

      if [ $? -eq 0 ]; then
        echo "Index built successfully in $INDEX_PATH"
      else
        echo "Error building with permutant=$permutant, ficticious=$ficticious, method=$method"
      fi

    done
  done
done

echo "PBIFP indexes built successfully"
