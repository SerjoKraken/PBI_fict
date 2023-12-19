#include <stdio.h>
#include <stdlib.h>
// #include "db.h"
// #include "index/index.h"
#include "db.h"
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


  saveIndex(index, "index.bin");

  return 0;
}
