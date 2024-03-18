#include "db.h"
#include "index/index.h"
#include "index/pbi.h"
#include <stdio.h>
#include <stdlib.h>
// #include "index/pbi.h"

//      0           1           2             3           4
// ./index.out <data file> <index name> <n elements> < permutants>

int main(int argc, char *argv[]) {

  char *dataFile = argv[1];

  char *indexFile = argv[2];

  int n = atoi(argv[3]);

  Index index = build(dataFile, n, &argc, &argv);

  saveIndex(index, indexFile);

  return 0;
}
