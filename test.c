#include <stdio.h>
#include <stdlib.h>

#include "trees.c"

int main(int argc, char ** argv)
{
    size_t Nvectors = 1000;
    if(argc == 2)
    {
        Nvectors = atol(argv[1]);
    }

    size_t Nvars = 50;

    printf("%zu vectors with %zu variables\n", Nvectors, Nvars);
    double * X = malloc(Nvectors*Nvars*sizeof(double));
for(size_t kk = 0; kk < Nvectors*Nvars; kk++)
 {
     X[kk] = (double) rand() / (double) RAND_MAX;
 }

double avg_class = 0;
for(size_t kk = 0; kk< Nvectors; kk++)
 {
     avg_class += tree_class(X + kk*Nvars);
 }
printf("Average class: %f\n", avg_class / (double) Nvectors);

}
