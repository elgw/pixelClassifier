#include "mex.h"
#include <math.h>
#include "trees.c"
#include <assert.h>

#define useThreads

#ifdef useThreads
#include <pthread.h>
#endif

typedef struct {
    int thread;
    int nthreads;
    double * C;
    double * F;
    size_t nPixels;
    size_t nFeatures;
} TData;

void * th_tree_class( void * data )
{
    TData * tdata = (TData *) data;
    int thread = tdata->thread;
    int nthreads = tdata->nthreads;
    double * C = tdata->C;
    double * F = tdata->F;
    size_t nPixels = tdata->nPixels;
    size_t nFeatures = tdata->nFeatures;

    size_t first = thread * nPixels/nthreads;
    size_t last = (thread+1) * nPixels/nthreads;

    //for(size_t kk = thread; kk < nPixels; kk += nthreads)
    for(size_t kk = first; kk < last; kk++)
    {
        C[kk] = (double) round( tree_class(F + kk*nFeatures));
    }
}

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{


    int verbosive = 0; // For debuggin


  if (nrhs != 1) {
    mexErrMsgTxt("There should be one input, the feature array.");
  }

  if (!(mxIsDouble(prhs[0]))) {
    mexErrMsgTxt("First argument must be of type double.");
  }

  double * F = (double *) mxGetPr(prhs[0]);
  mwSize n_dim_F = mxGetNumberOfDimensions(prhs[0]);
  if(n_dim_F != 2)
  {
      mexErrMsgTxt("The input has to be a 2D matrix.");
  }

  const mwSize * Fdim = mxGetDimensions(prhs[0]);

  // Prepare the output matrix
  mwSize Cdim[] = {0,0};
  Cdim[0] = Fdim[1];
  Cdim[1] = 1;

  if(verbosive) {
    printf("F: %dx%d\n", Fdim[0], Fdim[1]);
    printf("C: %dx%d\n", Cdim[0], Cdim[1]);
  }

  size_t nPixels = Fdim[1];
  size_t nFeatures = Fdim[0];

  plhs[0] = mxCreateNumericArray(2,  Cdim, mxDOUBLE_CLASS, mxREAL);
  double * C = (double *) mxGetPr(plhs[0]);

  #ifndef useThreads
  for(size_t kk = 0; kk<nPixels; kk++)
  {
      C[kk] = (double) round( tree_class(F + kk*nFeatures));
  }
#endif


  #ifdef useThreads

  int nThreads = 8;
  //mexPrintf("Using %d threads\n", nThreads);
  pthread_t * threads = malloc(nThreads*sizeof(pthread_t));
  TData * tdatas = malloc(nThreads*sizeof(TData));

  for(int tt = 0; tt < nThreads; tt++)
  {
      tdatas[tt].C = C;
      tdatas[tt].F = F;
      tdatas[tt].thread = tt;
      tdatas[tt].nthreads = nThreads;
      tdatas[tt].nPixels = nPixels;
      tdatas[tt].nFeatures = nFeatures;
      pthread_create(threads+tt, NULL, th_tree_class, (void *) &tdatas[tt]);
  }

  void * status;
  for(int tt = 0; tt < nThreads; tt++)
  {
      pthread_join(threads[tt], &status);;
  }

  free(threads);
  free(tdatas);
  #endif

}
