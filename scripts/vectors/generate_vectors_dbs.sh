#!/bin/sh

# I want the dimensions sizes and functions
# have a -d -s -f options

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <EXECUTABLE> <DB-DIR> [-d <DIMENSIONS>] [-s <SIZES>] [-f <FUNCTION>]"
  exit 1
fi



EXECUTABLE=$1
DB_DIR=$2

DEFAULT_SIZES=(10000 20000)
DEFAULT_DIMENSIONS=(128 256)
DEFAULT_FUNCTION=2


DIMENSIONS=${DEFAULT_DIMENSIONS[@]}
SIZES=${DEFAULT_SIZES[@]}
FUNCTION=$DEFAULT_FUNCTION

shift 2
while getopts "d:s:f:" opt; do
  case $opt in
    d) DIMENSIONS=($OPTARG) ;;
    s) SIZES=($OPTARG) ;;
    f) FUNCTION=($OPTARG) ;;
    *) echo "Invalid option -$OPTARG"; exit 1 ;;
  esac
done

mkdir -p "$DB_DIR"

for size in ${SIZES[@]}; do
  for dimension in ${DIMENSIONS[@]}; do
    DB_PATH="$DB_DIR/${size}v_${dimension}d.dat"

    echo "Generating DB with size=$size, dimension=$dimension and function=$FUNCTION"

    $EXECUTABLE $FUNCTION $dimension $size $DB_PATH

    if [ $? -eq 0 ]; then
      echo "DB generated successfully in $DB_PATH"
    else
      echo "Error generating DB with size=$size, dimension=$dimension"
    fi

  done
done


echo "Done"




