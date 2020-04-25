/***
   NAME
     ebtradau
   DESCRIPTION
     This file contains the specification of the implicit RADAU5 method with
     step size control and dense output for the actual time integration of the
     ODEs in the Escalator Boxcar Train program. This method is used here
     especially for event location and problems with algebraic restriction
     conditions. 
     The code is translated from the original Fortran source code, written by

		E. Hairer & G. Wanner
		Universite de Geneve, dept. de Mathematiques
		CH-1211 GENEVE 4, SWITZERLAND
		E-mail : HAIRER@DIVSUN.UNIGE.CH, WANNER@DIVSUN.UNIGE.CH

     The code is described in : E. Hairer, S.P. Norsett and G. Wanner, Solving
     ordinary differential equations II, Stiff and Differential-Algebraic
     problems, 2nd edition, Springer Series in Computational Mathematics,
     Springer-Verlag (1996).
     
   Last modification: AMdR - Jan 07, 2012
***/
#ifndef EBTRADAU
#define EBTRADAU
#endif

#ifndef RADAU_TEST
#define RADAU_TEST	0
#endif


/*==========================================================================*/
/*
 * Defining all constants that are local to this specific file.
 */
/*==========================================================================*/
/*
 * Return codes
 */
#define SUCCESS		0
#define BAD_CONVERGENCE	10101
#define NO_CONVERGENCE	10102
#define SINGULARITY	10103
#define MAX_ITERATIONS	10104

/*
 * Constants in method
 */
#define THET	0.001		/* Decides when Jacobian is recomputed      */
#define NIT	7		/* Maximum number of newton iterations      */
#define UROUND	1.0E-16		/* Smallest value satisfying 1.0+UROUND>1.0 */
#define SAFE	0.9		/* Safety factor in step size prediction    */
#define FACL	5.0		/* Parameters for step size selection       */
#define FACR	0.125		/* Default: FACL = 5.0; FACR = 0.125        */
#define QUOT1	1.0		/* If QUOT1 < HNEW/HOLD < QUOT2, step size  */
#define QUOT2	1.2		/* is not changed.                          */
#define JACSTEP 1.0E-5		/* Step size for Jacobian computation       */
#define INIT_H	1.0E-2		/* Initial stepsize when restarting         */
#define ABS_ERR	1.0E-13



/*==========================================================================*/
/*
 * The error messages that occur in the routines in the present file.
 */

#define MAFO "Memory allocation failure in ODE integration routine!"
#define REC  "Too many recursions in integration to find suitable stepsize!"
#define SSS  "Step size in integration routine too small!"
#define SIN  "Matrix is repeatedly singular in radau5()!"
#define ZBB  "Root is not bracketed in ZBRENT!"
#define ZBM  "Maximum number of iterations exceeded in ZBRENT!"


/*==========================================================================*/
/*
 * Definitions of static variables, restricted to this file.
 */

static int		step_failed=0, recur_no;
static long		ODEAllocated = 0L, SystemSize, JacobianSize;

static double		*y      = NULL, *yy1    = NULL, *yy2    = NULL;
static double		*Jac    = NULL, *scal   = NULL, *z0     = NULL;
static double		*E1     = NULL, *E2R    = NULL, *E2I    = NULL;
static double		*z1     = NULL, *z2     = NULL, *z3     = NULL;
static double		*f1     = NULL, *f2     = NULL, *f3     = NULL;
static double		*rcont1 = NULL, *rcont2 = NULL, *rcont3 = NULL;
static int		*daes   = NULL, *ip1    = NULL, *ip2    = NULL;

#if (POPULATION_NR > 0)
static population	u_pop1[POPULATION_NR], 	   u_ofs1[POPULATION_NR];
static population	u_pop2[POPULATION_NR], 	   u_ofs2[POPULATION_NR];

static population_index	i_pop1[POPULATION_NR], 	   i_ofs1[POPULATION_NR];

static population	u_popgrad0[POPULATION_NR], u_ofsgrad0[POPULATION_NR];
static population	u_popgrad1[POPULATION_NR], u_ofsgrad1[POPULATION_NR];
static population	u_popgrad2[POPULATION_NR], u_ofsgrad2[POPULATION_NR];
static population	u_popgrad3[POPULATION_NR], u_ofsgrad3[POPULATION_NR];
static population	u_popgrad4[POPULATION_NR], u_ofsgrad4[POPULATION_NR];
#else
static population	*bpoints = NULL;
static population	*u_pop1 = NULL,     *u_ofs1 = NULL;
static population	*u_pop2 = NULL,     *u_ofs2 = NULL;

static population	*u_popgrad0 = NULL, *u_ofsgrad0 = NULL;
static population	*u_popgrad1 = NULL, *u_ofsgrad1 = NULL;
static population	*u_popgrad2 = NULL, *u_ofsgrad2 = NULL;
static population	*u_popgrad3 = NULL, *u_ofsgrad3 = NULL;
static population	*u_popgrad4 = NULL, *u_ofsgrad4 = NULL;
#endif // (POPULATION_NR > 0)

static const double	_c1    =    .15505102572168219018,
			_c2    =    .64494897427831780982,
			_c1m1  =   -.84494897427831780982,
			_c2m1  =   -.35505102572168219018,
			_c1mc2 =   -.48989794855663561964,
			_dd1   = -10.048809399827415562,
			_dd2   =   1.3821427331607488958,
			_dd3   =   -.33333333333333333333,
			_u1    =   3.6378342527444957322,
			_alph  =   2.6810828736277521338,
			_beta  =   3.0504301992474105693;
  
static const double	_t11  =   .091232394870892942792,
			_t12  =  -.14125529502095420843,
			_t13  =  -.030029194105147424492,
			_t21  =   .24171793270710701896,
			_t22  =   .20412935229379993199,
			_t23  =   .38294211275726193779,
			_t31  =   .96604818261509293619,
			_ti11 =  4.325579890063155351,
			_ti12 =   .33919925181580986954,
			_ti13 =   .54177053993587487119,
			_ti21 = -4.1787185915519047273,
			_ti22 =  -.32768282076106238708,
			_ti23 =   .47662355450055045196,
			_ti31 =  -.50287263494578687595,
			_ti32 =  2.5719269498556054292,
			_ti33 =  -.59603920482822492497;

static int		start_new = 1, jac_new = 1, caljac = 0, dec_new = 1;
static int		newt = 0;
static int		nfcn = 0, njac = 0, ndec = 0, nsol = 0, nsing = 0;
static int		naccpt = 0, nrejct = 0;
static double		faccon, theta, hhfac, erracc, hacc;
static double		dynold, thqold;
static double		dtold = 0.0;
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
  int				org, len;

  SystemSize    = ENVIRON_DIM;
#if (POPULATION_NR > 0)
  register int			i;

  for(i=0; i<POPULATION_NR; i++)
    SystemSize   += (CohortNo[i]+BpointNo[i])*COHORT_SIZE;
#endif // (POPULATION_NR > 0)
  JacobianSize = SystemSize*SystemSize;

  if (!(SystemSize < ODEAllocated))
    {
      ODEAllocated = MemBlocks(SystemSize);
      y    = (double *)Myalloc((void *)y, (size_t)ODEAllocated,
			       sizeof(double));
      yy1  = (double *)Myalloc((void *)yy1, (size_t)ODEAllocated,
			       sizeof(double));
      yy2  = (double *)Myalloc((void *)yy2, (size_t)ODEAllocated,
			       sizeof(double));
      Jac  = (double *)Myalloc((void *)Jac, (size_t)(ODEAllocated*ODEAllocated),
			       sizeof(double));
      E1   = (double *)Myalloc((void *)E1, (size_t)(ODEAllocated*ODEAllocated),
			       sizeof(double));
      E2R  = (double *)Myalloc((void *)E2R, (size_t)(ODEAllocated*ODEAllocated),
			       sizeof(double));
      E2I  = (double *)Myalloc((void *)E2I, (size_t)(ODEAllocated*ODEAllocated),
			       sizeof(double));
      scal = (double *)Myalloc((void *)scal, (size_t)ODEAllocated,
			       sizeof(double));
      daes = (int *)   Myalloc((void *)daes, (size_t)ODEAllocated,
			       sizeof(int));
      ip1  = (int *)   Myalloc((void *)ip1, (size_t)ODEAllocated,
			       sizeof(int));
      ip2  = (int *)   Myalloc((void *)ip2, (size_t)ODEAllocated,
			       sizeof(int));
      z0   = (double *)Myalloc((void *)z0, (size_t)ODEAllocated,
			       sizeof(double));
      z1   = (double *)Myalloc((void *)z1, (size_t)ODEAllocated,
			       sizeof(double));
      z2   = (double *)Myalloc((void *)z2, (size_t)ODEAllocated,
			       sizeof(double));
      z3   = (double *)Myalloc((void *)z3, (size_t)ODEAllocated,
			       sizeof(double));
      f1   = (double *)Myalloc((void *)f1, (size_t)ODEAllocated,
			       sizeof(double));
      f2   = (double *)Myalloc((void *)f2, (size_t)ODEAllocated,
			       sizeof(double));
      f3   = (double *)Myalloc((void *)f3, (size_t)ODEAllocated,
			       sizeof(double));
      rcont1  = (double *)Myalloc((void *)rcont1, (size_t)ODEAllocated,
				  sizeof(double));
      rcont2  = (double *)Myalloc((void *)rcont2, (size_t)ODEAllocated,
				  sizeof(double));
      rcont3  = (double *)Myalloc((void *)rcont3, (size_t)ODEAllocated,
				  sizeof(double));
      if(!(y && yy1 && yy2 && Jac && E1 && E2R && E2I && scal &&
	   daes && ip1 && ip2 && z0 && z1 && z2 && z3 && f1 && f2 && f3 &&
	   rcont1 && rcont2 && rcont3))
	ErrorAbort(MAFO);
#if RADAU_TEST
      start_new = 1;
      jac_new = 1;
      dec_new = 1;
      nsing = 0;
      step_size = 1.0E-6;
      faccon = 1.0;
#endif
    }

#if (!RADAU_TEST)
  start_new = 1;
  jac_new = 1;
  dec_new = 1;
  nsing = 0;
  step_size = INIT_H;
  faccon = 1.0;
#endif

  org = 0;
  len = ENVIRON_DIM;				/* Copy environment vars.   */
  (void)memcpy((DEF_TYPE *)y, (DEF_TYPE *)env, len*sizeof(double));
  
#if (POPULATION_NR > 0)
  for(i=0; i<POPULATION_NR; i++)
    {
      org += len;
      len  = (BpointNo[i]*COHORT_SIZE);
      (void)memcpy((DEF_TYPE *)(y+org), (DEF_TYPE *)ofs[i], len*sizeof(double));
      u_ofs1[i] = (population)(yy1+org);
      u_ofs2[i] = (population)(yy2+org);
      
      i_ofs1[i] = (population_index)(daes+org);

      u_ofsgrad0[i] = (population)(z0+org);
      u_ofsgrad1[i] = (population)(z1+org);
      u_ofsgrad2[i] = (population)(z2+org);
      u_ofsgrad3[i] = (population)(z3+org);

      u_ofsgrad4[i] = (population)(f1+org);
    }

  for(i=0; i<POPULATION_NR; i++)
    {
      org += len;
      len  = (CohortNo[i]*COHORT_SIZE);
      (void)memcpy((DEF_TYPE *)(y+org), (DEF_TYPE *)pop[i], len*sizeof(double));
      u_pop1[i] = (population)(yy1+org);
      u_pop2[i] = (population)(yy2+org);
      
      i_pop1[i] = (population_index)(daes+org);

      u_popgrad0[i] = (population)(z0+org);
      u_popgrad1[i] = (population)(z1+org);
      u_popgrad2[i] = (population)(z2+org);
      u_popgrad3[i] = (population)(z3+org);

      u_popgrad4[i] = (population)(f1+org);
    }
#endif // (POPULATION_NR > 0)

  /*
   * Here I should set all entries in daes[] to 1 that represent algebraic
   * equations.
   */

  (void)memset((DEF_TYPE *)daes, 0, (size_t)(ODEAllocated*sizeof(int)));

  return;
}




/*==============================================================================*/

static int 	dec(int dimM, double *M, int *perm, int *sign)

  /**
     NAME:
	dec
     NOTES:
	MATRIX TRIANGULARIZATION BY GAUSSIAN ELIMINATION.

	INPUT..
		dimM = DIMENSION OF MATRIX.
		M    = MATRIX TO BE TRIANGULARIZED.
	OUTPUT..
		M(I,J),  I.LE.J = UPPER TRIANGULAR FACTOR, U .
		M(I,J),  I.GT.J = MULTIPLIERS = LOWER TRIANGULAR FACTOR, I - L.
		perm(K), K.LT.N = INDEX OF K-TH PIVOT ROW.
		sign = (-1)**(NUMBER OF INTERCHANGES) OR O.
	RETURNS..
		RETURN = 0 IF MATRIX M IS NONSINGULAR, OR `SINGULARITY'

	USE  SOL  TO OBTAIN SOLUTION OF LINEAR SYSTEM.
	DETERM(M) = sign*M(1,1)*M(2,2)*...*M(N,N).
	IF sign=O, M IS SINGULAR, SOL WILL DIVIDE BY ZERO.

  REFERENCE..
     C. B. MOLER, ALGORITHM 423, LINEAR EQUATION SOLVER,
     C.A.C.M. 15 (1972), P. 274.
  
**/

{
  register int		i, j, k, m;
  int			nm1, kp1;
  double		T;
  
  *sign = 1;
  nm1 = dimM - 1;
  for (k = 0; k < nm1; k++)
    {
      kp1 = k + 1;
      m = k;
      for (i = kp1; i < dimM; i++)
	if (fabs(M[i*dimM+k]) > fabs(M[m*dimM+k])) m = i;
      perm[k] = m;
      T = M[m*dimM+k];
      if (m != k)
	{
	  *sign = -(*sign);
	  M[m*dimM+k] = M[k*dimM+k];
	  M[k*dimM+k] = T;
	}
      if (fabs(T) < UROUND)
	{
	  *sign = 0;
	  return SINGULARITY;
	}

      T = -1.0/T;
      for (i = kp1; i < dimM; i++) M[i*dimM+k] *= T;

      for (j = kp1; j < dimM; j++)
	{
	  T = M[m*dimM+j];
	  M[m*dimM+j] = M[k*dimM+j];
	  M[k*dimM+j] = T;
	  if (fabs(T) < UROUND) continue;
	  for (i = kp1; i < dimM; i++) M[i*dimM+j] += M[i*dimM+k]*T;
	}
    }

  if (fabs(M[dimM*dimM-1]) < UROUND)
    {
      *sign = 0;
      return SINGULARITY;
    }
  
  return 0;
} /* dec */




/*==============================================================================*/

static int 	decc(int dimM, double *MR, double *MI, int *perm, int *sign)

  /**
     NAME:
	decc
     NOTES:
	MATRIX TRIANGULARIZATION BY GAUSSIAN ELIMINATION.
	------ MODIFICATION FOR COMPLEX MATRICES --------

	INPUT..
		dimM   = DIMENSION OF MATRIX.
		MR, MI = MATRIX TO BE TRIANGULARIZED.
	OUTPUT..
		MR(I,J),  I.LE.J = UPPER TRIANGULAR FACTOR, U; REAL PART.
		MI(I,J),  I.LE.J = UPPER TRIANGULAR FACTOR, U; IMAGINARY PART.
		MR(I,J),  I.GT.J = MULTIPLIERS = LOWER TRIANGULAR FACTOR, I - L.
							       REAL PART.
		MI(I,J),  I.GT.J = MULTIPLIERS = LOWER TRIANGULAR FACTOR, I - L.
							       IMAGINARY PART.
		perm(K), K.LT.N = INDEX OF K-TH PIVOT ROW.
		sign = (-1)**(NUMBER OF INTERCHANGES) OR O.
	RETURNS..
		RETURN = 0 IF MATRIX M IS NONSINGULAR, OR `SINGULARITY'

	USE  SOLC  TO OBTAIN SOLUTION OF LINEAR SYSTEM.
	IF sign=O, M IS SINGULAR, SOL WILL DIVIDE BY ZERO.

  REFERENCE..
     C. B. MOLER, ALGORITHM 423, LINEAR EQUATION SOLVER,
     C.A.C.M. 15 (1972), P. 274.
  
**/

{
  register int		i, j, k, m;
  int			nm1, kp1;
  double		TR, TI, PRODR, PRODI, DEN;
  
  *sign = 1;
  nm1 = dimM - 1;
  for (k = 0; k < nm1; k++)
    {
      kp1 = k + 1;
      m = k;
      for (i = kp1; i < dimM; i++)
	if ((fabs(MR[i*dimM+k])+fabs(MI[i*dimM+k])) >
	    (fabs(MR[m*dimM+k])+fabs(MI[m*dimM+k]))) m = i;
      perm[k] = m;
      TR = MR[m*dimM+k];
      TI = MI[m*dimM+k];
      if (m != k)
	{
	  *sign = -(*sign);
	  MR[m*dimM+k] = MR[k*dimM+k];
	  MI[m*dimM+k] = MI[k*dimM+k];
	  MR[k*dimM+k] = TR;
	  MI[k*dimM+k] = TI;
	}
      if ((fabs(TR)+fabs(TI)) < UROUND)
	{
	  *sign = 0;
	  return SINGULARITY;
	}

      DEN = TR*TR+TI*TI;
      TR /=  DEN;
      TI /= -DEN;
      for (i = kp1; i < dimM; i++)
	{
	  PRODR = MR[i*dimM+k]*TR - MI[i*dimM+k]*TI;
	  PRODI = MI[i*dimM+k]*TR + MR[i*dimM+k]*TI;
	  MR[i*dimM+k] = -PRODR;
	  MI[i*dimM+k] = -PRODI;
	}
      for (j = kp1; j < dimM; j++)
	{
	  TR = MR[m*dimM+j];
	  TI = MI[m*dimM+j];
	  MR[m*dimM+j] = MR[k*dimM+j];
	  MI[m*dimM+j] = MI[k*dimM+j];
	  MR[k*dimM+j] = TR;
	  MI[k*dimM+j] = TI;
	  if ((fabs(TR)+fabs(TI)) < UROUND) continue;
	  else
	    {
	      for (i = kp1; i < dimM; i++)
		{
		  PRODR = MR[i*dimM+k]*TR - MI[i*dimM+k]*TI;
		  PRODI = MI[i*dimM+k]*TR + MR[i*dimM+k]*TI;
		  MR[i*dimM+j] += PRODR;
		  MI[i*dimM+j] += PRODI;
		}
	    }
	}
    }

  if ((fabs(MR[dimM*dimM-1])+fabs(MI[dimM*dimM-1])) < UROUND)
    {
      *sign = 0;
      return SINGULARITY;
    }
  
  return 0;
} /* decc */




/*==============================================================================*/

static void 	sol(int dimM, double *M, double *V, int *perm)

  /**
     NAME:
	sol
     NOTES:
	SOLUTION OF LINEAR SYSTEM, M*X = V.

     INPUT..
	dimM = ORDER OF MATRIX.
	M    = TRIANGULARIZED MATRIX OBTAINED FROM DEC.
	V    = RIGHT HAND SIDE VECTOR.
	perm = PIVOT VECTOR OBTAINED FROM DEC.

	DO NOT USE IF DEC HAS RETURNED A SINGULARITY

     OUTPUT..
	V    = SOLUTION VECTOR, X.
**/

{
  register int		i, j, k, m;
  int			kp1, km1, nm1;
  double 		T;
  
  nm1 = dimM - 1;
  for (k = 0; k < nm1; k++)
    {
      kp1 = k + 1;
      m = perm[k];
      T = V[m];
      V[m] = V[k];
      V[k] = T;
      for (i = kp1; i < dimM; i++) V[i] += M[i*dimM+k]*T;
    }
  for (j = 0; j < nm1; j++)
    {
      km1 = dimM - 1 - j;
      k   = km1;
      V[k] /= M[k*dimM+k];
      T = -V[k];
      for (i = 0; i < km1; i++) V[i] += M[i*dimM+k]*T;
    }
  *V /= *M;
  
  return;
} /* sol */





/*==============================================================================*/

static void 	solc(int dimM, double *MR, double *MI, double *VR, double *VI,
		     int *perm)

  /**
     NAME:
	solc
     NOTES:
	SOLUTION OF LINEAR SYSTEM, M*X = V.
	------ MODIFICATION FOR COMPLEX MATRICES --------
     INPUT..
	dimM   = ORDER OF MATRIX.
	MR, MI = TRIANGULARIZED MATRIX OBTAINED FROM DECC.
	VR, VI = RIGHT HAND SIDE VECTOR.
	perm   = PIVOT VECTOR OBTAINED FROM DECC.

	DO NOT USE IF DECC HAS RETURNED A SINGULARITY

     OUTPUT..
	VR, VI = SOLUTION VECTOR, X.
**/

{
  register int		i, j, k, m;
  int			kp1, km1, nm1;
  double 		TR, TI, PRODR, PRODI, DEN;
  
  nm1 = dimM - 1;
  for (k = 0; k < nm1; k++)
    {
      kp1 = k + 1;
      m = perm[k];
      TR    = VR[m];
      TI    = VI[m];
      VR[m] = VR[k];
      VI[m] = VI[k];
      VR[k] = TR;
      VI[k] = TI;
      for (i = kp1; i < dimM; i++)
	{
	  PRODR  = MR[i*dimM+k]*TR - MI[i*dimM+k]*TI;
	  PRODI  = MI[i*dimM+k]*TR + MR[i*dimM+k]*TI;
	  VR[i] += PRODR;
	  VI[i] += PRODI;
	}
    }
  for (j = 0; j < nm1; j++)
    {
      km1   = dimM - 1 - j;
      k     = km1;
      DEN   = MR[k*dimM+k]*MR[k*dimM+k] + MI[k*dimM+k]*MI[k*dimM+k];
      PRODR = VR[k]*MR[k*dimM+k] + VI[k]*MI[k*dimM+k];
      PRODI = VI[k]*MR[k*dimM+k] - VR[k]*MI[k*dimM+k];
      VR[k] = PRODR/DEN;
      VI[k] = PRODI/DEN;
      TR    = -VR[k];
      TI    = -VI[k];
      for (i = 0; i < km1; i++)
	{
	  PRODR  = MR[i*dimM+k]*TR - MI[i*dimM+k]*TI;
	  PRODI  = MI[i*dimM+k]*TR + MR[i*dimM+k]*TI;
	  VR[i] += PRODR;
	  VI[i] += PRODI;
	}
    }
  DEN   = (*MR)*(*MR) + (*MI)*(*MI);
  PRODR = (*VR)*(*MR) + (*VI)*(*MI);
  PRODI = (*VI)*(*MR) - (*VR)*(*MI);
  *VR   = PRODR/DEN;
  *VI   = PRODI/DEN;
  
  return;
} /* solc */





/*==============================================================================*/

static int   rad_core(double dt, int jn, int dn)

  /* 
   * rad_core - Routine performs an integration step of the system using the
   *	        RADAU5 integration method. The code is translated from the
   *	        Fortran source code by E. Hairer & G. Wanner.
   */

{
  register int		i, j;
  int			error = 0, done = 0;
  int			signE1, signE2;
  double		ysafe, delt;
  double		_hv1, _hv2, _hv3;
  double		fac1, alphn, betan;
  double		c1q, c2q, c3q = 1.0;
  double		dyn, dyth, thq, qnewt, fnewt;

  _hv1 = 0.1*pow(accuracy, 2.0/3.0);
  fnewt= max(10*UROUND/_hv1, min(0.03, pow(_hv1, 0.5)));

						/* Don't do first deriva-   */
  if(!recur_no)					/* tive if already present  */
    {
      (void)memcpy((DEF_TYPE *)yy1, (DEF_TYPE *)y, SystemSize*sizeof(double));
      rk_level = 1;
      hhfac = dt;
      Gradient(yy1, u_pop1, u_ofs1, z0, u_popgrad0, u_ofsgrad0, bpoints);
      nfcn++;
#if (EVENT_NR > 0)
      for (i=0; i<EVENT_NR; i++) oldELvalue[i] = NO_EVENT;
      EventLocation(yy1, u_pop1, u_ofs1, bpoints, oldELvalue);
#endif
    }

  /* 
   * Compute the Jacobian
   */
  if (jn)
    {
#if RADAU_TEST
      Jac[0] = 0.0; Jac[1] = 0.0; Jac[2] = 0.0; 
      Jac[3] = 0.0; Jac[4] = 0.0; Jac[5] = 1.0; 
      Jac[6] = 0.0; 
      Jac[7] = (-2.0*yy1[1]*yy1[2]-1.0)/(1.0E-6);
      Jac[8] = (1.0-yy1[1]*yy1[1])/(1.0E-6);
#else
      for (i = 0; i < SystemSize; i++)
	{
	  ysafe  = yy1[i];
	  delt   = sqrt(UROUND * max(JACSTEP, fabs(ysafe)));
	  yy1[i] = ysafe + delt;
	  Gradient(yy1, u_pop1, u_ofs1, yy2, u_pop2, u_ofs2, bpoints);
	  nfcn++;
	  for (j = 0; j < SystemSize; j++)
	    Jac[j*SystemSize+i] = (yy2[j] - z0[j]) / delt;
	  yy1[i] = ysafe;
	}
#endif
      njac++;
      caljac = 1;
    }
  /*
   * LU decompose of the E1 and E2 matrices
   */
  fac1  = _u1/dt;
  alphn = _alph/dt;
  betan = _beta/dt;

  if (jn || dn)
    {
      for (i = 0; i < JacobianSize; i++) E1[i] = -Jac[i];

      (void)memcpy((DEF_TYPE *)E2R, (DEF_TYPE *)E1, JacobianSize*sizeof(double));
      (void)memset((DEF_TYPE *)E2I, 0, (size_t)(JacobianSize*sizeof(double)));

      for (i = 0; i < SystemSize; i++)
	{
	  if (daes[i]) continue;
	  j = i*SystemSize+i;
	  E1[j]  += fac1;
	  E2R[j] += alphn;
	  E2I[j] += betan;
	}

      error = dec(SystemSize, E1, ip1, &signE1);
      if (error) return SINGULARITY;

      error = decc(SystemSize, E2R, E2I, ip2, &signE2);
      if (error) return SINGULARITY;
      ndec++;
    }
  
  /*
   *  Starting values for the newton iterations
   */
  if (start_new)
    {
      c3q = dt;
      c1q = _c1*c3q;
      c2q = _c2*c3q;
      for (i = 0; i < SystemSize; i++)
	{
	  if (daes[i])
	    {
	      z1[i] = 0.0;
	      z2[i] = 0.0;
	      z3[i] = 0.0;
	    }
	  else
	    {
	      z1[i] = c1q*z0[i];
	      z2[i] = c2q*z0[i];
	      z3[i] = c3q*z0[i];
	    }
	}
    }
  else
    {
      c3q = dt/dtold;
      c1q = _c1*c3q;
      c2q = _c2*c3q;
      for (i = 0; i < SystemSize; i++)
	{
	  _hv1 = rcont1[i];
	  _hv2 = rcont2[i];
	  _hv3 = rcont3[i];
	  z1[i] = c1q*(_hv1+(c1q - _c2m1)*(_hv2+(c1q - _c1m1)*_hv3));
	  z2[i] = c2q*(_hv1+(c2q - _c2m1)*(_hv2+(c2q - _c1m1)*_hv3));
	  z3[i] = c3q*(_hv1+(c3q - _c2m1)*(_hv2+(c3q - _c1m1)*_hv3));
	}
    }

  for (i = 0; i < SystemSize; i++)
    {
      _hv1 = z1[i];
      _hv2 = z2[i];
      _hv3 = z3[i];
      f1[i] = _ti11*_hv1+_ti12*_hv2+_ti13*_hv3;
      f2[i] = _ti21*_hv1+_ti22*_hv2+_ti23*_hv3;
      f3[i] = _ti31*_hv1+_ti32*_hv2+_ti33*_hv3;
    }

  faccon = pow(max(faccon, UROUND), 0.8);
  theta  = fabs(THET);
  
  for (newt = 0; (!done) && (newt < NIT); newt++)
    {
      for (i = 0; i < SystemSize; i++) yy2[i] = yy1[i] + z1[i];
      Gradient(yy2, u_pop2, u_ofs2, z1, u_popgrad1, u_ofsgrad1, bpoints);

      for (i = 0; i < SystemSize; i++) yy2[i] = yy1[i] + z2[i];
      Gradient(yy2, u_pop2, u_ofs2, z2, u_popgrad2, u_ofsgrad2, bpoints);
	
      for (i = 0; i < SystemSize; i++) yy2[i] = yy1[i] + z3[i];
      Gradient(yy2, u_pop2, u_ofs2, z3, u_popgrad3, u_ofsgrad3, bpoints);
      nfcn +=3;
      
      for (i = 0; i < SystemSize; i++)
	{
	  _hv1 = z1[i];
	  _hv2 = z2[i];
	  _hv3 = z3[i];
	  z1[i] = _ti11*_hv1 + _ti12*_hv2 + _ti13*_hv3;
	  z2[i] = _ti21*_hv1 + _ti22*_hv2 + _ti23*_hv3;
	  z3[i] = _ti31*_hv1 + _ti32*_hv2 + _ti33*_hv3;
	}
      /*
       * Here we have to solve the linear system
       */
      for (i = 0; i < SystemSize; i++)
	{
	  if (daes[i]) continue;
	  _hv1 = -f1[i];
	  _hv2 = -f2[i];
	  _hv3 = -f3[i];
	  z1[i] += _hv1*fac1;
	  z2[i] += _hv2*alphn - _hv3*betan;
	  z3[i] += _hv3*alphn + _hv2*betan;
	}
      
      sol(SystemSize,  E1, z1, ip1);
      solc(SystemSize, E2R, E2I, z2, z3, ip2);
      nsol++;

      /*
       * Compute deviations
       */
      for (i = 1, dyn = 0.0; i < SystemSize; i++)
	dyn += (z1[i]*z1[i] + z2[i]*z2[i] + z3[i]*z3[i])/(scal[i]*scal[i]);
      dyn = sqrt(dyn/(3*(SystemSize-1)));

      /*
       * Here handle bad convergence or too many recursion steps
       */
      if (newt)
	{
	  thq = dyn/dynold;
	  if (newt == 1) theta = thq;
	  else theta = sqrt(thq*thqold);
	  thqold = thq;
	  if (theta < 0.99)
	    {
	      faccon = theta/(1.0-theta);
	      dyth = faccon * dyn * pow(theta, NIT-2-newt) / fnewt;
	      if (dyth >= 1.0)
		{
		  qnewt = max(1.0E-4, min(20.0, dyth));
		  hhfac = 0.8 * pow(qnewt, -1.0/(4.0+NIT-2-newt));
		  return BAD_CONVERGENCE;
		}
	      /*
	       * If dyth < 1.0 continue with Newton iterations
	       */
	    }
	  else return NO_CONVERGENCE;
	}
      dynold = max(dyn, UROUND);
      for (i = 0; i < SystemSize; i++)
	{
	  _hv1 = f1[i] + z1[i];
	  _hv2 = f2[i] + z2[i];
	  _hv3 = f3[i] + z3[i];
	  f1[i] = _hv1;
	  f2[i] = _hv2;
	  f3[i] = _hv3;
	  z1[i] = _t11*_hv1 + _t12*_hv2 + _t13*_hv3;
	  z2[i] = _t21*_hv1 + _t22*_hv2 + _t23*_hv3;
	  z3[i] = _t31*_hv1 +      _hv2;
	}
      done = ((faccon * dyn) < fnewt);
    }

  if (done) return SUCCESS;
  else return MAX_ITERATIONS;
} /* rad_core */




/*==============================================================================*/

static double	radau5(double h)

{
  int		error;
  double	del_h;
  char		msg[128];
  
  del_h = h;
  while (1)
    {						/* Do an integration step   */
      if (!(error = rad_core(del_h, jac_new, dec_new))) return del_h;
      switch (error)
	{
	case BAD_CONVERGENCE:
	  strcpy(msg, "Bad convergence");
	  recur_no++; step_failed = 1;
	  del_h *= hhfac;
	  break;
	case SINGULARITY:
	  strcpy(msg, "Singular matrix");
	  nsing++;
	  recur_no++; step_failed = 1;
	  hhfac  = 0.1;
	  del_h *= hhfac;
	  if (nsing > 5)
	    {
#if (POPULATION_NR > 0)
	      TransBcohorts();
#endif // (POPULATION_NR > 0)
	      ErrorExit(0, SIN);
	    }
	  break;
	case NO_CONVERGENCE:
	  strcpy(msg, "No convergence");
	  recur_no++; step_failed = 1;
	  hhfac  = 0.1;
	  del_h *= hhfac;
	  break;
	case MAX_ITERATIONS:
	  strcpy(msg, "Max. iterations");
	  recur_no++; step_failed = 1;
	  hhfac  = 0.1;
	  del_h *= hhfac;
	  break;
	default:
	  break;
	}
      jac_new = !caljac;
      dec_new = 1;

      if (EBTDEBUG(4))
	{
	  fprintf(dbgfil,
		  "%15s: T = %15.8f dt = %12.7E recurs = %2d\n",
		  msg, env[0], del_h, recur_no);
	  fflush(dbgfil);
	  fprintf(dbgfil, "Naccpt: %8d    Nrejct: %8d    Nfcn:  %8d    Njac: %8d\n",
		  naccpt, nrejct, nfcn, njac);
	  fprintf(dbgfil, "Ndec:   %8d    Nsol:   %8d    Nsing: %8d    Newt: %8d\n",
		  ndec, nsol, nsing, newt);
	  fflush(dbgfil);
	}
      if (recur_no > 25)
	{
#if (POPULATION_NR > 0)
	  TransBcohorts();
#endif // (POPULATION_NR > 0)
	  ErrorExit(0, REC);
	}
    }

  return del_h;
}




/*==============================================================================*/

static double	estrad(double h)

  /*
   * Routine estimates the local integration error
   */

{
  register int		i;
  double		_hv1, _hv2, _hv3;
  double		err = 0.0;
  
  _hv1 = _dd1/h;
  _hv2 = _dd2/h;
  _hv3 = _dd3/h;
  
  for (i = 0; i < SystemSize; i++)
    {
      f2[i]  = 0.0;
      if (!(daes[i]))
	f2[i]  = _hv1*z1[i] + _hv2*z2[i] + _hv3*z3[i];
      yy2[i] = f2[i] + z0[i];
    }
  sol(SystemSize, E1, yy2, ip1);
  
  for (i = 1, err = 0.0; i < SystemSize; i++)	/* Exclude the time here    */
    err += pow(yy2[i]/scal[i], 2.0);
  err = max(sqrt(err/(SystemSize-1)), MIN_ACCURACY);

  if ((err > 1.0) && (start_new || step_failed))
    {
      for (i = 0; i < SystemSize; i++) yy2[i] += yy1[i];
      Gradient(yy2, u_pop2, u_ofs2, f1, u_popgrad4, u_ofsgrad4, bpoints);
      nfcn++;
      for (i = 0; i < SystemSize; i++) yy2[i] = f1[i] + f2[i];
      sol(SystemSize, E1, yy2, ip1);

      for (i = 0, err = 0.0; i < SystemSize; i++)
	err += pow(yy2[i]/scal[i], 2.0);
      err = max(sqrt(err/SystemSize), MIN_ACCURACY);
    }

  return err;
}



/*==============================================================================*/
#if (EVENT_NR > 0)

static double 	delvalue(double theta, int eventindex)

{
  register int		i;
  double   		result[EVENT_NR];

  for (i = 0; i < SystemSize; i++)
    yy2[i] = yy1[i]
      +theta*(rcont1[i]+(theta-_c2m1)*(rcont2[i]+(theta-_c1m1)*rcont3[i]));

  for (i=0; i<EVENT_NR; i++) result[i] = NO_EVENT;
  EventLocation(yy2, u_pop2, u_ofs2, bpoints, result);
  
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

  a = -1.0; fa=olddel;
  b =  0.0; fb=newdel;

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
	  if ((stepfrac[i] > 0.0) || (stepfrac[i] < -1.0))
	    {
	      if (EBTDEBUG(1))
		{
		  (void)fprintf(dbgfil, "Problem locating event %d at T = %15.8f",
				i, yy1[0]);
		  (void)fprintf(dbgfil,	"  Start = %12.7E", oldELvalue[i]);
		  (void)fprintf(dbgfil,	"  Stop = %12.7E", newELvalue[i]);
		  (void)fprintf(dbgfil,	"  dt old = %12.7E", prev_dt);
		  (void)fprintf(dbgfil,	"  dt new = %12.7E\n",
				(1.0+stepfrac[index])*prev_dt);
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
  
  new_dt = prev_dt*(1.0+stepfrac[index]);

  /*  radau5(new_dt);		Use the continuous output state to continue */

  for (i = 0; i < SystemSize; i++)
    yy1[i] +=
      stepfrac[index]*(rcont1[i]+
		       (stepfrac[index]-_c2m1)*(rcont2[i]+
						(stepfrac[index]-_c1m1)*rcont3[i]));
  located[index] = 1;
  LocatedEvent = index;

  for (i=0; i<EVENT_NR; i++) newELvalue[i] = NO_EVENT;
  EventLocation(yy1, u_pop1, u_ofs1, bpoints, newELvalue);

  equal2zero = max(identical_zero,
		   pow(10, ceil(log10(fabs(newELvalue[index]) + ABS_ERR))));

  cohort_end = ForceCohortEnd(yy1, u_pop1, u_ofs1, bpoints);

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

static void	  IntermediateState(double S)

  /* 
   * IntermediateState - Routine computes the state of the system at an
   *			 intermediate time point by interpolation. 
   *			 Values are stored in basic data copy for further use
   *			 in output routines.
   */
  
{
  register int		i;
  int			org, len;
  
  for (i = 0; i < SystemSize; i++)
    yy2[i] = yy1[i]
      +S*(rcont1[i]+(S-_c2m1)*(rcont2[i]+(S-_c1m1)*rcont3[i]));
  org = 0; len = ENVIRON_DIM;
  (void)memcpy((DEF_TYPE *)env, (DEF_TYPE *)(yy2+org),
	       len*sizeof(double));

#if (POPULATION_NR > 0)
  register int		j, k;

  for(i=0; i<POPULATION_NR; i++)
    {
      org += len;
      len  = (BpointNo[i]*COHORT_SIZE);
      (void)memcpy((DEF_TYPE *)ofs[i], (DEF_TYPE *)(yy2+org),
		   len*sizeof(double));
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

  for(i=0; i<POPULATION_NR; i++)
    {
      org += len;
      len  = (CohortNo[i]*COHORT_SIZE);
      (void)memcpy((DEF_TYPE *)pop[i], (DEF_TYPE *)(yy2+org),
		   len*sizeof(double));
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
  double		err;
  double		fac, quot, facgus, hnew;
  double		_hv1, _hv2;
  int			org, len, adjust = 1, intermediate = 0;
#if (EVENT_NR > 0)
  int			dolocation[EVENT_NR], events = 0;
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

#if RADAU_TEST
  _hv1 = 0.1*pow(accuracy, 2.0/3.0);
  for (i = 0; i < SystemSize; i++)
    scal[i] = _hv1 + _hv1 * fabs(y[i]);
#else
  for (i = 0; i < SystemSize; i++)
    scal[i] = ABS_ERR + accuracy * fabs(y[i]);
#endif

  del_h = radau5(del_h);			/* integration step         */
  err = estrad(del_h);				/* error estimation         */

  if (err > 1.0)				/* Step rejected            */
    {
      nrejct++;
      if (EBTDEBUG(3))
	{
	  fprintf(dbgfil, "%-18s T = %15.8f     dt = %12.7E recurs = %2d\n",
		  "Step failed:", env[0], del_h, recur_no);
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

      fac  = min(SAFE, SAFE*(2*NIT+1)/(2*NIT+newt));
      quot = max(FACR, min(FACL, pow (err, 0.25)/fac));
      hnew = del_h/quot;
      if (start_new) hhfac  = 0.1;
      else hhfac = hnew/del_h;
      del_h *= hhfac;
      jac_new = !caljac;
	
      step_size = del_h;
      del_h  = IntegrationStep(del_h, del_max, recur_no);
    }
  else						/* Step accepted            */
    {
      naccpt++;
      if (EBTDEBUG(4))
	{
	  fprintf(dbgfil, "%-18s T = %15.8f     dt = %12.7E recurs = %2d\n",
		  "Step OK:", env[0], del_h, recur_no);
	  fprintf(dbgfil, "Naccpt: %8d    Nrejct: %8d    Nfcn:  %8d    Njac: %8d\n",
		  naccpt, nrejct, nfcn, njac);
	  fprintf(dbgfil, "Ndec:   %8d    Nsol:   %8d    Nsing: %8d    Newt: %8d\n",
		  ndec, nsol, nsing, newt);
	  fflush(dbgfil);
	}

      /*
       * Step size adjustment using Gustafsson controller, if not first cycle
       * step. No increase if failed just before 
       */
      fac   = min(SAFE, SAFE*(2*NIT+1)/(2*NIT+newt));
      quot  = max(FACR, min(FACL, pow (err, 0.25)/fac));
      hnew  = del_h/quot;
      dtold = del_h;
      if (!start_new)
	{
	  facgus = (hacc/del_h)*pow(err*err/erracc, 0.25)/SAFE;
	  facgus = max(FACR, min(FACL, facgus));
	  quot   = max(quot, facgus);
	  hnew   = del_h/quot;
	}
      hacc   = del_h;
      erracc = max(0.01, err);

      hnew = min(hnew, cohort_limit);
      hnew = min(hnew, LARGEST_STEP);
      if (step_failed) hnew = min(hnew, del_h);
      
      quot = hnew/del_h;
      if ((theta <= THET) && (quot >= QUOT1) && (quot <= QUOT2))
	{
	  jac_new   = 0;
	  dec_new   = 0;
	  step_size = del_h;
	}
      else
	{
	  jac_new   = (theta > THET);
	  dec_new   = 1;
	  if (adjust) step_size = hnew;
	}
      start_new   = 0;
      step_failed = 0;
      caljac      = 0;

      /*
       * Update variables for next step, the basic data copy, and the local
       * copy 
       */
      for (i = 0; i < SystemSize; i++)
	{
	  yy1[i] += z3[i];
	  _hv1 = (z1[i] - z2[i])/_c1mc2;
	  _hv2 = z1[i]/_c1;
	  _hv2 = (_hv1-_hv2)/_c2;
	  rcont1[i] = (z2[i] - z3[i])/_c2m1;
	  rcont2[i] = (_hv1-rcont1[i])/_c1m1;
	  rcont3[i] = rcont2[i]-_hv2;
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
      EventLocation(yy1, u_pop1, u_ofs1, bpoints, newELvalue);

      for(i=0, events=0; i<EVENT_NR; i++)
	{
	  if (((oldELvalue[i] < 0.0) && (newELvalue[i] < 0.0)) ||
	      ((oldELvalue[i] > 0.0) && (newELvalue[i] > 0.0)))
	    dolocation[i] = 0;
	  if (dolocation[i]) events++;
	}
      if (events) LocateEvent(del_h, dolocation, located);
      else for(i=0; i<EVENT_NR; i++) located[i] = 0;
#endif

      intermediate = ((next_output < (yy1[0]-identical_zero)) ||
		      ((state_out > 0.0) &&
		       (next_state_output < (yy1[0]-identical_zero))));

      if (intermediate)
	{
	  /*
	   * Produce intermediate output and state output if requested
	   */
#if (POPULATION_NR > 0)
	  for(i=0; i<POPULATION_NR; i++) CohortNo[i] += BpointNo[i];
#endif // (POPULATION_NR > 0)
	  while (next_output < (yy1[0]-identical_zero))
	    {
	      IntermediateState((next_output-yy1[0])/del_h);
#if (RADAU_TEST)
	      fprintf(stderr, "X =%5.2f    Y =%18.9E%18.9E    NSTEP =%4d\n",
		      yy2[0], yy2[1], yy2[2], naccpt);
#endif	  
	      FileOut();
	      next_output += delt_out;
	    }
      
#if (POPULATION_NR > 0)
	  while ((state_out > 0.0) && (next_state_output < (yy1[0]-identical_zero)))
	    {
	      IntermediateState((next_state_output-yy1[0])/del_h);
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
      org = 0; len = ENVIRON_DIM;
      (void)memcpy((DEF_TYPE *)env, (DEF_TYPE *)(yy1+org), len*sizeof(double));

#if (POPULATION_NR > 0)
      for(i=0; i<POPULATION_NR; i++)
	{
	  org += len;
	  len  = (BpointNo[i]*COHORT_SIZE);
	  (void)memcpy((DEF_TYPE *)ofs[i], (DEF_TYPE *)(yy1+org),
		       len*sizeof(double));
	}

      for(i=0; i<POPULATION_NR; i++)
	{
	  org += len;
	  len  = (CohortNo[i]*COHORT_SIZE);
	  (void)memcpy((DEF_TYPE *)pop[i], (DEF_TYPE *)(yy1+org),
		       len*sizeof(double));
	}
#endif // (POPULATION_NR > 0)

      (void)memcpy((DEF_TYPE *)y, (DEF_TYPE *)yy1, SystemSize*sizeof(double));
    }

  return del_h;
}




/*==============================================================================*/





