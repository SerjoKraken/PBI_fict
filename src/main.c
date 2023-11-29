#include <stdio.h>
#include <stdlib.h>
#include "db.h"
#include "index/pbi.h"

int main(int argc, char *argv[]) {
  // atoi
  // atof
  // atol
  // atod
  // atoll
  // strtod
  Index index = build("vectors.ascii", 100, &argc, &argv);

  printf("Index built\n");

  printf("nnums %d\n", ((fileHeader*)index)->n);

  return 0;

}
