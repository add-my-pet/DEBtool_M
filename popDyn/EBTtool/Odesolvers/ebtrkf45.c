/***
   NAME
     ebtrkf45
   DESCRIPTION
     This file contains the specification of the Runge-Kutta-Fehlberg 4/5th
     order integration method with an adaptive step size for the actual time
     integration of the ODEs in the Escalator Boxcar Train program.  
   NOTES
     
   HISTORY
     AMdR - Nov 08, 1998 : Created.
     AMdR - Jan 07, 2012 : Revised last.
***/
#ifndef EBTRKF45
#define EBTRKF45
#endif



/*==========================================================================*/
/*
 * Defining all constants that are local to this specific file.
 */

#define PSHRINK		-0.2
#define PGROW		-0.2
#define ABS_ERR		(2.0E-13)/accuracy
#define SAFETY		0.9



/*==========================================================================*/
/*
 * The error messages that occur in the routines in the present file.
 */

#define MAFO "Memory allocation failure in ODE integration routine!"
#define REC  "Too many recursions in integration to find suitable stepsize!"
#define SSS  "Step size in integration routine too small!"



/*==========================================================================*/
/*
 * Definitions of static variables, restricted to this file.
 */

static int		step_failed=0, recur_no;
static long		ODEAllocated = 0L, SystemSize;
static double		abs_err;
static double		*xin = NULL, *xtemp = NULL;
static double		*der1 = NULL, *der2 = NULL, *der3 = NULL;
static double		*der4 = NULL, *der5 = NULL, *der6 = NULL;
#if (POPULATION_NR > 0)
static int		table_size[POPULATION_NR];
static population	u_pop[POPULATION_NR], 	   u_ofs[POPULATION_NR];
static population	u_popgrad1[POPULATION_NR], u_ofsgrad1[POPULATION_NR];
static population	u_popgrad2[POPULATION_NR], u_ofsgrad2[POPULATION_NR];
static population	u_popgrad3[POPULATION_NR], u_ofsgrad3[POPULATION_NR];
static population	u_popgrad4[POPULATION_NR], u_ofsgrad4[POPULATION_NR];
static population	u_popgrad5[POPULATION_NR], u_ofsgrad5[POPULATION_NR];
static population	u_popgrad6[POPULATION_NR], u_ofsgrad6[POPULATION_NR];
#else
static population	*bpoints = NULL;
static population	*u_pop = NULL, 	    *u_ofs = NULL;
static population	*u_popgrad1 = NULL, *u_ofsgrad1 = NULL;
static population	*u_popgrad2 = NULL, *u_ofsgrad2 = NULL;
static population	*u_popgrad3 = NULL, *u_ofsgrad3 = NULL;
static population	*u_popgrad4 = NULL, *u_ofsgrad4 = NULL;
static population	*u_popgrad5 = NULL, *u_ofsgrad5 = NULL;
static population	*u_popgrad6 = NULL, *u_ofsgrad6 = NULL;
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
  abs_err = ABS_ERR;
  SystemSize    = ENVIRON_DIM;
#if (POPULATION_NR > 0)
  register int		i;

  for(i=0; i<POPULATION_NR; i++)
    {
      table_size[i] = CohortNo[i]+BpointNo[i];
      SystemSize   += table_size[i]*COHORT_SIZE;
    }
#endif //(POPULATION_NR > 0)
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
      der4  = (double *)Myalloc((void *)der4, (size_t)ODEAllocated,
				sizeof(double));
      der5  = (double *)Myalloc((void *)der5, (size_t)ODEAllocated,
				sizeof(double));
      der6  = (double *)Myalloc((void *)der6, (size_t)ODEAllocated,
				sizeof(double));
      if(!(xin && xtemp && der1 && der2 && der3 && der4 && der5 && der6))
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
      u_popgrad4[i] = (population)(der4+len);
      u_ofsgrad4[i] = (population)(der4+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad5[i] = (population)(der5+len);
      u_ofsgrad5[i] = (population)(der5+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad6[i] = (population)(der6+len);
      u_ofsgrad6[i] = (population)(der6+len+CohortNo[i]*COHORT_SIZE);
      len += (table_size[i]*COHORT_SIZE);
    }
#endif // (POPULATION_NR > 0)

  return;
}




/*==========================================================================*/

static void	Fehlberg(double dt)

  /* 
   * Fehlberg - Routine performs a RKF45 integration step of the system and 
   *            updates all the variables.
   */

{
  register int		i;
  static CONST double	b11=  	    1.0/     4.0;
  static CONST double	b21=	    3.0/    32.0,  b22=	       9.0/     32.0;
  static CONST double	b31=	 1932.0/  2197.0,  b32= -   7200.0/   2197.0,
			b33=	 7296.0/  2197.0;
  static CONST double	b41=	 8341.0/  4104.0,  b42= -  32832.0/   4104.0,
			b43=	29440.0/  4104.0,  b44= -    845.0/   4104.0;
  static CONST double	b51= -	 6080.0/ 20520.0,  b52=    41040.0/  20520.0, 
			b53= -  28352.0/ 20520.0,  b54=     9295.0/  20520.0, 
			b55= -   5643.0/ 20520.0;
  static CONST double	b61=	 2375.0/ 20520.0,
			b63=	11264.0/ 20520.0,  b64=    10985.0/  20520.0,
			b65= -	 4104.0/ 20520.0;
  static CONST double	b71=   902880.0/7618050.0,
			b73=  3953664.0/7618050.0, b74=  3855735.0/7618050.0,
			b75= -1371249.0/7618050.0, b76=   277020.0/7618050.0;

  initState = xin;
  currentState   = xtemp;
  currentDers[1] = der1;
  currentDers[2] = der2;
  currentDers[3] = der3;
  currentDers[4] = der4;
  currentDers[5] = der5;
  currentDers[6] = der6;
						/* Set all time derivatives */
  der1[0] = der2[0] = der3[0] = der4[0] = der5[0] = der6[0] = 1.0;

						/* Don't do first deriva-   */
  if(!recur_no)					/* tive if already present  */
    {
      (void)memcpy((DEF_TYPE *)xtemp,(DEF_TYPE *)xin,
		   SystemSize*sizeof(double));
      rk_level = 1;
      Gradient(xtemp, u_pop, u_ofs, der1, u_popgrad1, u_ofsgrad1, bpoints);
    }

  for (i=0; i<SystemSize; i++)
    xtemp[i] = xin[i] + dt*(b11*der1[i]);

  rk_level = 2;
  Gradient(xtemp, u_pop, u_ofs, der2, u_popgrad2, u_ofsgrad2, bpoints);

  for (i=0; i<SystemSize; i++)
    xtemp[i] = xin[i] + dt*(b21*der1[i]+b22*der2[i]);

  rk_level = 3;
  Gradient(xtemp, u_pop, u_ofs, der3, u_popgrad3, u_ofsgrad3, bpoints);

  for (i=0; i<SystemSize; i++)
    xtemp[i] = xin[i] + dt*(b31*der1[i]+b32*der2[i]+b33*der3[i]);

  rk_level = 4;
  Gradient(xtemp, u_pop, u_ofs, der4, u_popgrad4, u_ofsgrad4, bpoints);

  for (i=0; i<SystemSize; i++)
    xtemp[i] = xin[i] +
      dt*(b41*der1[i]+b42*der2[i]+b43*der3[i]+b44*der4[i]);

  rk_level = 5;
  Gradient(xtemp, u_pop, u_ofs, der5, u_popgrad5, u_ofsgrad5, bpoints);

  for (i=0; i<SystemSize; i++)
    xtemp[i] = xin[i] +
      dt*(b51*der1[i]+b52*der2[i]+b53*der3[i]+b54*der4[i]+b55*der5[i]);

  rk_level = 6;
  Gradient(xtemp, u_pop, u_ofs, der6, u_popgrad6, u_ofsgrad6, bpoints);

  for (i=0; i<SystemSize; i++)			/* Save 5th order values    */
    xtemp[i] = xin[i] +
      dt*(b71*der1[i]+b73*der3[i]+b74*der4[i]+b75*der5[i]+b76*der6[i]);

						/* Save differences with 4th*/
  for (i=0; i<SystemSize; i++)			/* order values in der2     */
    der2[i] = xin[i] - xtemp[i] +		/* (no longer needed)       */
      dt*(b61*der1[i]+b63*der3[i]+b64*der4[i]+b65*der5[i]);

  return;
}




/*==========================================================================*/

double	  IntegrationStep(double del_tim, double del_max, int recurs)

  /* 
   * IntegrationStep - Performs an integration with adaptable step size but 
   *                   maximum "del_max". Step size control and order 
   *                   increase using Fehlberg's method as implemented by 
   *                   Watts & Shampine (see Forsythe et al., 1977,
   *		       Computer methods for mathematical computations,
   *		       Chapter 6). 
   */
  
{
  register int		i;
  register double	*pin, *perr, *pout;
  double		del_h, ss;
  double		errmax;
  int			adjust = 1;
  
  del_h = del_tim;				/* Adjust stepsize to hit   */
  if(del_max < (2*del_tim))			/* cohort end, look ahead   */
    {						/* two steps to avoid too   */
      del_h = 0.5*del_max;			/* drastic step changes	    */
      if(del_max < del_tim) del_h = del_max;
      adjust = 0;
    }
  if(del_h < SMALLEST_STEP)
    {
#if (POPULATION_NR > 0)
      TransBcohorts();
#endif // (POPULATION_NR > 0)
      ErrorExit(0, SSS);
    }
  recur_no = recurs;

  Fehlberg(del_h);				/* Do an integration step   */

  pin = xin; perr = der2; pout = xtemp; errmax=0.0;
  for(i=0; i<SystemSize; i++)
      errmax = max(fabs(perr[i])/(fabs(pin[i])+fabs(pout[i])+abs_err),
		   errmax);			/* Determine relative error */
  errmax *= 2.0*del_h/accuracy;			/* according to Watts &	    */
						/* Shampine (see Forsythe)  */

						/* If bigger than accuracy  */
  if (errmax > 1.0)				/* take smaller step and    */
    {						/* restart. Stepdecrease    */
      recur_no++; step_failed=1;		/* is limited to 0.1.	    */

      if (recur_no > 25)
	{
#if (POPULATION_NR > 0)
	  TransBcohorts();
#endif // (POPULATION_NR > 0)
	  ErrorExit(0, REC);
	}
						/* This part is adapted	    */
      if(errmax < 59049.0)			/* from Watts & Shampine    */
	del_h *= max(SAFETY*pow(errmax, PSHRINK), 0.1);
      else del_h *= 0.1;
      step_size = del_h;
      del_h=IntegrationStep(del_h, del_max, recur_no);
    }						/* Otherwise compute new    */
  else						/* stepsize. Increase is    */
    {						/* limited to factor 5.0    */
      if (adjust && !step_failed)		/* No increase if failed    */
	{					/* just before		    */
	  if(errmax > 1.889568E-4) ss = min(SAFETY*pow(errmax, PGROW), 5.0);
	  else ss = 5.0;
	  step_size=min(ss*del_h, cohort_limit);
	}
      step_failed=0;

						/* Update basic data copy   */
      (void)memcpy((DEF_TYPE *)env,		/* Copy environment vars.   */
                   (DEF_TYPE *)xtemp,
		   ENVIRON_DIM*sizeof(double));
#if (POPULATION_NR > 0)
      int			len, adjust = 1;

      len = ENVIRON_DIM;
      for(i=0; i<POPULATION_NR; i++)
	{
	  (void)memcpy((DEF_TYPE *)pop[i],	/* Copy all populations     */
		       (DEF_TYPE *)(xtemp+len),
		       (table_size[i]*COHORT_SIZE)*sizeof(double));
	  len += (table_size[i]*COHORT_SIZE);
	}
#endif // (POPULATION_NR > 0)
						/* Update local data copy   */
      (void)memcpy((DEF_TYPE *)xin,(DEF_TYPE *)xtemp,
		   SystemSize*sizeof(double));

    }
  
  return del_h;
}



/*==========================================================================*/
