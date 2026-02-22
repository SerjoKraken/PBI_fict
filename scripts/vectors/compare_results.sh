#!/bin/bash

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <EXACT_DIR> <INEXACT_DIR> <DIMENSIONS> <K>"
  exit 1
fi

EXACT_DIR=$1
INEXACT_DIR=$2
DIMENSIONS=$3
K=$4

PERCENTAGES=(1 2 3 4 5 6 7 8 9 10 15 20 30 40 50)


# Encabezado

for percentage in "${PERCENTAGES[@]}"; do
  sum=0
  count=0

  # Iterar sobre archivos exactos
  for exact_file in "$EXACT_DIR"/*; do
    # Extraer el índice del archivo exacto
    exact_index=$(basename "$exact_file" | grep -o '[0-9]*$')

    # Construir el directorio correspondiente en las inexactas
    query_dir="$INEXACT_DIR/100q_128d_$exact_index"
    percentage_file="$query_dir/$percentage"

    if [ -d "$query_dir" ] && [ -f "$percentage_file" ]; then
      # Ejecutar comparación
      answer=$(python src/compare_knn_results.py "$exact_file" "$percentage_file" "$K")
      # echo "Percentage: $percentage, Exact: $exact_file, Query: $query_dir, Answer: $answer"
      sum=$(echo "$sum + $answer" | bc)
      ((count++))
    else
      echo "Warning: Missing data for Exact: $exact_file, Query: $query_dir, Percentage: $percentage"
    fi
  done

  # Calcular promedio
  if [ "$count" -gt 0 ]; then
    average=$(echo "scale=2; $sum / $count" | bc)
    echo -e "$average"
  else
    echo -e "$percentage\tNo data"
  fi
done
