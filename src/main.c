#include <stdio.h>
#include <stdlib.h>
#include "db.h"
#include "index/index.h"
#include "index/pbi.h"
#include "string.h"

int main(int argc, char *argv[]) {
  // atoi
  // atof
  // atol
  // atod
  // atoll
  // strtod


  Index index = build("vectors.ascii", atoi(argv[1]), &argc, &argv);

  printf("Index built\n");

  printf("nnums %d\n", ((fileHeader*)index)->n);
  printPBI();

  saveIndex(index, "index.bin");

  return 0;
}
