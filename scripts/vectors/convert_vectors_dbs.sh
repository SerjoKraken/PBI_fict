#!/bin/sh


# DB FILES SHOULD BE A GROUP OF ANY NUMBER OF FILES
# IN THE SAME DIRECTORY

# The script should be called like this
# ./convert_vectors_dbs.sh <EXECUTABLE> <BIN-DIR> (DB-FILES)
# ./convert_vectors_dbs.sh convertcoords ./binary ./db
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <EXECUTABLE> <BIN-DIR> (DB-FILES) "
  exit 1
fi

# the files are .dat files
# in wanna convert them to .bin
# i need to remove the .dat in the name

EXECUTABLE=$1
BIN_DIR=$2

shift 2
for file in $@; do
  echo "Converting $file"
  bin_file="${file##*/}"
  bin_file="${bin_file%.dat}.bin"
  $EXECUTABLE $file $BIN_DIR/$bin_file
  echo "Saving as $BIN_DIR/$bin_file"
done
