#include "index/index.h"
// #include "index/pbi/pbi.h"
#include <stdio.h>
#include <stdlib.h>

//      0           1           2             3           4
// ./index <data file> <index name> <n elements> < permutants>
// program name, data file, index name (output), n elements, permutants
//
// argv[0] = ./index.out
// argv[1] = <data file>
// argv[2] = <index name>
// argv[3] = <n elements>
// argv[4] = <permutants>
// argv[5] = <ficticious permutants> (optional)
// argv[6] = <method>

int main(int argc, char *argv[]) {

  if (argc < 4) {
    fprintf(stderr, "Usage: %s <dbname> <indexfile> <size> <permutants> \n",
            argv[0]);
    exit(1);
  }

  char *dbname = argv[1];
  char *indexFile = argv[2];
  int n = atoi(argv[3]);

  Index index = build(dbname, n, &argc, &argv);

  saveIndex(index, indexFile);
  freeIndex(index, false);

  return 0;
}
