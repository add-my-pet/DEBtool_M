/***
   NAME
     ebtdopri5
   DESCRIPTION
     This file contains the specification of an explicit Runge-Kutta method of
     order (4)5 due to Dormand & Prince with step size control and dense output
     for the actual time integration of the ODEs in the Escalator Boxcar Train
     program. This method is used here especially for event location.
     The code is adapted from the original C source code, written by

		E. Hairer & G. Wanner
		Universite de Geneve, dept. de Mathematiques
		CH-1211 GENEVE 4, SWITZERLAND
		E-mail : HAIRER@DIVSUN.UNIGE.CH, WANNER@DIVSUN.UNIGE.CH

     The code is described in : E. Hairer, S.P. Norsett and G. Wanner, Solving
     ordinary differential equations I, nonstiff problems, 2nd edition,
     Springer Series in Computational Mathematics, Springer-Verlag (1993).
     
   Last modification: AMdR - Aug 02, 2015
***/
#ifndef EBTDOPRI5
#define EBTDOPRI5
#endif



/*==========================================================================*/
/*
 * Defining all constants that are local to this specific file.
 */
/*==========================================================================*/
/***
	DESCRIPTION OF INTEGRATION CONSTANTS

BETA	 The "beta" for stabilized step size control (see section IV.2 of the
	 book). Larger values for beta ( <= 0.1 ) make the step size control 
	 more stable. dopri5 needs a larger beta than Higham & Hall. Negative 
	 initial value provoke beta=0; default beta=0.04.

FAC1     Parameters for step size selection; the new step size is chosen
FAC2     subject to the restriction  fac1 <= hnew/hold <= fac2.
	 Default values are fac1=0.2 and fac2=10.0.

SAFETY   Safety factor in the step size prediction, default 0.9.

***/  

#define BETA		0.1
#define FAC1		0.2
#define FAC2	       10.0
#define FACC1		5.0			/* 1.0 / FAC1               */
#define FACC2		0.1			/* 1.0 / FAC2               */
#define SAFETY		0.9
#define ABS_ERR		1.0E-13
#define FACOLD		1.0E-4
#define NSTIFF		1000



/*==========================================================================*/
/*
 * The error messages that occur in the routines in the present file.
 */

#define MAFO "Memory allocation failure in ODE integration routine!"
#define REC  "Too many recursions in integration to find suitable stepsize!"
#define SSS  "Step size in integration routine too small!"
#define ZBB  "Root is not bracketed in ZBRENT!"
#define ZBM  "Maximum number of iterations exceeded in ZBRENT!"


/*==========================================================================*/
/*
 * Definitions of static variables, restricted to this file.
 */

static int		step_failed=0, recur_no;
static int		nonsti = 0, iasti = 0;
static double		hlamb = 0.0;
static long		accepted_steps = 0L;
static long		ODEAllocated = 0L, SystemSize;
static double		*y  = NULL, *yy1 = NULL, *yco  = NULL, *ysti = NULL;
static double		*k1 = NULL, *k2  = NULL, *k3   = NULL;
static double		*k4 = NULL, *k5  = NULL, *k6   = NULL;
static double		*rcont1 = NULL, *rcont2  = NULL, *rcont3 = NULL;
static double		*rcont4 = NULL, *rcont5  = NULL;
#if (POPULATION_NR > 0)
static int		table_size[POPULATION_NR];
static population	u_pop[POPULATION_NR], 	   u_ofs[POPULATION_NR];
static population	c_pop[POPULATION_NR],	   c_ofs[POPULATION_NR];
static population	u_popgrad1[POPULATION_NR], u_ofsgrad1[POPULATION_NR];
static population	u_popgrad2[POPULATION_NR], u_ofsgrad2[POPULATION_NR];
static population	u_popgrad3[POPULATION_NR], u_ofsgrad3[POPULATION_NR];
static population	u_popgrad4[POPULATION_NR], u_ofsgrad4[POPULATION_NR];
static population	u_popgrad5[POPULATION_NR], u_ofsgrad5[POPULATION_NR];
static population	u_popgrad6[POPULATION_NR], u_ofsgrad6[POPULATION_NR];
#else
static population	*bpoints = NULL;
static population	*u_pop = NULL, 	    *u_ofs = NULL;
#if (EVENT_NR > 0)
static population	*c_pop = NULL,	    *c_ofs = NULL;
#endif
static population	*u_popgrad1 = NULL, *u_ofsgrad1 = NULL;
static population	*u_popgrad2 = NULL, *u_ofsgrad2 = NULL;
static population	*u_popgrad3 = NULL, *u_ofsgrad3 = NULL;
static population	*u_popgrad4 = NULL, *u_ofsgrad4 = NULL;
static population	*u_popgrad5 = NULL, *u_ofsgrad5 = NULL;
static population	*u_popgrad6 = NULL, *u_ofsgrad6 = NULL;
#endif // (POPULATION_NR > 0)

static double		facold = FACOLD;
#if (EVENT_NR > 0)
static double		oldELvalue[EVENT_NR] = {0.0},
			newELvalue[EVENT_NR] = {0.0};
static int		located[EVENT_NR] = {0};
#endif


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
  SystemSize = ENVIRON_DIM;
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
      y    = (double *)Myalloc((void *)y, (size_t)ODEAllocated,
			       sizeof(double));
      yy1  = (double *)Myalloc((void *)yy1, (size_t)ODEAllocated,
			       sizeof(double));
      yco  = (double *)Myalloc((void *)yco, (size_t)ODEAllocated,
			       sizeof(double));
      ysti = (double *)Myalloc((void *)ysti, (size_t)ODEAllocated,
			       sizeof(double));
      k1   = (double *)Myalloc((void *)k1, (size_t)ODEAllocated,
			       sizeof(double));
      k2   = (double *)Myalloc((void *)k2, (size_t)ODEAllocated,
			       sizeof(double));
      k3   = (double *)Myalloc((void *)k3, (size_t)ODEAllocated,
			       sizeof(double));
      k4   = (double *)Myalloc((void *)k4, (size_t)ODEAllocated,
			       sizeof(double));
      k5   = (double *)Myalloc((void *)k5, (size_t)ODEAllocated,
			       sizeof(double));
      k6   = (double *)Myalloc((void *)k6, (size_t)ODEAllocated,
			       sizeof(double));
      rcont1  = (double *)Myalloc((void *)rcont1, (size_t)ODEAllocated,
				  sizeof(double));
      rcont2  = (double *)Myalloc((void *)rcont2, (size_t)ODEAllocated,
				  sizeof(double));
      rcont3  = (double *)Myalloc((void *)rcont3, (size_t)ODEAllocated,
				  sizeof(double));
      rcont4  = (double *)Myalloc((void *)rcont4, (size_t)ODEAllocated,
				  sizeof(double));
      rcont5  = (double *)Myalloc((void *)rcont5, (size_t)ODEAllocated,
				  sizeof(double));
      if(!(y && yy1 && yco && ysti && k1 && k2 && k3 && k4 && k5 && k6 &&
	   rcont1 && rcont2 && rcont3 && rcont4 && rcont5))
	ErrorAbort(MAFO);
    }

  (void)memcpy((DEF_TYPE *)y,			/* Copy environment vars.   */
	       (DEF_TYPE *)env,
	       ENVIRON_DIM*sizeof(double));

#if (POPULATION_NR > 0)
  int			len;

  len = ENVIRON_DIM;
  for(i=0; i<POPULATION_NR; i++)
    {
      (void)memcpy((DEF_TYPE *)(y+len),		/* Copy all populations     */
		   (DEF_TYPE *)pop[i],
		   (table_size[i]*COHORT_SIZE)*sizeof(double));
      u_pop[i] = (population)(yy1+len);
      u_ofs[i] = (population)(yy1+len+CohortNo[i]*COHORT_SIZE);
      c_pop[i] = (population)(yco+len);
      c_ofs[i] = (population)(yco+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad1[i] = (population)(k1+len);
      u_ofsgrad1[i] = (population)(k1+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad2[i] = (population)(k2+len);
      u_ofsgrad2[i] = (population)(k2+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad3[i] = (population)(k3+len);
      u_ofsgrad3[i] = (population)(k3+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad4[i] = (population)(k4+len);
      u_ofsgrad4[i] = (population)(k4+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad5[i] = (population)(k5+len);
      u_ofsgrad5[i] = (population)(k5+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad6[i] = (population)(k6+len);
      u_ofsgrad6[i] = (population)(k6+len+CohortNo[i]*COHORT_SIZE);
      len += (table_size[i]*COHORT_SIZE);
    }
#endif // (POPULATION_NR > 0)

  return;
}




/*==============================================================================*/

static void	dopri5(double dt)

  /* 
   * dopri5 - Routine performs an integration step of the system using the
   *	      DOPRI5 integration method. The code is adapted from the original
   *	      C source code by E. Hairer & G. Wanner.
   */

{
  register int		i;
  static CONST double	
    a21=0.2, 		
    a31=3.0/40.0, 	a32=9.0/40.0,   
    a41=44.0/45.0,    	a42=-56.0/15.0, 	a43=32.0/9.0,
    a51=19372.0/6561.0, a52=-25360.0/2187.0,	a53=64448.0/6561.0, a54=-212.0/729.0,
    a61=9017.0/3168.0, 	a62=-355.0/33.0, 	a63=46732.0/5247.0, a64=49.0/176.0, 	a65=-5103.0/18656.0,
    a71=35.0/384.0, 				a73=500.0/1113.0,   a74=125.0/192.0,	a75=-2187.0/6784.0, 	a76=11.0/84.0,
    d1=-12715105075.0/11282082432.0, 		d3=87487479700.0/32700410799.0,
    d4=-10690763975.0/1880347072.0, 		d5=701980252875.0/199316789632.0,
    d6=-1453857185.0/822651844.0, 		d7=69997945.0/29380423.0,
    e1=71.0/57600.0, 				e3=-71.0/16695.0, 	
    e4=71.0/1920.0,	e5=-17253.0/339200.0, 	e6=22.0/525.0, 
    e7=-1.0/40.0;

  initState = y;
  currentState = yy1;
  currentDers[1] = k1;
  currentDers[2] = k2;
  currentDers[3] = k3;
  currentDers[4] = k4;
  currentDers[5] = k5;
  currentDers[6] = k6;
  currentDers[7] = k2;
						/* Set all time derivatives */
  k1[0] = k2[0] = k3[0] = k4[0] = k5[0] = k6[0] = 1.0;

						/* Don't do first deriva-   */
  if(!recur_no)					/* tive if already present  */
    {
      (void)memcpy((DEF_TYPE *)yy1,(DEF_TYPE *)y, SystemSize*sizeof(double));
      rk_level = 1;
      Gradient(yy1, u_pop, u_ofs, k1, u_popgrad1, u_ofsgrad1, bpoints);
#if (EVENT_NR > 0)
      for (i=0; i<EVENT_NR; i++) oldELvalue[i] = NO_EVENT;
      EventLocation(yy1, u_pop, u_ofs, bpoints, oldELvalue);
#endif
    }

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * a21 * k1[i];

  rk_level = 2;
  Gradient(yy1, u_pop, u_ofs, k2, u_popgrad2, u_ofsgrad2, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a31*k1[i] + a32*k2[i]);

  rk_level = 3;
  Gradient(yy1, u_pop, u_ofs, k3, u_popgrad3, u_ofsgrad3, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a41*k1[i] + a42*k2[i] + a43*k3[i]);

  rk_level = 4;
  Gradient(yy1, u_pop, u_ofs, k4, u_popgrad4, u_ofsgrad4, bpoints);

  for (i = 0; i <SystemSize; i++)
    yy1[i] = y[i] + dt * (a51*k1[i] + a52*k2[i] + a53*k3[i] + a54*k4[i]);

  rk_level = 5;
  Gradient(yy1, u_pop, u_ofs, k5, u_popgrad5, u_ofsgrad5, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a61*k1[i] + a62*k2[i] + a63*k3[i] +
			  a64*k4[i] + a65*k5[i]);

  (void)memcpy((DEF_TYPE *)ysti, (DEF_TYPE *)yy1, SystemSize*sizeof(double));

  rk_level = 6;
  Gradient(yy1, u_pop, u_ofs, k6, u_popgrad6, u_ofsgrad6, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a71*k1[i] + a73*k3[i] + a74*k4[i] +
			  a75*k5[i] + a76*k6[i]);
  rk_level = 7;
  Gradient(yy1, u_pop, u_ofs, k2, u_popgrad2, u_ofsgrad2, bpoints);

  for (i = 0; i < SystemSize; i++)
    rcont5[i] = dt * (d1*k1[i] + d3*k3[i] + d4*k4[i] +
		      d5*k5[i] + d6*k6[i] + d7*k2[i]);

  for (i = 0; i < SystemSize; i++)
    k4[i] = dt * (e1*k1[i] + e3*k3[i] + e4*k4[i] + e5*k5[i] + e6*k6[i] + e7*k2[i]);

  return;
} /* dopri5 */




/*==============================================================================*/
#if (EVENT_NR > 0)

static double 	delvalue(double theta, int eventindex)

{
  register int		i;
  double   		theta1, result[EVENT_NR];

  theta1 = 1.0 - theta;

  for (i = 0; i < SystemSize; i++)
    yco[i] = rcont1[i] + theta*(rcont2[i] +
				theta1*(rcont3[i] +
					theta*(rcont4[i] +
					       theta1*rcont5[i])));

  for (i=0; i<EVENT_NR; i++) result[i] = NO_EVENT;
  EventLocation(yco, c_pop, c_ofs, bpoints, result);
  
  return result[eventindex];
}




/*==============================================================================*/
#define ITMAX		500
#define EPS		1.0e-16

static double	zbrent(double olddel, double newdel, int eventindex)

{
  int			iter;
  double		a, b, c = 0.0, d = 0.0, e = 0.0, min1, min2;
  double		fa, fb, fc, p, q, r, s, tol1, xm;

  a = 0.0; fa=olddel;
  b = 1.0; fb=newdel;

  if (fb*fa > 0.0)
    {
      Warning(ZBB);
      return -1.0;
    }

  fc = fb;
  for (iter=0; iter<ITMAX; iter++)
    {
      if (fb*fc > 0.0)
	{
	  c = a; fc=fa;
	  e = d = b-a;
	}
      if (fabs(fc) < fabs(fb))
	{
	  a = b; fa = fb;
	  b = c; fb = fc;
	  c = a; fc = fa;
	}
      tol1 = 2.0*EPS*fabs(b)+0.5*identical_zero;
      xm = 0.5*(c-b);

      if ((fabs(xm) <= tol1 && fb*fc <=0.0) || fb == 0.0) return b;

      if (fabs(e) >= tol1 && fabs(fa) > fabs(fb))
	{
	  s = fb/fa;
	  if (a == c)
	    {
	      p=2.0*xm*s;
	      q=1.0-s;
	    }
	  else
	    {
	      q = fa/fc;
	      r = fb/fc;
	      p = s*(2.0*xm*q*(q-r)-(b-a)*(r-1.0));
	      q = (q-1.0)*(r-1.0)*(s-1.0);
	    }
	  if (p > 0.0) q = -q;
	  p = fabs(p);
	  min1 = 3.0*xm*q-fabs(tol1*q);
	  min2 = fabs(e*q);
	  if (2.0*p < (min1 < min2 ? min1 : min2))
	    {
	      e = d;
	      d = p/q;
	    }
	  else
	    {
	      d = xm;
	      e = d;
	    }
	}
      else
	{
	  d = xm;
	  e = d;
	}
      a = b; fa = fb;
      if (fabs(d) > tol1) b += d;
      else b += (xm > 0.0 ? fabs(tol1) : -fabs(tol1));
      fb = delvalue(b, eventindex);
    }
  Warning(ZBM);

  return -1.0;
}



#undef ITMAX
#undef EPS

/*===========================================================================*/

static void	LocateEvent(double prev_dt, int *doloc, int *located)

  /* 
   * LocateEvent - This routine is called to locate the events that are
   *		   triggered by the user-defined routine EventLocation()
   *	           It is assumed that on entrance to this routine, the array
   *		   doloc[] flags which events to locate, i.e. for which
   *		   event indicator oldELvalue[] and newELvalue[] have sound
		   values, i.e. both non-zero and their product negative.
   */

{
  register int		i;
  int			index = -1;
  double		new_dt, level;
  double		stepfrac[EVENT_NR], smallest = 2.0;

  for (i=0; i<EVENT_NR; i++)
    {
      located[i] = 0;
      if (doloc[i])
	{
	  stepfrac[i] = zbrent(oldELvalue[i], newELvalue[i], i);
	  if ((stepfrac[i] < 0.0) || (stepfrac[i] > 1.0))
	    {
	      if (EBTDEBUG(1))
		{
		  (void)fprintf(dbgfil, "Problem locating event %d at T = %15.8f",
				i, yy1[0]);
		  (void)fprintf(dbgfil,	"  Start = %12.7E", oldELvalue[i]);
		  (void)fprintf(dbgfil,	"  Stop = %12.7E", newELvalue[i]);
		  (void)fprintf(dbgfil,	"  dt old = %12.7E", prev_dt);
		  (void)fprintf(dbgfil,	"  dt new = %12.7E\n", stepfrac[i]*prev_dt);
		  fflush(dbgfil);
		}
	    }
	  else if (stepfrac[i] < smallest)
	    {
	      smallest = stepfrac[i];
	      index = i;
	    }
	}
    }

  if (index < 0)
    {
      (void)memcpy((DEF_TYPE *)yy1,(DEF_TYPE *)y, SystemSize*sizeof(double));
      return;
    }
  
  new_dt = prev_dt*stepfrac[index];
  if (new_dt == 0.0)
    (void)memcpy((DEF_TYPE *)yy1,(DEF_TYPE *)y, SystemSize*sizeof(double));
  else
    {
#if (1)						/* Use the continuous output*/
      double		theta, theta1;		/* state to continue        */
      
      theta = stepfrac[index];
      theta1 = 1.0 - theta;
      
      for (i = 0; i < SystemSize; i++)
	yy1[i] = rcont1[i] + theta*(rcont2[i] +
				    theta1*(rcont3[i] +
					    theta*(rcont4[i] +
						   theta1*rcont5[i])));
#else
      double		yd0, ydiff, bspl;
      
      dopri5(new_dt);
      /*
       * Update variables for continuous output
       */
      for (i = 0; i < SystemSize; i++)
	{
	  yd0 = y[i];
	  ydiff = yy1[i] - yd0;
	  bspl = new_dt * k1[i] - ydiff;
	  rcont1[i] = y[i];
	  rcont2[i] = ydiff;
	  rcont3[i] = bspl;
	  rcont4[i] = -new_dt * k2[i] + ydiff - bspl;
	}
#endif
    }
  
  located[index] = 1;
  LocatedEvent = index;
  
  for (i=0; i<EVENT_NR; i++) newELvalue[i] = NO_EVENT;
  EventLocation(yy1, u_pop, u_ofs, bpoints, newELvalue);

  equal2zero = max(identical_zero,
		   pow(10, ceil(log10(fabs(newELvalue[index]) + ABS_ERR))));

  cohort_end = ForceCohortEnd(yy1, u_pop, u_ofs, bpoints);

  if (EBTDEBUG(1))				/* Report performance if    */
    {						/* required by user         */
      if (EBTDEBUG(4))
	{
	  fprintf(dbgfil, "%-14s%3d: T = %15.8f     dt = %12.7E\n",
		  "Step to event", index, env[0], new_dt);
	  fflush(dbgfil);
	}
  
      if (EBTDEBUG(2) ||
	  (EBTDEBUG(1) && (fabs(newELvalue[index]) >= identical_zero)))
	{
	  if (cohort_end)
	    (void)fprintf(dbgfil, "%-18s T = %15.8f",
			  "Cohort closed:", yy1[0]);
	  else
	    (void)fprintf(dbgfil, "%-18s T = %15.8f",
			  "Event located:", yy1[0]);
	  (void)fprintf(dbgfil, "  Value = %12.7E", newELvalue[index]);
	  if (fabs(newELvalue[index]) >= identical_zero)
	    {
	      (void)fprintf(dbgfil, " ");
	      level = (ceil(log10(fabs(newELvalue[index])/identical_zero))-
		       identical_zero);
	      for (i=0; i<level; i++) (void)fprintf(dbgfil, "*");
	    }
	  (void)fprintf(dbgfil, "\n");
	  (void)fflush(dbgfil);
	}
    }

  return;
} /* LocateEvent */
#endif /* EVENT_NR > 0 */



/*==============================================================================*/

static void	  IntermediateState(double theta)

  /* 
   * IntermediateState - Routine computes the state of the system at an
   *			 intermediate time point by interpolation. 
   *			 Values are stored in basic data copy for further use
   *			 in output routines.
   */
  
{
  register int		i;
  double   		theta1;

  theta1 = 1.0 - theta;

  for (i = 0; i < SystemSize; i++)
    yco[i] = rcont1[i] + theta*(rcont2[i] +
				theta1*(rcont3[i] +
					theta*(rcont4[i] +
					       theta1*rcont5[i])));

  (void)memcpy((DEF_TYPE *)env, (DEF_TYPE *)yco, ENVIRON_DIM*sizeof(double));

#if (POPULATION_NR > 0)
  register int		j, k;
  int			len;

  len = ENVIRON_DIM;
  for(i=0; i<POPULATION_NR; i++)
    {
      (void)memcpy((DEF_TYPE *)pop[i], (DEF_TYPE *)(yco+len),
		   (table_size[i]*COHORT_SIZE)*sizeof(double));
      len += (table_size[i]*COHORT_SIZE);
    }

  for(i=0; i<POPULATION_NR; i++)
    {
      for(j=0; j<BpointNo[i]; j++)
	{
	  if(ofs[i][j][number] > 0)
	    {
	      for(k=1; k<COHORT_SIZE; k++)
		ofs[i][j][k] /= ofs[i][j][number];
	    }
	  for(k=1; k<COHORT_SIZE; k++)
	    ofs[i][j][k] += bpoints[i][j][k];
	}
    }
#endif // (POPULATION_NR > 0)

  return;
}




/*==============================================================================*/

double	  IntegrationStep(double del_tim, double del_max, int recurs)

  /* 
   * IntegrationStep - Performs an integration with adaptable step size but 
   *                   maximum "del_max". Step size control and event
   *                   location as implemented by E. Hairer & G. Wanner.
   */
  
{
  register int		i;
  double		del_h;
  double		err, err0, sk, sqr, maxsqr;
  double		fac, fac11, hnew;
  double		yd0, ydiff, bspl;
  double		stnum, stden;
  int			adjust = 1, events = 0, intermediate = 0, maxerri;
#if (EVENT_NR > 0)
  int			dolocation[EVENT_NR];
#endif

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
  LocatedEvent = -1;

  if (EBTDEBUG(4))
    {
      fprintf(dbgfil, "%-18s T = %15.8f     dt = %12.7E recurs = %2d\n",
	      "Starting step:", env[0], del_h, recurs);
      fflush(dbgfil);
    }

  dopri5(del_h);				/* Do an integration step   */

  err = 0.0; maxsqr = 0.0; maxerri = 0;		/* error estimation         */
  for (i = 0; i < SystemSize; i++)
    {
      sk   = ABS_ERR + accuracy * max (fabs(y[i]), fabs(yy1[i]));
      sqr  = k4[i] / sk;
      if (sqr > maxsqr)
	{
	  maxsqr  = sqr;
	  maxerri = i;
	}
      err += sqr*sqr;
    }
  err0 = err;
  err = sqrt (err / (double)SystemSize);

  if (err > 1.0)				/* Step rejected            */
    {
      if (EBTDEBUG(3))
	{
	  fprintf(dbgfil, "%-18s T = %15.8f     dt = %12.7E recurs = %2d Largest error contribution in ODE #%d (%.3f%%)\n",
		  "Step failed:", env[0], del_h, recur_no, maxerri, 100*maxsqr*maxsqr/err0);
	  fflush(dbgfil);
	}

      /*
       * If bigger than accuracy take smaller step and restart
       */
      recur_no++; step_failed=1;
      if (recur_no > 25)
	{
#if (POPULATION_NR > 0)
	  TransBcohorts();
#endif // (POPULATION_NR > 0)
	  ErrorExit(0, REC);
	}

      fac11  = pow (err, 0.2 - BETA * 0.75);
      del_h /= min (FACC1, fac11/SAFETY);

      step_size = del_h;
      del_h  = IntegrationStep(del_h, del_max, recur_no);
    }
  else						/* Step accepted            */
    {
      if (EBTDEBUG(4))
	{
	  fprintf(dbgfil, "%-18s T = %15.8f     dt = %12.7E recurs = %2d\n",
		  "Step OK:", env[0], del_h, recur_no);
	  fflush(dbgfil);
	}

      /*
       * Step size adjustment using Lund-stabilization: we require
       * 		fac1 <=  hnew/h <= fac2
       * No increase if failed just before
       */
      if (adjust && !step_failed)
	{
	  fac11  = pow (err, 0.2 - BETA * 0.75);
	  fac    = fac11/pow(facold, BETA);
	  fac    = max(FACC2, min(FACC1, fac/SAFETY));
	  hnew   = del_h / fac;
	  facold = max (err, FACOLD);

	  step_size = min(hnew, cohort_limit);
	  step_size = min(step_size, LARGEST_STEP);
	}
      step_failed=0;
      accepted_steps++;
      
      if (EBTDEBUG(1))
	{
	  /*
	   * Do some stiffness detection at regular intervals
	   */
	  if (!(accepted_steps % NSTIFF) || (iasti > 0))
	    {
	      stnum = 0.0;
	      stden = 0.0;
	      for (i = 0; i < SystemSize; i++)
		{
		  sqr    = k2[i] - k6[i];
		  stnum += sqr*sqr;
		  sqr    = yy1[i] - ysti[i];
		  stden += sqr*sqr;
		}
	      if (stden > 0.0)
		hlamb = del_h * sqrt (stnum / stden);
	      if (hlamb > 3.25)
		{
		  nonsti = 0;
		  iasti++;
		  if (iasti == 15)
		    (void)fprintf(dbgfil,
				  "The problem is becoming stiff at T = %.4f\n",
				  env[0]);
		}
	      else
		{
		  nonsti++;
		  if (nonsti == 6) iasti = 0;
		}
	    }
	}

      /* 
       * Location of events: If located in previous and no change in ELvalue do
       * not locate.
       * WARNING: The order of these statements seems odd but is OK! What is
       * 	  checked is whether the newELvalue from before cohort closure
       *	  equals the value computed at the beginning of this time
       *	  integration step!
       */
#if (EVENT_NR > 0)
      for(i=0; i<EVENT_NR; i++)
	{
	  dolocation[i] = 1;
	  if (located[i] && isequal(oldELvalue[i], newELvalue[i]))
	    dolocation[i] = 0;
	}
      
      for (i=0; i<EVENT_NR; i++) newELvalue[i] = NO_EVENT;
      EventLocation(yy1, u_pop, u_ofs, bpoints, newELvalue);

      for(i=0, events=0; i<EVENT_NR; i++)
	{
	  if (((oldELvalue[i] < 0.0) && (newELvalue[i] < 0.0)) ||
	      ((oldELvalue[i] > 0.0) && (newELvalue[i] > 0.0)))
	    dolocation[i] = 0;
	  if (dolocation[i]) events++;
	}
#endif

      intermediate = ((next_output < (yy1[0]-identical_zero)) ||
		      ((state_out > 0.0) &&
		       (next_state_output < (yy1[0]-identical_zero))));

      if (events || intermediate)
	{
	  /*
	   * Update variables for event location and continuous output
	   */
	  for (i = 0; i < SystemSize; i++)
	    {
	      yd0 = y[i];
	      ydiff = yy1[i] - yd0;
	      bspl = del_h * k1[i] - ydiff;
	      rcont1[i] = y[i];
	      rcont2[i] = ydiff;
	      rcont3[i] = bspl;
	      rcont4[i] = -del_h * k2[i] + ydiff - bspl;
	    }
	}
      
#if (EVENT_NR > 0)
      if (events) LocateEvent(del_h, dolocation, located);
      else for(i=0; i<EVENT_NR; i++) located[i] = 0;
#endif

      /*
       * Produce intermediate output and state output if requested
       */
      if (intermediate)
	{
#if (POPULATION_NR > 0)
	  for(i=0; i<POPULATION_NR; i++) CohortNo[i] += BpointNo[i];
#endif // (POPULATION_NR > 0)
	  while (next_output < (yy1[0]-identical_zero))
	    {
	      IntermediateState((next_output-y[0])/del_h);
	      FileOut();
	      next_output += delt_out;
	    }
#if (POPULATION_NR > 0)
	  while ((state_out > 0.0) && (next_state_output < (yy1[0]-identical_zero)))
	    {
	      IntermediateState((next_state_output-y[0])/del_h);
	      FileState();
	      next_state_output += state_out;
	    }
	  for(i=0; i<POPULATION_NR; i++) CohortNo[i] -= BpointNo[i];
	  for(i=0; i<POPULATION_NR; i++) cohort_no[i] = CohortNo[i];
#endif // (POPULATION_NR > 0)
	}

      /*
       * Update the basic data copy, and the local copy 
       */
      (void)memcpy((DEF_TYPE *)env, (DEF_TYPE *)yy1, ENVIRON_DIM*sizeof(double));

#if (POPULATION_NR > 0)
      int		len;

      len = ENVIRON_DIM;
      for(i=0; i<POPULATION_NR; i++)
	{
	  (void)memcpy((DEF_TYPE *)pop[i], (DEF_TYPE *)(yy1+len),
		       (table_size[i]*COHORT_SIZE)*sizeof(double));
	  len += (table_size[i]*COHORT_SIZE);
	}
#endif // (POPULATION_NR > 0)

      (void)memcpy((DEF_TYPE *)y, (DEF_TYPE *)yy1, SystemSize*sizeof(double));
    }

  return del_h;
}



/*==========================================================================*/
