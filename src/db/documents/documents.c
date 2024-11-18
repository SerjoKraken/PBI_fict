
#include "documents.h"
#include <stdlib.h>
#include <string.h>

DB db;

double tfdf(char *f1, char *f2) {
  double sum, norm1, norm2;
  FILE *g;
  Vocab *w1, *w2;
  uint n1, n2, i ,j;
  struct stat sdata;
  char *fname1, *fname2;

  fname1 = malloc(strlen(db.dirname) + strlen(f1));
  fname2 = malloc(strlen(db.dirname) + strlen(f2));

  sprintf(fname1, "%s/%s", db.dirname, f1);
  sprintf(fname2, "%s/%s", db.dirname, f2);

  stat(fname1, &sdata);
  n1 = sdata.st_size;

  stat(fname2, &sdata);
  n2 = sdata.st_size;

  w1 = malloc(n1 * sizeof(*w1));
  w2 = malloc(n2 * sizeof(*w2));

  if (!(g = fopen(fname1, "rb"))) {
    fprintf(stderr, "Error: file %s not found\n", fname1);
    exit(-1);
  }
  i = fread(w1, sizeof(*w1), n1, g);
  fclose(g);

  if (!(g = fopen(fname2, "rb"))) {
    fprintf(stderr, "Error: file %s not found\n", fname2);
    exit(-1);
  }

  j = fread(w2, sizeof(*w2), n2, g);
  fclose(g);
  
  norm1 = norm2 = sum = 0.0;

  for (i = 0; i < n1; i++)
    norm1 += w1[i].w * w1[i].w;

  for (i = 0; i < n2; i++)
    norm2 += w2[i].w * w2[i].w;

  for (i = 0, j = 0; (i < n1) && (j < n2);) {
    if (w1[i].id == w2[j].id) {
      sum += w1[i].w * w2[j].w;
      i++;
      j++;
    }
    else if (w1[i].id < w2[j].id)
      i++;
    else
     j++;
  }

  free(w1);
  free(w2);


  return acos(sum / sqrt(norm1) * sqrt(norm2));
}

float distance(uint u, uint q) {
  return db.dist(db(u), db(q));
}

int openDB(char *dbname) {
  DIR *dptr; // document directory pointer
  struct dirent *dnt; // document directory entry
  uint size, np;
  char *buff; // buffer for document name

  db.dirname = malloc(strlen(dbname) + 1);
  strcpy(db.dirname, dbname);
  db.n = 0;

  if (!(dptr = opendir(dbname))){
    fprintf(stderr, "Error: directory %s not found\n", dbname);
    exit(-1);
  }

  size = 0;
  np = 0;

  while((dnt = readdir(dptr))) {
    if (dnt->d_name[0] == '.') continue;

    size += strlen(dnt->d_name) + 1;
    np++;
  }
  
  rewinddir(dptr);

  db.dnames = malloc(np * sizeof(char *));
  buff = malloc(size);

  while((dnt = readdir(dptr))) {
    if (dnt->d_name[0] == '.') continue;

    strcpy(buff, dnt->d_name);
    db.dnames[db.n++] = buff;
    buff += strlen(buff) + 1;
  }

  closedir(dptr);
  return db.n;
}

void closeDB() {
  free(db.dirname);
  free(db.dnames[0]); // free the buffer
  free(db.dnames);
  db.dnames = NULL;
  db.dirname = NULL;
}

void printObj(int obj) {
  printf("%s\n", db(obj));
}

int parseObj(char *s) {
  int i;
  sscanf(s, "%i", &i);
  return i;
}
