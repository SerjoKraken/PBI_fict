
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <EXACT_OUTPUT> <INEXACT_DIR> <DIMENSIONS> <K>"
  exit 1
fi

EXACT_OUTPUT=$1
INEXACT_DIR=$2
DIMENSIONS=$3
K=$4

PERCENTAGES=(1 2 3 4 5 6 7 8 9 10 15 20 30 40 50)

# rm $INEXACT_DIR/results.txt

for query_file in $@; do
  route_file=$(echo "$query_file" | sed 's/.*\///')
  mkdir -p $OUTPUT_DIR/$route_file
  for i in ${PERCENTAGES[@]}; do
    answer=$(python src/compare_knn_results.py $EXACT_OUTPUT $INEXACT_DIR/$i $K)
    echo $answer
    # echo $answer >> $INEXACT_DIR/results.txt
  done
done
