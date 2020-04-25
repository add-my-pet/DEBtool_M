/***
   NAME
     ebtmain.c
   PURPOSE
     This file contains the main routine of the EBT program.
   NOTES

   HISTORY
     AMdR - Jul 19, 1995 : Created.
     AMdR - Nov 18, 2014 : Revised last.
***/

#define EBTMAIN_C				/* Identification of file   */
#define EBTLIB                                  /* and file grouping        */

#include "escbox.h"                             /* Include general header   */
#include "ebtinit.h"
#include "ebtcohrt.h"
#include "ebtmain.h"
#include "ebtutils.h"
#include "ebtstop.h"

/* Bas Kooijman 2020/04/02 */
#include "ebttint.h"


/*==========================================================================*/
/*
 * The error messages that occur in the routines in the present file.
 */

#define SGE  "Error in installing the signal handlers!"

/*==========================================================================*/
/*
 * Start of function implementations.
 */
/*==========================================================================*/
#ifdef MODULE
EXTERN_C char* exp_error_msg(void){ return error_msg; }
EXTERN_C int exp_environ_dim(void){ return environ_dim; }
EXTERN_C int exp_population_nr(void){ return population_nr; }
EXTERN_C int exp_i_state_dim(void){ return i_state_dim; }
EXTERN_C int exp_i_const_dim(void){ return i_const_dim; }
EXTERN_C int exp_parameter_nr(void){ return parameter_nr; }
EXTERN_C double* exp_env(void){ return env; }
EXTERN_C double* exp_output(void){ return output; }
#if (POPULATION_NR > 0)
EXTERN_C population* exp_pop(void){ return pop; }
EXTERN_C int* exp_CohortNo(void){ return CohortNo; }
EXTERN_C char* exp_statelabel(int popnr){ return statelabels[popnr]; }
#if (I_CONST_DIM > 0)
EXTERN_C popID* exp_popIDcard(void){ return popIDcard; }
#else
EXTERN_C double* exp_popIDcard(void){ return popIDcard; }
#endif	// i_const_dim > 0
#else
EXTERN_C population* exp_pop(void){ return NULL; }
EXTERN_C int* exp_CohortNo(void){ return NULL; }
EXTERN_C char* exp_statelabel(int popnr){ return NULL; }
EXTERN_C double* exp_popIDcard(void){ return NULL; }
#endif // (POPULATION_NR > 0)
#endif  // MODULE

// This function is called in both the tool and ebtutils.c. It is implemented
// to protect the value of output_var_nr from changes by the user
EXTERN_C int exp_output_var_nr(void){ return output_var_nr; }


#ifndef MODULE

static void	PrintStats(void)

  /*
   * PrintStats - Routine writes statistics about current program status to
   *              stderr after receiving a SIGUSR1 signal
   *		  (use kill -USR1 to generate it)
   */

{
  fprintf(stderr, "\n\nCurrent program status:\n\n");
  fprintf(stderr, "%-50s : %.6f\n", "Time", env[0]);

#if (POPULATION_NR > 0)
  register int 			i;

  for (i=0; i<POPULATION_NR; i++)
    {
      fprintf(stderr, "%-48s%2d : %d\n",
	      "Number of cohorts in population", i, CohortNo[i]);
    }
#endif // (POPULATION_NR > 0)

  fprintf(stderr, "%-50s : %.4E\n",
	  "Current cohort limit", cohort_limit);
  fprintf(stderr, "%-50s : %.4E\n",
	  "Step size in integration", step_size);
  fprintf(stderr, "\n\n");

  WriteStateToFile(stderr, NULL);

  fflush(stderr);

  return;
}



/*==============================================================================*/

#if HAS_SIGNALS
						/* ARGSUSED                 */
static void	CatchSig(int signl)

  /*
   * CatchSig - Routine catches and handles the signals received from the
   *            ebttool application running this program as a child.
   */

{
  switch (signl)
    {
#ifndef LIMITED_SIGNALS
    case SIGHUP:				/* End integration         */
#if (POPULATION_NR > 0)
      TransBcohorts();
#endif // (POPULATION_NR > 0)
      ErrorExit(1, "Hangup enforced by user signal");
      break;
    case SIGUSR1:				/* Print program statistics*/
      PrintStats();
      break;
#endif
    case SIGFPE:				/* Floating point exception*/
#if defined(_GNU_SOURCE)
      if (initState && currentState)
	{
	  // In the middle of integration, save most recent data
	  if (!dbgfil)				// Open file if necessary
	    {
	      char			filename[MAXFILENAMELEN];

	      (void)strcpy(filename, runname); (void)strcat(filename, "dbg");
	      dbgfil=fopen(filename, "a");
	      if(!dbgfil) Warning("Unable to open DBG file!");
	    }
	  if(dbgfil) (void)fprintf(dbgfil, "==============================================================\n");
	  if(dbgfil) (void)fprintf(dbgfil, "\nFPE EXCEPTION AT T = %.10f, STEP SIZE = %.6E\n", env[0], step_size);
	  if (dbgfil && initState)
	    {
	      (void)fprintf(dbgfil, "\nInitial state of current integration step\n\n");
	      WriteStateToFile(dbgfil, initState);
	    }
	  if (dbgfil && currentState)
	    {
	      (void)fprintf(dbgfil, "\nCurrent state in integration step (rk_level = %d)\n\n", rk_level);
	      WriteStateToFile(dbgfil, currentState);
	    }
	  if (dbgfil && currentDers[rk_level-1])
	    {
	      (void)fprintf(dbgfil, "\nLast derivative in integration step (rk_level = %d)\n\n", rk_level-1);
	      WriteStateToFile(dbgfil, currentDers[rk_level-1]);
	    }
	  if (dbgfil && currentDers[rk_level])
	    {
	      (void)fprintf(dbgfil, "\nCurrent derivative in integration step (rk_level = %d)\n\n", rk_level);
	      WriteStateToFile(dbgfil, currentDers[rk_level]);
	    }
	  if(dbgfil) (void)fprintf(dbgfil, "==============================================================\n");
	}
#if (POPULATION_NR > 0)
      TransBcohorts();
#endif // (POPULATION_NR > 0)
      {
	char		fpe_mes[80];

	/*
	  The code below represents an attempt to further detect the type of FPU
	  error that occurred. As of now, however, I do not know how to do
	  it. The use of fetestexcept() always yields a 0 return value, which is
	  meaningless.

	int		fpe;

	fpe = fetestexcept(FE_ALL_EXCEPT);
	if (fetestexcept(FE_DIVBYZERO))
	  sprintf(fpe_mes, "Floating point error at time %.4f: Division by 0", env[0]);
	else if (fetestexcept(FE_UNDERFLOW))
	  sprintf(fpe_mes, "Floating point error at time %.4f: Underflow", env[0]);
	else if (fetestexcept(FE_OVERFLOW))
	  sprintf(fpe_mes, "Floating point error at time %.4f: Overflow", env[0]);
	else if (fetestexcept(FE_INEXACT))
	  sprintf(fpe_mes, "Floating point error at time %.4f: Inexact result", env[0]);
	else if (fetestexcept(FE_INVALID))
	  sprintf(fpe_mes, "Floating point error at time %.4f: Invalid operation", env[0]);
	else
	  sprintf(fpe_mes, "Floating point error at time %.4f: Unknown error code %d",
		  env[0], fpe);
	*/
	sprintf(fpe_mes, "Floating point error at time %.4f", env[0]);
	ErrorExit(1, fpe_mes);
      }
#endif
      break;
    }

#ifndef LIMITED_SIGNALS
  if (signal(SIGHUP,  CatchSig) == SIG_ERR) Warning(SGE);
  if (signal(SIGUSR1, CatchSig) == SIG_ERR) Warning(SGE);
#endif
  if (signal(SIGFPE,  CatchSig) == SIG_ERR) Warning(SGE);

  return;
}

#endif //HAS_SIGNALS
#endif //!MODULE



/*==========================================================================*/

#ifdef MODULE
#if HAS_SIGNALS
EXTERN_C int HandleSignal(int signl)
{
  switch (signl)
    {
#ifndef LIMITED_SIGNALS
    case SIGHUP:
      ErrorExit(1, "Received SIGHUP signal.");
      break;
#endif
    case SIGINT:
      ErrorExit(1, "Received SIGINT signal.");
      break;
    case SIGFPE:
      ErrorExit(1, "Received SIGFPE signal.");
      break;
    }
  return error_code;
}

#endif //HAS_SIGNALS
#endif //MODULE

/*==========================================================================*/

static void usage(char *progname)

{
  fprintf(stderr, "\nUsage of %s command line options: \n\n", progname);
  fprintf(stderr, "    -r | --resume\n");
  fprintf(stderr, "        Resume previously interrupted integration\n\n");
  fprintf(stderr, "    -d <0|1|2|3|4> | --debug <0|1|2|3|4> \n");
  fprintf(stderr, "        Select debug information level 0, 1, 2, 3 or 4 ");
  fprintf(stderr, "(written to DBG file)\n\n");
  fprintf(stderr, "    -? | --help \n");
  fprintf(stderr, "        Show this message\n");
  fprintf(stderr, "\n");
  exit(0);
  return;
}





/*==========================================================================*/
#ifndef MODULE

int       		main(int argc, char **argv)

#else

EXTERN_C int		StartUp(int argc, char **argv)

#endif

{
  char			**argpnt1 = NULL, **argpnt2 = NULL, **my_argv = NULL;
  int			my_argc;
#ifdef MODULE
  int			ret_val = 0;
#endif
  Resume 	= 0;
  debug_level 	= 0;
  environ_dim	= ENVIRON_DIM;
  population_nr	= POPULATION_NR;
  i_state_dim	= I_STATE_DIM;
  i_const_dim	= I_CONST_DIM;
  output_var_nr = OUTPUT_VAR_NR;
  parameter_nr	= PARAMETER_NR;
#ifdef MODULE
  strcpy(error_msg, "");
#endif
  error_code    = 0;

#if defined(_GNU_SOURCE)
  /*
   * Possible exception types to set are
   *		(FE_DIVBYZERO | FE_INVALID | FE_OVERFLOW | FE_UNDERFLOW | FE_INEXACT);
   * The last two are, however, frequently occurring in mathematical functions
   * without any consequences. Only enable testing the first 3.
   */
#ifndef MODULE
  feclearexcept(FE_ALL_EXCEPT);
#if defined(__APPLE__)
  static 	fenv_t fenv;
  unsigned int 	new_excepts;  // previous masks

  new_excepts = (FE_DIVBYZERO | FE_INVALID | FE_OVERFLOW) & FE_ALL_EXCEPT,

  fegetenv(&fenv);

  // unmask
  fenv.__control &= ~new_excepts;
  fenv.__mxcsr   &= ~(new_excepts << 7);
  fesetenv (&fenv);

#else
  // Bas Kooijman 2020/03/31: feenableexcept replaced by feraiseexcept
  feraiseexcept(FE_DIVBYZERO | FE_INVALID | FE_OVERFLOW);
#endif // defined(__APPLE__)
#endif
#endif

  my_argv = (char **)Myalloc((void *)my_argv, (size_t)argc, sizeof(char *));

  /*
   * Process all intrinsic command line parameters. Possibilities:
   *
   *	-r   | --resume	 	: Resume previously interrupted integration
   *
   *	-d n | --debug n 	: Level of debug information, stored in the
   *			   	  DBG file
   *
   *	-?   | --help		: Print usage message
   */
  argpnt1 = argv;
  argpnt2 = my_argv;
  my_argc = 0;
  while (*argpnt1)
    {
      if (!strcmp(*argpnt1, "-r") || !strcmp(*argpnt1, "--resume"))
	{
	  Resume = 1;
	}
      else if (!strcmp(*argpnt1, "-?") || !strcmp(*argpnt1, "--help"))
	{
	  usage(argv[0]);
	}
      else if (!strcmp(*argpnt1, "-d") ||!strcmp(*argpnt1, "--debug"))
	{
	  argpnt1++;
	  if (!*argpnt1)
	    {
	      fprintf(stderr, "\nNo debug level specified!\n");
	      usage(argv[0]);
	    }
	  switch (atoi(*argpnt1))
	    {
	    case 0:
	    case 1:
	    case 2:
	    case 3:
	    case 4:
	    case 5:
	      debug_level = atoi(*argpnt1);
	      break;
	    default:
	      fprintf(stderr, "\nWrong debug level specifier: %s\n", *argpnt1);
	      usage(argv[0]);
	      break;
	    }
	}
      else if ((!strncmp(*argpnt1, "--", 2)))
	{
	  fprintf(stderr, "\nUnknown command line option: %s\n", *argpnt1);
	  usage(argv[0]);
	}
      else if ((!strncmp(*argpnt1, "-", 1)) && isalpha(*(*argpnt1+1)))
	{
	  fprintf(stderr, "\nUnknown command line option: %s\n", *argpnt1);
	  usage(argv[0]);
	}
      else
	{
	  *argpnt2 = *argpnt1;
	  my_argc++;
	  argpnt2++;
	}
      argpnt1++;
    }
  // Initialization of the environment, population and output devices
  Initialize(my_argc, my_argv);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return error_code;
#endif

#ifndef MODULE
#if HAS_SIGNALS
#ifndef LIMITED_SIGNALS
  if (signal(SIGHUP,  CatchSig) == SIG_ERR) Warning(SGE);
  if (signal(SIGUSR1, CatchSig) == SIG_ERR) Warning(SGE);
#endif
  if (signal(SIGFPE,  CatchSig) == SIG_ERR) Warning(SGE);
#endif /* HAS_SIGNALS */
#endif // ! MODULE

#if (DYNAMIC_COHORTS == 1)
  next_cohort_end = max_time;
#else
  next_cohort_end = (floor(env[0]/cohort_limit)+1)*cohort_limit;
#endif /* DYNAMIC_COHORTS */

						/* By default (state)       */
  next_output       =				/* output at start up       */
      (floor((env[0]-identical_zero)/delt_out)+1)*delt_out;
  if (state_out > 0.0)
      next_state_output =
	  (floor((env[0]-identical_zero)/state_out)+1)*state_out;
  else next_state_output = 0.0;

#if (BIFURCATION == 1)
  double		oldBifParVal;

  // Initialise the bifurcation and set the current parameter value
  SetBifOutputTimes(env);

  BifParBase = parameter[BifParIndex];

  if (BifParLogStep)
    parameter[BifParIndex] = (BifParBase*pow(10.0, BifParStep*floor((env[0]+BIFTINY)/BifPeriod)));
  else
    parameter[BifParIndex] = (BifParBase + floor((env[0]+BIFTINY)/BifPeriod)*BifParStep);

  oldBifParVal = parameter[BifParIndex];
#endif // (BIFURCATION == 1)

#if (POPULATION_NR > 0)
						/* Allow the user to carry  */
  UserInit(my_argc, my_argv, env, pop);		/* out some initialization  */
#else
  UserInit(my_argc, my_argv, env, NULL);
#endif // (POPULATION_NR > 0)
#ifdef MODULE
  if (error_code & FATAL_ERROR) return error_code;
#endif

#if (POPULATION_NR > 0)
  SievePop();
#endif // (POPULATION_NR > 0)

#if (BIFURCATION == 1)
  // Bifurcation parameter as additional output
  output_var_nr++;

  // Redo the initialisation in case the user has changed some of the
  // bifurcation parameters
  SetBifOutputTimes(env);

  // Change the BifParBase only when user has changed the parameter value in UserInit()
  if (oldBifParVal != parameter[BifParIndex]) BifParBase = parameter[BifParIndex];

  if (BifParLogStep)
    parameter[BifParIndex] = (BifParBase*pow(10.0, BifParStep*floor((env[0]+BIFTINY)/BifPeriod)));
  else
    parameter[BifParIndex] = (BifParBase + floor((env[0]+BIFTINY)/BifPeriod)*BifParStep);
#endif // (BIFURCATION == 1)

  if ((next_output - env[0]) < identical_zero)
    {						/* Increment next time      */
      next_output += delt_out;			/* Produce output if        */
      FileOut();				/* required at this time    */
#ifdef MODULE
      ret_val |= NORMAL_OUT;			// AMdR - Jul 22, 2008
#endif
    }

#if (POPULATION_NR > 0)
  if ((state_out > 0.0) && ((next_state_output-env[0]) < identical_zero))
    {						/* Increment next time      */
      next_state_output += state_out;		/* Output complete state if */
      FileState();				/* required at this time    */
#ifdef MODULE
      ret_val |= STATE_OUT;			// AMdR - Jul 22, 2008
#endif
    }
#endif // (POPULATION_NR > 0)

  if (!Resume) WriteReport(my_argc, my_argv);	/* Write report file        */

#ifndef MODULE

  while (!((env[0] >= max_time) || ForcedRunEnd))
    CohortCycle(next_cohort_end);
						/* Program shut down        */
  ShutDown(0);					/* procedure                */

  return 0;
#else
  return (ret_val | error_code);		// AMdR - Jul 22, 2008
#endif
}



/*==========================================================================*/
