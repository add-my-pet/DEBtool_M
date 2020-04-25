/* Copyright (c) 1997 by A.M. de Roos. All Rights Reserved                  */

/***
   NAME
     DefineIDcard
   PURPOSE
     A wrapper header file for DefineIDcard.c
   NOTES
     
   HISTORY
     AMdR - Sep 07, 2007
     AvdM - August, 2005 Added export of i_state_dim
***/

#ifndef I_STATE_DIM
#error You have to define I_STATE_DIM at the beginning of the source file!
#endif
#ifndef NEW_CONST_DIM
#error You have to define NEW_CONST_DIM at the beginning of the source file!
#endif

#ifndef DEFINEIDCARD
#define DEFINEIDCARD
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


void			DefineIDcard(double *, population *, population *);

EXTERN_C int		DefIDcardWrapper(double *env, population *pop, population *newIDcard,
					 double *pars, int *coh_nr)

{
  if (newIDcard)
    {
      parameter = pars;
      cohort_no = coh_nr;

      DefineIDcard(env, pop, newIDcard);
    }

  return (NEW_CONST_DIM);
}

#ifdef MODULE
EXTERN_C int		iStateDim()
{
  return (I_STATE_DIM);
}
#endif /* MODULE */

#endif /* DEFINEIDCARD */
