
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <EXACT_OUTPUT> <INEXACT_DIR> <DIMENSIONS> <K>"
  exit 1
fi

EXACT_OUTPUT=$1
INEXACT_DIR=$2
DIMENSIONS=$3
K=$4


for i in {1..100}; do
  if ((i % 5 == 0)); then
    python src/compare_knn_results.py $EXACT_OUTPUT $INEXACT_DIR/$i $K >> $INEXACT_DIR/results.txt
  fi
done
