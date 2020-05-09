/***
   NAME
     ebtdopri8
   DESCRIPTION
     This file contains the specification of an explicit Runge-Kutta method of
     order 8(5,3) due to Dormand & Prince with step size control and dense
     output for the actual time integration of the ODEs in the Escalator Boxcar
     Train program. This method is used here especially for event location.
     The code is adapted from the original C source code, written by

		E. Hairer & G. Wanner
		Universite de Geneve, dept. de Mathematiques
		CH-1211 GENEVE 4, SWITZERLAND
		E-mail : HAIRER@DIVSUN.UNIGE.CH, WANNER@DIVSUN.UNIGE.CH

     The code is described in : E. Hairer, S.P. Norsett and G. Wanner, Solving
     ordinary differential equations I, nonstiff problems, 2nd edition,
     Springer Series in Computational Mathematics, Springer-Verlag (1993).
     
   Last modification: AMdR - Jan 07, 2012
***/
#ifndef EBTDOPRI8
#define EBTDOPRI8
#endif



/*==========================================================================*/
/*
 * Defining all constants that are local to this specific file.
 */
/*==========================================================================*/
/***
	DESCRIPTION OF INTEGRATION CONSTANTS

BETA	 The "beta" for stabilized step size control (see section IV.2 of the
	 book). Larger values for beta ( <= 0.2 ) make the step size control 
	 more stable. Negative initial value provoke beta=0; default beta=0.0.

FAC1     Parameters for step size selection; the new step size is chosen
FAC2     subject to the restriction  fac1 <= hnew/hold <= fac2.
	 Default values are fac1=0.333 and fac2=6.0.

SAFETY   Safety factor in the step size prediction, default 0.9.

***/  

#define BETA		0.02
#define FAC1		0.333
#define FAC2	        6.0
#define FACC1		3.0			/* 1.0 / FAC1               */
#define FACC2	        0.166666666666666666	/* 1.0 / FAC2               */
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
static double		*y  = NULL, *yy1 = NULL, *yco  = NULL;
static double		*k1 = NULL, *k2  = NULL, *k3   = NULL;
static double		*k4 = NULL, *k5  = NULL, *k6   = NULL;
static double		*k7 = NULL, *k8  = NULL, *k9   = NULL, *k10 = NULL;
static double		*rcont1 = NULL, *rcont2  = NULL, *rcont3 = NULL;
static double		*rcont4 = NULL, *rcont5  = NULL, *rcont6 = NULL;
static double		*rcont7 = NULL, *rcont8  = NULL;
#if (POPULATION_NR > 0)
static int		table_size[POPULATION_NR];
static population	u_pop[POPULATION_NR], 	    u_ofs[POPULATION_NR];
static population	c_pop[POPULATION_NR],	    c_ofs[POPULATION_NR];
static population	u_popgrad1[POPULATION_NR],  u_ofsgrad1[POPULATION_NR];
static population	u_popgrad2[POPULATION_NR],  u_ofsgrad2[POPULATION_NR];
static population	u_popgrad3[POPULATION_NR],  u_ofsgrad3[POPULATION_NR];
static population	u_popgrad4[POPULATION_NR],  u_ofsgrad4[POPULATION_NR];
static population	u_popgrad5[POPULATION_NR],  u_ofsgrad5[POPULATION_NR];
static population	u_popgrad6[POPULATION_NR],  u_ofsgrad6[POPULATION_NR];
static population	u_popgrad7[POPULATION_NR],  u_ofsgrad7[POPULATION_NR];
static population	u_popgrad8[POPULATION_NR],  u_ofsgrad8[POPULATION_NR];
static population	u_popgrad9[POPULATION_NR],  u_ofsgrad9[POPULATION_NR];
static population	u_popgrad10[POPULATION_NR], u_ofsgrad10[POPULATION_NR];
#else
static population	*bpoints = NULL;
static population	*u_pop = NULL, 	     *u_ofs = NULL;
#if (EVENT_NR > 0)
static population	*c_pop = NULL,	     *c_ofs = NULL;
#endif // (EVENT_NR > 0)
static population	*u_popgrad1 = NULL,  *u_ofsgrad1 = NULL;
static population	*u_popgrad2 = NULL,  *u_ofsgrad2 = NULL;
static population	*u_popgrad3 = NULL,  *u_ofsgrad3 = NULL;
static population	*u_popgrad4 = NULL,  *u_ofsgrad4 = NULL;
static population	*u_popgrad5 = NULL,  *u_ofsgrad5 = NULL;
static population	*u_popgrad6 = NULL,  *u_ofsgrad6 = NULL;
static population	*u_popgrad7 = NULL,  *u_ofsgrad7 = NULL;
static population	*u_popgrad8 = NULL,  *u_ofsgrad8 = NULL;
static population	*u_popgrad9 = NULL,  *u_ofsgrad9 = NULL;
static population	*u_popgrad10 = NULL, *u_ofsgrad10 = NULL;
#endif // (POPULATION_NR > 0)

static double		facold = FACOLD;
#if (EVENT_NR > 0)
static double		oldELvalue[EVENT_NR] = {0.0},
			newELvalue[EVENT_NR] = {0.0};
static int		located[EVENT_NR] = {0};
#endif

static CONST double	c2    =  0.526001519587677318785587544488E-01,
			c3    =  0.789002279381515978178381316732E-01,
			c4    =  0.118350341907227396726757197510E+00,
			c5    =  0.281649658092772603273242802490E+00,
			c6    =  0.333333333333333333333333333333E+00,
			c7    =  0.25E+00,
			c8    =  0.307692307692307692307692307692E+00,
			c9    =  0.651282051282051282051282051282E+00,
			c10   =  0.6E+00,
			c11   =  0.857142857142857142857142857142E+00,
			c14   =  0.1E+00,
			c15   =  0.2E+00,
			c16   =  0.777777777777777777777777777778E+00,

			b1    =  5.42937341165687622380535766363E-2,
			b6    =  4.45031289275240888144113950566E0,
			b7    =  1.89151789931450038304281599044E0,
			b8    = -5.8012039600105847814672114227E0,
			b9    =  3.1116436695781989440891606237E-1,
			b10   = -1.52160949662516078556178806805E-1,
			b11   =  2.01365400804030348374776537501E-1,
			b12   =  4.47106157277725905176885569043E-2,

			bhh1  =  0.244094488188976377952755905512E+00,
			bhh2  =  0.733846688281611857341361741547E+00,
			bhh3  =  0.220588235294117647058823529412E-01,

			er1   =  0.1312004499419488073250102996E-01,
			er6   = -0.1225156446376204440720569753E+01,
			er7   = -0.4957589496572501915214079952E+00,
			er8   =  0.1664377182454986536961530415E+01,
			er9   = -0.3503288487499736816886487290E+00,
			er10  =  0.3341791187130174790297318841E+00,
			er11  =  0.8192320648511571246570742613E-01,
			er12  = -0.2235530786388629525884427845E-01,

                        a21   =  5.26001519587677318785587544488E-2,
                        a31   =  1.97250569845378994544595329183E-2,
                        a32   =  5.91751709536136983633785987549E-2,
                        a41   =  2.95875854768068491816892993775E-2,
                        a43   =  8.87627564304205475450678981324E-2,
                        a51   =  2.41365134159266685502369798665E-1,
                        a53   = -8.84549479328286085344864962717E-1,
                        a54   =  9.24834003261792003115737966543E-1,
                        a61   =  3.7037037037037037037037037037E-2,
                        a64   =  1.70828608729473871279604482173E-1,
                        a65   =  1.25467687566822425016691814123E-1,
                        a71   =  3.7109375E-2,
                        a74   =  1.70252211019544039314978060272E-1,
                        a75   =  6.02165389804559606850219397283E-2,
                        a76   = -1.7578125E-2,
                        a81   =  3.70920001185047927108779319836E-2,
                        a84   =  1.70383925712239993810214054705E-1,
                        a85   =  1.07262030446373284651809199168E-1,
                        a86   = -1.53194377486244017527936158236E-2,
                        a87   =  8.27378916381402288758473766002E-3,
                        a91   =  6.24110958716075717114429577812E-1,
                        a94   = -3.36089262944694129406857109825E0,
                        a95   = -8.68219346841726006818189891453E-1,
                        a96   =  2.75920996994467083049415600797E1,
                        a97   =  2.01540675504778934086186788979E1,
                        a98   = -4.34898841810699588477366255144E1,

                        a101  =  4.77662536438264365890433908527E-1,
                        a104  = -2.48811461997166764192642586468E0,
                        a105  = -5.90290826836842996371446475743E-1,
                        a106  =  2.12300514481811942347288949897E1,
                        a107  =  1.52792336328824235832596922938E1,
                        a108  = -3.32882109689848629194453265587E1,
                        a109  = -2.03312017085086261358222928593E-2,
                        a111  = -9.3714243008598732571704021658E-1,
                        a114  =  5.18637242884406370830023853209E0,
                        a115  =  1.09143734899672957818500254654E0,
                        a116  = -8.14978701074692612513997267357E0,
                        a117  = -1.85200656599969598641566180701E1,
                        a118  =  2.27394870993505042818970056734E1,
                        a119  =  2.49360555267965238987089396762E0,
                        a1110 = -3.0467644718982195003823669022E0,
                        a121  =  2.27331014751653820792359768449E0,
                        a124  = -1.05344954667372501984066689879E1,
                        a125  = -2.00087205822486249909675718444E0,
                        a126  = -1.79589318631187989172765950534E1,
                        a127  =  2.79488845294199600508499808837E1,
                        a128  = -2.85899827713502369474065508674E0,
                        a129  = -8.87285693353062954433549289258E0,
                        a1210 =  1.23605671757943030647266201528E1,
                        a1211 =  6.43392746015763530355970484046E-1,
                        a141  =  5.61675022830479523392909219681E-2,
                        a147  =  2.53500210216624811088794765333E-1,
                        a148  = -2.46239037470802489917441475441E-1,
                        a149  = -1.24191423263816360469010140626E-1,
                        a1410 =  1.5329179827876569731206322685E-1,
                        a1411 =  8.20105229563468988491666602057E-3,
                        a1412 =  7.56789766054569976138603589584E-3,
                        a1413 = -8.298E-3,
                        a151  =  3.18346481635021405060768473261E-2,
                        a156  =  2.83009096723667755288322961402E-2,
                        a157  =  5.35419883074385676223797384372E-2,
                        a158  = -5.49237485713909884646569340306E-2,
                        a1511 = -1.08347328697249322858509316994E-4,
                        a1512 =  3.82571090835658412954920192323E-4,
                        a1513 = -3.40465008687404560802977114492E-4,
                        a1514 =  1.41312443674632500278074618366E-1,
                        a161  = -4.28896301583791923408573538692E-1,
                        a166  = -4.69762141536116384314449447206E0,
                        a167  =  7.68342119606259904184240953878E0,
                        a168  =  4.06898981839711007970213554331E0,
                        a169  =  3.56727187455281109270669543021E-1,
                        a1613 = -1.39902416515901462129418009734E-3,
                        a1614 =  2.9475147891527723389556272149E0,
                        a1615 = -9.15095847217987001081870187138E0,

                        d41   = -0.84289382761090128651353491142E+01,
                        d46   =  0.56671495351937776962531783590E+00,
                        d47   = -0.30689499459498916912797304727E+01,
                        d48   =  0.23846676565120698287728149680E+01,
                        d49   =  0.21170345824450282767155149946E+01,
                        d410  = -0.87139158377797299206789907490E+00,
                        d411  =  0.22404374302607882758541771650E+01,
                        d412  =  0.63157877876946881815570249290E+00,
                        d413  = -0.88990336451333310820698117400E-01,
                        d414  =  0.18148505520854727256656404962E+02,
                        d415  = -0.91946323924783554000451984436E+01,
                        d416  = -0.44360363875948939664310572000E+01,
                        d51   =  0.10427508642579134603413151009E+02,
                        d56   =  0.24228349177525818288430175319E+03,
                        d57   =  0.16520045171727028198505394887E+03,
                        d58   = -0.37454675472269020279518312152E+03,
                        d59   = -0.22113666853125306036270938578E+02,
                        d510  =  0.77334326684722638389603898808E+01,
                        d511  = -0.30674084731089398182061213626E+02,
                        d512  = -0.93321305264302278729567221706E+01,
                        d513  =  0.15697238121770843886131091075E+02,
                        d514  = -0.31139403219565177677282850411E+02,
                        d515  = -0.93529243588444783865713862664E+01,
                        d516  =  0.35816841486394083752465898540E+02,
                        d61   =  0.19985053242002433820987653617E+02,
                        d66   = -0.38703730874935176555105901742E+03,
                        d67   = -0.18917813819516756882830838328E+03,
                        d68   =  0.52780815920542364900561016686E+03,
                        d69   = -0.11573902539959630126141871134E+02,
                        d610  =  0.68812326946963000169666922661E+01,
                        d611  = -0.10006050966910838403183860980E+01,
                        d612  =  0.77771377980534432092869265740E+00,
                        d613  = -0.27782057523535084065932004339E+01,
                        d614  = -0.60196695231264120758267380846E+02,
                        d615  =  0.84320405506677161018159903784E+02,
                        d616  =  0.11992291136182789328035130030E+02,
                        d71   = -0.25693933462703749003312586129E+02,
                        d76   = -0.15418974869023643374053993627E+03,
                        d77   = -0.23152937917604549567536039109E+03,
                        d78   =  0.35763911791061412378285349910E+03,
                        d79   =  0.93405324183624310003907691704E+02,
                        d710  = -0.37458323136451633156875139351E+02,
                        d711  =  0.10409964950896230045147246184E+03,
                        d712  =  0.29840293426660503123344363579E+02,
                        d713  = -0.43533456590011143754432175058E+02,
                        d714  =  0.96324553959188282948394950600E+02,
                        d715  = -0.39177261675615439165231486172E+02,
                        d716  = -0.14972683625798562581422125276E+03;


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
      k7   = (double *)Myalloc((void *)k7, (size_t)ODEAllocated,
			       sizeof(double));
      k8   = (double *)Myalloc((void *)k8, (size_t)ODEAllocated,
			       sizeof(double));
      k9   = (double *)Myalloc((void *)k9, (size_t)ODEAllocated,
			       sizeof(double));
      k10  = (double *)Myalloc((void *)k10, (size_t)ODEAllocated,
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
      rcont6  = (double *)Myalloc((void *)rcont6, (size_t)ODEAllocated,
				  sizeof(double));
      rcont7  = (double *)Myalloc((void *)rcont7, (size_t)ODEAllocated,
				  sizeof(double));
      rcont8  = (double *)Myalloc((void *)rcont8, (size_t)ODEAllocated,
				  sizeof(double));
      if(!(y && yy1 && yco && k1 && k2 && k3 && k4 && k5 && k6 &&
	   k7 && k8 && k9 && k10 && rcont1 && rcont2 && rcont3 &&
	   rcont4 && rcont5 && rcont6 && rcont7 && rcont8))
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
      u_popgrad1[i]  = (population)(k1+len);
      u_ofsgrad1[i]  = (population)(k1+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad2[i]  = (population)(k2+len);
      u_ofsgrad2[i]  = (population)(k2+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad3[i]  = (population)(k3+len);
      u_ofsgrad3[i]  = (population)(k3+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad4[i]  = (population)(k4+len);
      u_ofsgrad4[i]  = (population)(k4+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad5[i]  = (population)(k5+len);
      u_ofsgrad5[i]  = (population)(k5+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad6[i]  = (population)(k6+len);
      u_ofsgrad6[i]  = (population)(k6+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad7[i]  = (population)(k7+len);
      u_ofsgrad7[i]  = (population)(k7+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad8[i]  = (population)(k8+len);
      u_ofsgrad8[i]  = (population)(k8+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad9[i]  = (population)(k9+len);
      u_ofsgrad9[i]  = (population)(k9+len+CohortNo[i]*COHORT_SIZE);
      u_popgrad10[i] = (population)(k10+len);
      u_ofsgrad10[i] = (population)(k10+len+CohortNo[i]*COHORT_SIZE);
      len += (table_size[i]*COHORT_SIZE);
    }
#endif // (POPULATION_NR > 0)

  return;
}




/*==============================================================================*/

static void	dopri8(double dt)

  /* 
   * dopri8 - Routine performs an integration step of the system using the
   *	      DOPRI8 integration method. The code is adapted from the original
   *	      C source code by E. Hairer & G. Wanner.
   */

{
  register int		i;

  initState = y;
  currentState = yy1;
  currentDers[ 1] = k1;
  currentDers[ 2] = k2;
  currentDers[ 3] = k3;
  currentDers[ 4] = k4;
  currentDers[ 5] = k5;
  currentDers[ 6] = k6;
  currentDers[ 7] = k7;
  currentDers[ 8] = k8;
  currentDers[ 9] = k9;
  currentDers[10] = k10;
  currentDers[11] = k2;
  currentDers[12] = k3;
						/* Set all time derivatives */
  k1[0] = k2[0] = k3[0] = k4[0] = k5[0]  = 1.0;
  k6[0] = k7[0] = k8[0] = k9[0] = k10[0] = 1.0;

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
    yy1[i] = y[i] + dt * (a41*k1[i] + a43*k3[i]);

  rk_level = 4;
  Gradient(yy1, u_pop, u_ofs, k4, u_popgrad4, u_ofsgrad4, bpoints);

  for (i = 0; i <SystemSize; i++)
    yy1[i] = y[i] + dt * (a51*k1[i] + a53*k3[i] + a54*k4[i]);

  rk_level = 5;
  Gradient(yy1, u_pop, u_ofs, k5, u_popgrad5, u_ofsgrad5, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a61*k1[i] + a64*k4[i] + a65*k5[i]);

  rk_level = 6;
  Gradient(yy1, u_pop, u_ofs, k6, u_popgrad6, u_ofsgrad6, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a71*k1[i] + a74*k4[i] + a75*k5[i] + a76*k6[i]);

  rk_level = 7;
  Gradient(yy1, u_pop, u_ofs, k7, u_popgrad7, u_ofsgrad7, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a81*k1[i] + a84*k4[i] + a85*k5[i] + a86*k6[i] +
			  a87*k7[i]);

  rk_level = 8;
  Gradient(yy1, u_pop, u_ofs, k8, u_popgrad8, u_ofsgrad8, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a91*k1[i] + a94*k4[i] + a95*k5[i] + a96*k6[i] +
			  a97*k7[i] + a98*k8[i]);

  rk_level = 9;
  Gradient(yy1, u_pop, u_ofs, k9, u_popgrad9, u_ofsgrad9, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a101*k1[i] + a104*k4[i] + a105*k5[i] + a106*k6[i] +
			  a107*k7[i] + a108*k8[i] + a109*k9[i]);

  rk_level = 10;
  Gradient(yy1, u_pop, u_ofs, k10, u_popgrad10, u_ofsgrad10, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a111*k1[i] + a114*k4[i] + a115*k5[i] + a116*k6[i] +
			  a117*k7[i] + a118*k8[i] + a119*k9[i] + a1110*k10[i]);

  rk_level = 11;
  Gradient(yy1, u_pop, u_ofs, k2, u_popgrad2, u_ofsgrad2, bpoints);

  for (i = 0; i < SystemSize; i++)
    yy1[i] = y[i] + dt * (a121*k1[i] + a124*k4[i] + a125*k5[i] + a126*k6[i] +
			  a127*k7[i] + a128*k8[i] + a129*k9[i] +
			  a1210*k10[i] + a1211*k2[i]);

  rk_level = 12;
  Gradient(yy1, u_pop, u_ofs, k3, u_popgrad3, u_ofsgrad3, bpoints);

  for (i = 0; i < SystemSize; i++)
    {
      k4[i] = (b1*k1[i] + b6*k6[i] + b7*k7[i] + b8*k8[i] + b9*k9[i] +
	       b10*k10[i] + b11*k2[i] + b12*k3[i]);
      k5[i] = y[i] + dt * k4[i];
    }

  return;
} /* dopri8 */




/*==============================================================================*/
#if (EVENT_NR > 0)

static double 	delvalue(double theta, int eventindex)

{
  register int		i;
  double   		theta1, result[EVENT_NR];

  theta1 = 1.0 - theta;

  for (i = 0; i < SystemSize; i++)
    yco[i] = rcont1[i] +
      theta*(rcont2[i] +
	     theta1*(rcont3[i] +
		     theta*(rcont4[i] +
			    theta1*(rcont5[i] +
				    theta*(rcont6[i] +
					   theta1*(rcont7[i] +
						   theta*rcont8[i]))))));

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
   *		   values, i.e. both non-zero and their product negative.
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
    {						/* Use the continuous output*/
      double		theta, theta1;		/* state to continue        */
      
      theta = stepfrac[index];
      theta1 = 1.0 - theta;
      
      for (i = 0; i < SystemSize; i++)
	yy1[i] = rcont1[i] +
	  theta*(rcont2[i] +
		 theta1*(rcont3[i] +
			 theta*(rcont4[i] +
				theta1*(rcont5[i] +
					theta*(rcont6[i] +
					       theta1*(rcont7[i] +
						       theta*rcont8[i]))))));
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
    yco[i] = rcont1[i] +
      theta*(rcont2[i] +
	     theta1*(rcont3[i] +
		     theta*(rcont4[i] +
			    theta1*(rcont5[i] +
				    theta*(rcont6[i] +
					   theta1*(rcont7[i] +
						   theta*rcont8[i]))))));

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
  double		err, err2, erri, sk, sqr, deno;
  double		fac, fac11, hnew;
  double		ydiff, bspl;
  double		stnum, stden;
  int			adjust = 1, events = 0, intermediate = 0;
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

  dopri8(del_h);				/* Do an integration step   */

  err  = 0.0;					/* error estimation         */
  err2 = 0.0;
  for (i = 0; i < SystemSize; i++)
    {
      sk    = ABS_ERR + accuracy * max (fabs(y[i]), fabs(k5[i]));
      erri  = k4[i] - bhh1*k1[i] - bhh2*k9[i] - bhh3*k3[i];
      sqr   = erri / sk;
      err2 += sqr*sqr;
      erri  = (er1*k1[i] + er6*k6[i] + er7*k7[i] + er8*k8[i] + er9*k9[i] +
	       er10 * k10[i] + er11*k2[i] + er12*k3[i]);
      sqr   = erri / sk;
      err  += sqr*sqr;
    }
  deno = err + 0.01 * err2;
  if (deno <= 0.0) deno = 1.0;
  err  = fabs(del_h) * err * sqrt (1.0 / (deno*(double)SystemSize));

  if (err > 1.0)				/* Step rejected            */
    {
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

      fac11  = pow (err, 0.125 - BETA * 0.2);
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
	  fac11  = pow (err, 0.125 - BETA * 0.2);
	  fac    = fac11/pow(facold, BETA);
	  fac    = max(FACC2, min(FACC1, fac/SAFETY));
	  hnew   = del_h / fac;
	  facold = max (err, FACOLD);

	  step_size = min(hnew, cohort_limit);
	  step_size = min(step_size, LARGEST_STEP);
	}
      step_failed=0;
      accepted_steps++;

      rk_level = 13;
      Gradient(k5, u_popgrad5, u_ofsgrad5, k4, u_popgrad4, u_ofsgrad4, bpoints);
      
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
		  sqr    = k4[i] - k3[i];
		  stnum += sqr*sqr;
		  sqr    = k5[i] - yy1[i];
		  stden += sqr*sqr;
		}
	      if (stden > 0.0)
		hlamb = del_h * sqrt (stnum / stden);
	      if (hlamb > 6.1)
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
	   * only in really necessary (4 more function evalutions)!
	   */
	  for (i = 0; i < SystemSize; i++)
	    {
	      rcont1[i] = y[i];
	      ydiff     = k5[i] - y[i];
	      rcont2[i] = ydiff;
	      bspl      = del_h * k1[i] - ydiff;
	      rcont3[i] = bspl;
	      rcont4[i] = ydiff - del_h*k4[i] - bspl;
	      rcont5[i] = (d41*k1[i] + d46*k6[i] + d47*k7[i] + d48*k8[i] +
			   d49*k9[i] + d410*k10[i] + d411*k2[i] + d412*k3[i]);
	      rcont6[i] = (d51*k1[i] + d56*k6[i] + d57*k7[i] + d58*k8[i] +
			   d59*k9[i] + d510*k10[i] + d511*k2[i] + d512*k3[i]);
	      rcont7[i] = (d61*k1[i] + d66*k6[i] + d67*k7[i] + d68*k8[i] +
			   d69*k9[i] + d610*k10[i] + d611*k2[i] + d612*k3[i]);
	      rcont8[i] = (d71*k1[i] + d76*k6[i] + d77*k7[i] + d78*k8[i] +
			   d79*k9[i] + d710*k10[i] + d711*k2[i] + d712*k3[i]);
	    }
	  for (i = 0; i < SystemSize; i++)
	    yy1[i] = y[i] + del_h * (a141*k1[i] + a147*k7[i] + a148*k8[i] +
				     a149*k9[i] + a1410*k10[i] + a1411*k2[i] +
				     a1412*k3[i] + a1413*k4[i]);

	  rk_level = 14;
	  Gradient(yy1, u_pop, u_ofs, k10, u_popgrad10, u_ofsgrad10, bpoints);

	  for (i = 0; i < SystemSize; i++)
	    yy1[i] = y[i] + del_h * (a151*k1[i]  + a156*k6[i]  + a157*k7[i]  + 
				     a158*k8[i]  + a1511*k2[i] + a1512*k3[i] +
				     a1513*k4[i] + a1514*k10[i]);
	  rk_level = 15;
	  Gradient(yy1, u_pop, u_ofs, k2, u_popgrad2, u_ofsgrad2, bpoints);

	  for (i = 0; i < SystemSize; i++)
	    yy1[i] = y[i] + del_h * (a161*k1[i] + a166*k6[i] + a167*k7[i] +
				     a168*k8[i] + a169*k9[i] + a1613*k4[i] +
				     a1614*k10[i] + a1615*k2[i]);
	  rk_level = 16;
	  Gradient(yy1, u_pop, u_ofs, k3, u_popgrad3, u_ofsgrad3, bpoints);

	  /* final preparation */
	  for (i = 0; i < SystemSize; i++)
	    {
	      rcont5[i] = del_h * (rcont5[i] + d413*k4[i] + d414*k10[i] +
				   d415*k2[i] + d416*k3[i]);
	      rcont6[i] = del_h * (rcont6[i] + d513*k4[i] + d514*k10[i] +
				   d515*k2[i] + d516*k3[i]);
	      rcont7[i] = del_h * (rcont7[i] + d613*k4[i] + d614*k10[i] +
				   d615*k2[i] + d616*k3[i]);
	      rcont8[i] = del_h * (rcont8[i] + d713*k4[i] + d714*k10[i] +
				   d715*k2[i] + d716*k3[i]);
	    }
	}

      (void)memcpy((DEF_TYPE *)yy1,(DEF_TYPE *)k5, SystemSize*sizeof(double));

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
      int			len;

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
