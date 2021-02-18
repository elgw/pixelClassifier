#include "mex.h"
#include <math.h>
#include "trees.c"

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{


  int verbosive = 1;
  int weighted = 0;

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

  plhs[0] = mxCreateNumericArray(2,  Cdim, mxDOUBLE_CLASS, mxREAL);
  double * C = (double *) mxGetPr(plhs[0]);

  size_t nPixels = Fdim[1];
  for(size_t kk = 0; kk<nPixels; kk++)
  {
      C[kk] = (double) round( tree_class(F + kk*Fdim[0]));
  }

}
