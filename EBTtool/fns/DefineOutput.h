/* Copyright (c) 1997 by A.M. de Roos. All Rights Reserved                  */

/***
   NAME
     DefineOutput
   PURPOSE
     A wrapper header file for DefineOutput.c
   NOTES
     
   HISTORY
     AMdR - Sep 07, 2007: Last Revision.
     AvdM - August, 2005 Added export of i_state_dim
***/

#ifndef I_STATE_DIM
#error You have to define I_STATE_DIM at the beginning of the source file!
#endif
#ifndef OUTPUT_VAR_NR
#error You have to define OUTPUT_VAR_NR at the beginning of the source file!
#endif

#ifndef DEFINEOUTPUT
#define DEFINEOUTPUT
#include  "math.h"
#include  "stdio.h"
#include  "stdlib.h"
#include  "float.h"

// AvdM050801:
#include "ebttune.h" //for definition of EXTERN_C

typedef	double		*population;


/*==========================================================================*/
/* 
 * Defining macro's for global use in all files
 */

#if defined(DBL_MAX)				/* Stub value for missing   */
#define MISSING_VALUE		(DBL_MAX)	/* data point	            */
#elif defined(MAXDOUBLE)
#define MISSING_VALUE		(MAXDOUBLE)
#else
#define MISSING_VALUE		(1.23456789e+307)
#endif

#define max(a, b)       (((a) > (b)) ? (a) : (b))
#define min(a, b)       (((a) < (b)) ? (a) : (b))
#define number		(0)
#define i_state(a)	(min((a)+1,I_STATE_DIM))
#define i_const(a)	((a)+I_STATE_DIM+1)

int			*cohort_no;
double			*parameter;

void			DefineOutput(double *, population *, double *);

EXTERN_C int		DefOutWrapper(double *env, population *pop, double *output,
				      double *pars, int *coh_nr)

{
  if(output)
    {
      parameter = pars;
      cohort_no = coh_nr;

      output[0] = env[0];
      DefineOutput(env, pop, output+1);	
      // AvdM if function is called with a null pointer for "output", it should
      // just return the number of output variables (similar to defIDcard)
    }

  return (OUTPUT_VAR_NR+1);
}

#ifdef MODULE
EXTERN_C int		iStateDim()
{
  return (I_STATE_DIM);
}
#endif /* MODULE */

#endif /* DEFINEOUTPUT */
