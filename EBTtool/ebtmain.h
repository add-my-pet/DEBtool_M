/***
   NAME
     ebtmain.h
   PURPOSE
     Interface header file to the functions defined in ebtmain.c
   NOTES
     
   HISTORY
     AMdR - Jul 20, 1995 : Created.
     AMdR - Oct 25, 2012 : Revised last.
***/

#ifndef EBTMAIN_H
#define EBTMAIN_H

/*==========================================================================*/
/*
 * Definitions of global variables exported to the linker. All the global 
 * variables are defined in the ebtmain.h file and exported to the other 
 * modules. This facilitates location of their definitions.
 */

#ifndef EXPORTING
#define EXPORTING 
#endif
#ifdef 	EBTMAIN_C
#  undef  EXTERN
#  define EXTERN
#else
#  undef  EXPORTING
#  define EXPORTING
#  undef  EXTERN
#  define EXTERN	extern
#endif

EXTERN int	environ_dim;		/* Environment dimension    */
EXTERN int	population_nr;		/* Number of populations    */
EXTERN int	i_state_dim;		/* I-state dimension        */
EXTERN int	i_const_dim;		/* I-constant dimension     */
EXTERN int	parameter_nr;		/* Parameter number         */
EXTERN int      error_code;             /* Warning/(fatal) error    */

#ifdef 	EBTMAIN_C
// Static variables restricted to ebtmain.c only
static int	output_var_nr;			/* Output variable number   */
#endif

#ifdef MODULE
EXTERN	 char error_msg[1024];	/* Error message, for tool  */
EXTERN_C char* exp_error_msg(void);
EXTERN_C int exp_environ_dim(void);
EXTERN_C int exp_population_nr(void);
EXTERN_C int exp_i_state_dim(void);
EXTERN_C int exp_i_const_dim(void);
EXTERN_C int exp_parameter_nr(void);
EXTERN_C double* exp_env(void); 
EXTERN_C population* exp_pop(void);
EXTERN_C int* exp_CohortNo(void);
EXTERN_C double* exp_output(void);
EXTERN_C char* exp_statelabel(int popnr);
#if (I_CONST_DIM > 0)
EXTERN_C popID* exp_popIDcard(void); 
#else
EXTERN_C double* exp_popIDcard(void);
#endif  // i_const_dim
#endif  // module

// This function is called in both the tool and ebtutils.c. It is implemented
// to protect the value of output_var_nr from changes by the user
EXTERN_C int exp_output_var_nr(void);


EXTERN double	*initState;			/* Pointer to initial       */
						/* system state             */
EXTERN double	*currentState;			/* Pointer to most current  */
						/* system state             */
EXTERN double	*currentDers[MAXDERS];		/* Pointers to computed     */
						/* derivatives              */
EXTERN double	env[ENVIRON_DIM];		/* Becomes vector of        */
						/* environmental values     */
#if (POPULATION_NR > 0)
EXTERN population pop[POPULATION_NR];		/* Array of pointers to the */
						/* population data          */
EXTERN population ofs[POPULATION_NR];		/* Array of pointers to the */
						/* offspring data           */
EXTERN population bpoints[POPULATION_NR];	/* Array of pointers to the */
						/* boundary points          */
#if (I_CONST_DIM > 0)
EXTERN popID popIDcard[POPULATION_NR];		/* Population ID structure  */
EXTERN popID ofsIDcard[POPULATION_NR];		/* & offspring ID structure */
#else                                           /* for non-dynamic data     */
EXTERN double popIDcard[POPULATION_NR];
#endif

EXTERN int	CohortNo[POPULATION_NR]; 	/* Number of cohorts in     */
						/* the various populations  */
EXTERN int	cohort_no[POPULATION_NR];       /* Copy of CohortNo vector  */
						/* accessible to user       */
EXTERN int      BpointNo[POPULATION_NR];        /* Number of boundary points*/
						/* for boundary cohorts     */
EXTERN int	bpoint_no[POPULATION_NR];       /* Copy of BpointNo vector  */
						/* accessible to user       */
#endif // (POPULATION_NR > 0)

EXTERN double	cohort_limit;                   /* Time limit new cohorts   */

EXTERN double	max_time;                       /* Maximum integration time */

EXTERN int	cohort_end;                     /* Flag indicating dynamic  */
						/* ending of cohort cycle   */
EXTERN double	step_size;                      /* The step size for the    */
						/* time integration         */
EXTERN double	output[OUTPUT_VAR_NR+2];	/* Array with output values */

EXTERN int	outputDefined;			/* Output is defined flag   */

EXTERN double	delt_out;                       /* Output time interval     */

EXTERN double	state_out;                      /* The time interval for    */
						/* complete state output    */
EXTERN double	next_cohort_end;		/* Time of cohort closure   */

EXTERN double	next_output, next_state_output;	/* Time of next (state)     */
						/* output                   */
EXTERN FILE	*resfil;			/* Pointer to outputfile    */

EXTERN FILE	*csbfil;			/* Pointer binary state file*/

#if ((BIFURCATION == 1) && (MEASUREBIFSTATS == 1))
EXTERN FILE	*averages;			// File pointers for
EXTERN FILE	*gaverages;			// bifurcation output
EXTERN FILE	*variances;
EXTERN FILE	*extrema;
#endif

EXTERN int	csbnew;				/* Flag new state file      */

EXTERN FILE	*dbgfil;			/* Pointer debug report file*/

EXTERN double	accuracy;                       /* Accuracy of the          */
						/* integration routine      */
EXTERN double	identical_zero;			/* Tolerance value, deter-  */
						/* mining identity with 0.0 */
EXTERN double	equal2zero;			/* Internal tolerance value */
						/* for identity with 0.0    */
#if (POPULATION_NR > 0)
EXTERN cohort	abs_tols[POPULATION_NR];	/* Absolute tolerance for   */
						/* identity of cohorts      */
EXTERN cohort	rel_tols[POPULATION_NR];	/* Relative tolerance for   */
						/* identity of cohorts      */
EXTERN int	tol_zero[POPULATION_NR];        /* Flag indicating one of   */
						/* i-state tolerances is 0  */
EXTERN int	pop_extinct[POPULATION_NR];     /* Flag indicating whether  */
						/* population extinction has*/
						/* been signalled already   */
#endif // (POPULATION_NR > 0)

#if PARAMETER_NR
EXTERN double	parameter[PARAMETER_NR];	/* Vector of free parameters*/
#endif						/* in the problem           */

#if (BIFURCATION == 1)
EXTERN int	BifParIndex;			/* Index of                 */
						/* bifurcation parameter    */
EXTERN double	BifParStep;			/* Step size in             */
						/* bifurcation parameter    */
EXTERN double	BifParLastVal;			/* Last value of            */
						/* bifurcation parameter    */
EXTERN int	BifParLogStep;			/* Logarithmic steps in     */
						/* bifurcation parameter    */
EXTERN double	BifOutput;			/* Output period            */
						/* during bifurcation run   */
EXTERN double	BifStateOutput;			/* State output period      */
						/* during bifurcation run   */
EXTERN double	BifParBase;			/* First value of           */
						/* bifurcation parameter    */
EXTERN double	BifPeriod;			/* Parameter change period  */
						/* during bifurcation run   */
#endif // (BIFURCATION == 1)
EXTERN char	progname[MAXFILENAMELEN];       /* Name of the program      */

EXTERN char	runname[MAXFILENAMELEN];        /* Name of the current run  */

EXTERN char	**usernotes;			/* User defined notes       */
						/* State labels in CSB file */
#if (POPULATION_NR > 0)
EXTERN char     statelabels[POPULATION_NR][DESCRIP_MAX];
#endif // (POPULATION_NR > 0)

EXTERN struct dscrptn {				/* The structure with       */
		char accuracy[DESCRIP_MAX];	/* descriptions of the      */
		char cohort_limit[DESCRIP_MAX];	/* quantities that are      */
		char identical_zero[DESCRIP_MAX]; /* read from .CVF file    */
		char max_time[DESCRIP_MAX];
		char delt_out[DESCRIP_MAX];
		char state_out[DESCRIP_MAX];
		char abs_tols[COHORT_SIZE][DESCRIP_MAX];
		char rel_tols[COHORT_SIZE][DESCRIP_MAX];
#if PARAMETER_NR
		char parameter[PARAMETER_NR][DESCRIP_MAX];
#endif
#if (BIFURCATION == 1)
		char bifparindex[DESCRIP_MAX];
		char bifparstep[DESCRIP_MAX];
		char bifparlastval[DESCRIP_MAX];
		char bifparlogstep[DESCRIP_MAX];
		char bifoutput[DESCRIP_MAX];
		char bifstateoutput[DESCRIP_MAX];
#endif // (BIFURCATION == 1)
		} description;

EXTERN int	Resume;				/* Flag for resuming run    */

EXTERN int	debug_level;			/* Level of debug info      */

#if (POPULATION_NR > 0)
EXTERN long	DataMemAllocated[POPULATION_NR];/* Total number of doubles  */
						/* currently allocated      */
#if (I_CONST_DIM > 0)
EXTERN long	IDMemAllocated[POPULATION_NR];	/* Total number of doubles  */
#endif						/* currently allocated      */
#endif // (POPULATION_NR > 0)

EXTERN int	rk_level;			/* Number of current Runge- */
						/* Kutta evaluation (1-6)   */

EXTERN int	ForcedCohortEnd;		/* Flag indicating forced   */
						/* dynamic cohort closure   */

EXTERN int	ForcedRunEnd;			/* Flag indicating forced   */
						/* ending of entire run     */

EXTERN int	LocatedEvent;			/* Index of located event   */


/*==========================================================================*/
#endif /* EBTMAIN_C */
