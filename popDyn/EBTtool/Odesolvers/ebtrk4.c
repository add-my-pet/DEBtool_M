/***
   NAME
     ebtrk4
   DESCRIPTION
     This file contains the specification of the 4th order Runga-Kutta
     integration method with fixed stepsize for the time integration of the
     ODEs in the Escalator Boxcar Train program.
   NOTES
     
   HISTORY
     Last modification: AMdR - Jan 07, 2012
***/
#ifndef EBTRK4
#define EBTRK4
#endif



/*==========================================================================*/
/*
 * The error messages that occur in the routines in the present file.
 */

#define MAFO "Memory allocation failure in ODE integration routine!"



/*==========================================================================*/
/*
 * Definitions of static variables, restricted to this file.
 */

static long		ODEAllocated = 0L, SystemSize;
static double		*xin = NULL, *xtemp = NULL;
static double		*der1 = NULL, *der2 = NULL, *der3 = NULL;
#if (POPULATION_NR > 0)
static int		table_size[POPULATION_NR];
static population	u_pop[POPULATION_NR], 	   u_ofs[POPULATION_NR];
static population	u_popgrad1[POPULATION_NR], u_ofsgrad1[POPULATION_NR];
static population	u_popgrad2[POPULATION_NR], u_ofsgrad2[POPULATION_NR];
static population	u_popgrad3[POPULATION_NR], u_ofsgrad3[POPULATION_NR];
#else
static population	*bpoints = NULL;
static population	*u_pop = NULL, 	    *u_ofs = NULL;
static population	*u_popgrad1 = NULL, *u_ofsgrad1 = NULL;
static population	*u_popgrad2 = NULL, *u_ofsgrad2 = NULL;
static population	*u_popgrad3 = NULL, *u_ofsgrad3 = NULL;
#endif // (POPULATION_NR > 0)



/*==========================================================================*/
/*
 * Start of function implementations.
 */
/*==========================================================================*/

void	PrepareCycle()

  /* 
   * PrepareCycle - This routine is called at the beginning of a cohort
   *		    cycle, when the size of the system of ODEs is fixed and
   *		    will not change until the end of the cohort cycle has
   *		    been reached. The different memory copies of the data
   *		    to be integrated and the pointers into the data heap
   *		    can hence safely be set up.
   */

{
  SystemSize    = ENVIRON_DIM;

#if (POPULATION_NR > 0)
  register int		i;

  for(i=0; i<POPULATION_NR; i++)
    {
      table_size[i] = CohortNo[i]+BpointNo[i];
      SystemSize   += table_size[i]*COHORT_SIZE;
    }
#endif // (POPULATION_NR > 0)

  if (!(SystemSize < ODEAllocated))
    {
      ODEAllocated = MemBlocks(SystemSize);
      xin   = (double *)Myalloc((void *)xin, (size_t)ODEAllocated,
				sizeof(double));
      xtemp = (double *)Myalloc((void *)xtemp, (size_t)ODEAllocated,
				sizeof(double));
      der1  = (double *)Myalloc((void *)der1, (size_t)ODEAllocated,
				sizeof(double));
      der2  = (double *)Myalloc((void *)der2, (size_t)ODEAllocated,
				sizeof(double));
      der3  = (double *)Myalloc((void *)der3, (size_t)ODEAllocated,
				sizeof(double));
      if(!(xin && xtemp && der1 && der2 && der3))
	ErrorAbort(MAFO);
    }

  (void)memcpy((DEF_TYPE *)xin,			/* Copy environment vars.   */
	       (DEF_TYPE *)env,
	       ENVIRON_DIM*sizeof(double));
#if (POPULATION_NR > 0)
  int			len;

  len = ENVIRON_DIM;
  for(i=0; i<POPULATION_NR; i++)
    {
      (void)memcpy((DEF_TYPE *)(xin+len),	/* Copy all populations     */
		   (DEF_TYPE *)pop[i],
		   (table_size[i]*COHORT_SIZE)*sizeof(double));
      u_pop[i] = (population)(xtemp+len);
      u_ofs[i] = (population)(xtemp+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad1[i] = (population)(der1+len);
      u_ofsgrad1[i] = (population)(der1+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad2[i] = (population)(der2+len);
      u_ofsgrad2[i] = (population)(der2+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad3[i] = (population)(der3+len);
      u_ofsgrad3[i] = (population)(der3+len+CohortNo[i]*COHORT_SIZE);
      len += (table_size[i]*COHORT_SIZE);
    }
#endif // (POPULATION_NR > 0)


  return;
}




/*==========================================================================*/

double	  IntegrationStep(double del_tim, double del_max, int recurs)

  /* 
   * IntegrationStep - Performs an integration with fixed step size but 
   *                   maximum "del_max". 
   */
  
{
  register int		i;
  double		del_h, hh, h6;
  
  del_h = min(accuracy, del_max);
  hh    = del_h*0.5;
  h6    = del_h/6.0;

  initState = xin;
  currentState = xtemp;
  currentDers[1] = der1;
  currentDers[2] = der2;
  currentDers[3] = der3;

  der1[0] = der2[0] = der3[0] = 1.0;		/* Set all time derivatives */

  (void)memcpy((DEF_TYPE *)xtemp, (DEF_TYPE *)xin,
	       SystemSize*sizeof(double));
  rk_level = 1;
  Gradient(xtemp, u_pop, u_ofs, der1, u_popgrad1, u_ofsgrad1, bpoints);

  for (i=0; i<SystemSize; i++)
    xtemp[i] = xin[i] + hh*der1[i];
  rk_level = 2;
  Gradient(xtemp, u_pop, u_ofs, der2, u_popgrad2, u_ofsgrad2, bpoints);

  for (i=0; i<SystemSize; i++)
    xtemp[i] = xin[i] + hh*der2[i];
  rk_level = 3;
  Gradient(xtemp, u_pop, u_ofs, der3, u_popgrad3, u_ofsgrad3, bpoints);

  for (i=0; i<SystemSize; i++)
    {
      xtemp[i] = xin[i] + del_h*der3[i];
      der3[i] += der2[i];
    }
  rk_level = 4;
  Gradient(xtemp, u_pop, u_ofs, der2, u_popgrad2, u_ofsgrad2, bpoints);

  for (i=0; i<SystemSize; i++)
    xtemp[i] = xin[i] + h6*(der1[i]+der2[i]+2.0*der3[i]);

						/* Update basic data copy   */
  (void)memcpy((DEF_TYPE *)env,			/* Copy environment vars.   */
	       (DEF_TYPE *)xtemp,
	       ENVIRON_DIM*sizeof(double));

#if (POPULATION_NR > 0)
  int			len;

  len = ENVIRON_DIM;
  for(i=0; i<POPULATION_NR; i++)
    {
      (void)memcpy((DEF_TYPE *)pop[i],		/* Copy all populations     */
		   (DEF_TYPE *)(xtemp+len),
		   (table_size[i]*COHORT_SIZE)*sizeof(double));
      len += (table_size[i]*COHORT_SIZE);
    }
#endif // (POPULATION_NR > 0)
						/* Update local data copy   */
  (void)memcpy((DEF_TYPE *)xin,(DEF_TYPE *)xtemp,
	       SystemSize*sizeof(double));

  return del_h;
}



/*==========================================================================*/
