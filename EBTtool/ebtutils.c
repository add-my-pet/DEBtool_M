/***
   NAME
     ebtutils.c
   PURPOSE
     This file contains the output routines FileOut() and FileState() plus
     all low level routines that are processing memory allocation
     requests and issuing error and warning messages. The routines are
     called from a number of different modules.
   NOTES

   HISTORY
     AMdR - Jul 19, 1995 : Created.
     AMdR - May 13, 2016 : Revised last.
***/
#define	EBTUTILS_C				/* Identification of file   */
#define	EBTLIB					/* and file grouping	    */

#include "escbox.h"				/* Include general header   */
#include "ebtmain.h"
#include "ebtstop.h"
#include "ebtutils.h"

/* Bas Kooijman 2020/04/02 */
#include "ebttint.h"

#include "ebtcsbdefs.h"                         /* Definition of Envdim and Popdim*/

#ifdef __cplusplus
#undef EBTDEBUG
#define EBTDEBUG(a)	0
#endif

#if (HAS_MALLINFO && EBTDEBUG(5))
#include "malloc.h"
#endif /* HAS_MALLINFO */

// Magic key of the type of CSB file written
const uint32_t		CSB_MAGIC_KEY = 20030509;



/*==========================================================================*/
/*
 * The error messages that occur in the routines in the present file.
 */

#define ECSB "Error writing to CSB file. Further state output will be disabled!"
#define IPAC "Invalid population number in request to add cohorts: AddCohorts()!"
#define ICAC "Invalid cohort number in request to add cohorts: AddCohorts()!"
#define MAFC "Memory allocation failure for cohort variables!"
#define MAFI "Memory allocation failure for cohort constants!"



/*==========================================================================*/
/*
 * Start of function implementations.
 */
/*==============================================================================*/

int	  imin(int a, int b)

{
  return (a < b) ? a : b;
}




/*==============================================================================*/

int	  imax(int a, int b)

{
  return (a > b) ? a : b;
}




/*==============================================================================*/

double	  min(double a, double b)

{
  return (a < b) ? a : b;
}




/*==============================================================================*/

double	  max(double a, double b)

{
  return (a > b) ? a : b;
}




/*==============================================================================*/

int	  iszero(double a)

{
  /*
   * return (fabs(a) < equal2zero);
   */

  return (fabs(a) < identical_zero);
}




/*==============================================================================*/

int	  ismissing(double a)

{
  return (fabs(a) > 0.95*MISSING_VALUE);
}




/*==============================================================================*/

int	  isequal(double a, double b)

{
  double		diff;

  diff = fabs(a - b);

  /*
   * return ((diff < equal2zero) || (diff < 0.5*equal2zero*(fabs(a)+fabs(b))));
   */

  return ((diff < identical_zero) || (diff < 0.5*identical_zero*(fabs(a)+fabs(b))));
}




/*==============================================================================*/

void	  SetStepSize(double newstep)

{
  step_size = newstep;

  return;
}




/*==============================================================================*/

void	  ErrorAbort(CONST char *mes)

  /*
   * ErrorAbort - Routine issues an error message and exits immediately
   *		  without trying to save the state of the system.
   */

{
#ifndef MODULE
  char                  rn[MAXFILENAMELEN];

  (void)strcpy(rn, runname);
  rn[strlen(rn)-1] = '\0';			// Remove trainling dot

  (void)fprintf(stderr, "\nRUN %-s: ERROR at T = %.2f:\n", rn, env[0]);
  (void)fprintf(stderr, "** %-70s **\n", mes);
  (void)fprintf(stderr, "** %-70s **\n\n",
		"Normal closure of output files failed.");
  exit(1);
#else
  strcpy(error_msg, mes);
  strcat(error_msg, "\nNormal closure of output files failed.");
  error_code |= FATAL_ERROR;
#endif

  return;
}


/*==========================================================================*/

void	  ErrorExit(CONST int exitcode, CONST char *mes)

  /*
   * ErrorExit - Routine issues an error message and tries to call the
   *		 ShutDown() routine to save the state of the system. The
   *		 program subsequently terminates.
   */

{
#ifndef MODULE
  char                  rn[MAXFILENAMELEN];

  (void)strcpy(rn, runname);
  rn[strlen(rn)-1] = '\0';			// Remove trainling dot

  (void)fprintf(stderr, "\nRUN %-s: ERROR at T = %.2f:\n", rn, env[0]);
  (void)fprintf(stderr, "** %-70s **\n", mes);
  (void)fprintf(stderr, "** %-70s **\n\n",
		"Normal closure of output files attempted.");
  ShutDown(exitcode);
#else
  // put things in error message for tool to read
  strcpy(error_msg, mes);
  strcat(error_msg, "\nNormal closure of output files attempted.");
  error_code |= FATAL_ERROR;
#endif

  return;
}



/*==========================================================================*/

void	  Warning(CONST char *mes)

  /*
   * Warning - Routine issues a warning message pertaining to the current
   *	       state of the program. The program continues normally.
   */

{
#ifndef MODULE
  char                  rn[MAXFILENAMELEN];

  (void)strcpy(rn, runname);
  rn[strlen(rn)-1] = '\0';			// Remove trainling dot

  (void)fprintf(stderr, "\nRUN %-s: WARNING at T = %.2f:\n", rn, env[0]);
  (void)fprintf(stderr, "** %-70s **\n", mes);
  (void)fprintf(stderr, "** %-70s **\n\n", "Program continues normally.");
#else
  strcpy(error_msg, mes);
  strcat(error_msg, "\nProgram continues normally.");
  error_code |= WARNING;
#endif

  return;
}




/*==========================================================================*/
#if (HAS_MALLINFO && EBTDEBUG(5))
#define SKIP_CALLS	10
static long unsigned	call_nr = 0L;
struct mallinfo		malloc_info;
#endif /* HAS_MALLINFO */

void	*Myalloc(void *pnt, size_t count, size_t eltsize)

  /*
   * Myalloc - Replacement routine for the 'calloc()' and 'realloc()'
   *	       functions.  Allocates or reallocates memory and sets it to 0.
   *	       Implemented to watch memory use.
   */

{
  size_t		size;
  void			*value;

#if (HAS_MALLINFO && EBTDEBUG(5))
  call_nr++;
  if (!(call_nr%SKIP_CALLS))
    {
      malloc_info = mallinfo();
      (void)fprintf(stderr, "Myalloc #%12ld  in:", call_nr);
      (void)fprintf(stderr, "\tBlocks free: %8d  total: %8d",
		    malloc_info.fordblks,
		    malloc_info.uordblks);
      (void)fprintf(stderr, "\tChunks free: %8d  Arena: %8d  \n",
		    malloc_info.ordblks,
		    malloc_info.arena);
    }
#endif /* HAS_MALLINFO */

  size	= count * eltsize;
  if (pnt)					/* Reallocation call        */
      value = (void *)realloc((DEF_TYPE *)pnt, (SIZE_TYPE)size);
  else						/* Allocation call	    */
    {
      value = (void *)malloc((SIZE_TYPE)size);
      if (value != NULL) (void)memset((DEF_TYPE *)value, 0, size);
    }

#if (HAS_MALLINFO && EBTDEBUG(5))
  if (!(call_nr%SKIP_CALLS))
    {
      malloc_info = mallinfo();
      (void)fprintf(stderr, "Myalloc #%12ld out:", call_nr);
      (void)fprintf(stderr, "\tBlocks free: %8d  total: %8d",
		    malloc_info.fordblks,
		    malloc_info.uordblks);
      (void)fprintf(stderr, "\tChunks free: %8d  Arena: %8d  \n",
		    malloc_info.ordblks,
		    malloc_info.arena);
    }
#endif /* HAS_MALLINFO */

  return value;
}



/*==========================================================================*/

void	  PrettyPrint(FILE *fp, double value)

/*
 * PrettyPrint - Formatted print of output to the file pointed to by fp.
 */

{
#if !defined(_MSC_VER)
  int fpclass = fpclassify(value);

  if (fpclass == FP_NORMAL)
#endif
    {
      if (((fabs(value) <= 1.0E4) && (fabs(value) >= 1.0E-4)) || (value == 0))
	(void)fprintf(fp, "%.10f", value);
      else
	(void)fprintf(fp, "%.6E", value);
    }
#if !defined(_MSC_VER)
  else (void)fprintf(fp, "%E", value);
#endif

  return;
}
/*==========================================================================*/

void	  WriteStateToFile(FILE *fp, double *data)

/*
 * WriteStateToFile - Routine writes the entire state of the populations
 *		      and the environment to the file pointed to by fp.
 */

{
  register int		i;

  // Write environment state
  for(i=0; i<ENVIRON_DIM; i++)
    {
      if (i) (void)fprintf(fp, "\t");
      if (data) PrettyPrint(fp, data[i]);
      else PrettyPrint(fp, env[i]);
    }
  (void)fprintf(fp, "\n\n");

#if (POPULATION_NR > 0)
  register int		j, k;
  int			len = ENVIRON_DIM;
  population		lpop = NULL;

  for(i=0; i<POPULATION_NR; i++)
    {
      // Write boundary cohorts
      if (data) lpop = (population)(data + len + CohortNo[i]*COHORT_SIZE);
      for(j=BpointNo[i]-1; (j>=0); j--)
	{
	  for(k=0; k<COHORT_SIZE; k++)
	    {
	      if (k) (void)fprintf(fp, "\t");
	      if (data) PrettyPrint(fp, lpop[j][k]);
	      else PrettyPrint(fp, ofs[i][j][k]);
	    }
#if (I_CONST_DIM > 0)
	  for(k=0; k<I_CONST_DIM; k++)
	    {
	      (void)fprintf(fp, "\t");
	      PrettyPrint(fp, ofsIDcard[i][j][k]);
	    }
#endif
	  (void)fprintf(fp, "\n");
	}

      // Write internal cohorts
      if (data) lpop = (population)(data + len);
      for(j=CohortNo[i]-1; (j>=0); j--)
	{
	  for(k=0; k<COHORT_SIZE; k++)
	    {
	      if (k) (void)fprintf(fp, "\t");
	      if (data) PrettyPrint(fp, lpop[j][k]);
	      else PrettyPrint(fp, pop[i][j][k]);
	    }
#if (I_CONST_DIM > 0)
	  for(k=0; k<I_CONST_DIM; k++)
	    {
	      (void)fprintf(fp, "\t");
	      PrettyPrint(fp, popIDcard[i][j][k]);
	    }
#endif
	  (void)fprintf(fp, "\n");
	}

      if (!CohortNo[i])
	{
	  for(j=0; j<(COHORT_SIZE+I_CONST_DIM); j++)
	    {
	      if (j) (void)fprintf(fp, "\t");
	      (void)fprintf(fp, "%f", 0.0);
	    }
	  (void)fprintf(fp, "\n");
	}
      else len += (CohortNo[i]+BpointNo[i])*COHORT_SIZE;

      (void)fprintf(fp, "\n");
    }
#endif // (POPULATION_NR > 0)

  return;
}




/*==========================================================================*/
#if (POPULATION_NR > 0)

static void	  WriteBinStateToFile(FILE *fp)

/*
 * WriteBinStateToFile - Routine writes the entire state of the populations
 *		         and the environment in binary format to the file
 *			 pointed to by fp.
 */

{
  register int		i, j, k;
  int			writeOK;
  size_t		hdrdbls, lbldbls;
  Envdim		cenv[2];
  Popdim		cpop[2];
  double		zero = 0.0;

  hdrdbls  = (sizeof(Envdim)/sizeof(double))+1;
  (void)memset((DEF_TYPE *)cenv, 0, hdrdbls*sizeof(double));

  cenv->timeval      = env[0];
  cenv->columns      = ENVIRON_DIM;
  cenv->data_offset  = hdrdbls;
  cenv->memory_used  = hdrdbls*sizeof(double);
  cenv->memory_used += ENVIRON_DIM*sizeof(double);
  for (i=0; i<POPULATION_NR; i++)
    {
      hdrdbls = (sizeof(Popdim)/sizeof(double))+1;
      lbldbls = (strlen(statelabels[i])*sizeof(char))/sizeof(double)+1;
      cenv->memory_used += (hdrdbls+lbldbls)*sizeof(double);
      cenv->memory_used += (imax(CohortNo[i], 1)*
			    (COHORT_SIZE+I_CONST_DIM)*sizeof(double));
    }

  hdrdbls  = (sizeof(Envdim)/sizeof(double))+1;
  writeOK  = (fwrite((void *)cenv, 1, hdrdbls*sizeof(double), fp) == (hdrdbls*sizeof(double)));

  if (writeOK)
    writeOK = (fwrite((void *)env, 1, ENVIRON_DIM*sizeof(double), fp) == (ENVIRON_DIM*sizeof(double)));

  for (i=0; (i<POPULATION_NR) && (writeOK); i++)
    {
      hdrdbls = (sizeof(Popdim)/sizeof(double))+1;
      lbldbls = (strlen(statelabels[i])*sizeof(char))/sizeof(double)+1;
      (void)memset((DEF_TYPE *)cpop, 0, hdrdbls*sizeof(double));
      cpop->timeval     = env[0];
      cpop->population  = i;
      cpop->columns     = (COHORT_SIZE+I_CONST_DIM);
      cpop->cohorts     = imax(CohortNo[i], 1);
      cpop->data_offset = hdrdbls+lbldbls;
      cpop->lastpopdim  = (i == (POPULATION_NR-1));

      writeOK = (fwrite((void *)cpop, 1, hdrdbls*sizeof(double), fp) == (hdrdbls*sizeof(double)));
      if (!writeOK) break;

      writeOK = (fwrite((void *)statelabels[i], 1, lbldbls*sizeof(double), fp) == (lbldbls*sizeof(double)));
      if (!writeOK) break;

      if (CohortNo[i])
	{
	  for(k=0; (k<COHORT_SIZE) && writeOK; k++)
	    for(j=CohortNo[i]-1; (j>=0) && writeOK; j--)
	      writeOK = (fwrite((void *)(pop[i][j]+k), sizeof(double), 1, fp) == 1);
#if (I_CONST_DIM > 0)
	  for(k=0; (k<I_CONST_DIM) && writeOK; k++)
	    for(j=CohortNo[i]-1; (j>=0) && writeOK; j--)
	      writeOK = (fwrite((void *)(popIDcard[i][j]+k), sizeof(double), 1, fp) == 1);
#endif
	}
      else
	for(k=0; (k<(COHORT_SIZE+I_CONST_DIM)) && writeOK; k++)
	  writeOK = (fwrite((void *)&zero, sizeof(double), 1, fp) == 1);
    }

  (void)fflush(fp);				/* Flush the file buffer    */

  if (!writeOK)
    {
      Warning(ECSB);
      (void)fclose(fp);
      csbfil = NULL;
    }

  return;
}


#endif // (POPULATION_NR > 0)


/*==========================================================================*/

void	  FileOut()

  /*
   * FileOut - Routine sends output to file. All output statistics are
   *	       defined by the user, except for the first one which is the
   *	       current time value.
   */

{
  register int		i;

  for(i=0; i<OUTPUT_VAR_NR; i++) output[i]=0.0;
#if (POPULATION_NR > 0)
  for(i=0; i<POPULATION_NR; i++) cohort_no[i] = CohortNo[i];
#endif // (POPULATION_NR > 0)

#if (POPULATION_NR > 0)
  DefineOutput(env, pop, output);		/* User output values       */
#else
  DefineOutput(env, NULL, output);		/* User output values       */
#endif // (POPULATION_NR > 0)

#if (BIFURCATION == 1)
  // Add bifurcation parameter as last column
  output[OUTPUT_VAR_NR] = parameter[BifParIndex];
#endif // (BIFURCATION == 1)

  (void)fprintf(resfil, "%.2f", env[0]);
  for(i=0; i<exp_output_var_nr(); i++)
    {
      (void)fprintf(resfil, "\t");
      PrettyPrint(resfil, output[i]);
    }
  (void)fprintf(resfil, "\n"); (void)fflush(resfil);

  for(i=exp_output_var_nr(); i>0; i--) output[i] = output[i-1];
  output[0] = env[0];

  return;
}




/*==========================================================================*/
#if (POPULATION_NR > 0)

void	  FileState()

  /*
   * FileState - Routine writes the entire state of the environment and all
   *		 populations to the '.csb' file.
   */

{
  uint32_t		tmpint32;
  int			tmpint;
  int			writeOK = 1;

  if (csbfil && csbnew)
    { // New CSB file: Write magic key and parameters
      tmpint32 = CSB_MAGIC_KEY;
      writeOK = (fwrite((void *)(&tmpint32), 1, sizeof(uint32_t), csbfil) == sizeof(uint32_t));
      tmpint  = PARAMETER_NR;
      if (writeOK)
	writeOK = (fwrite((void *)(&tmpint), 1, sizeof(int), csbfil) == sizeof(int));
      if (writeOK)
	writeOK = (fwrite((void *)(&parameter), PARAMETER_NR, sizeof(double), csbfil) == sizeof(double));
      csbnew = 0;
    }

  if (!writeOK)
    {
      Warning(ECSB);
      (void)fclose(csbfil);
      csbfil = NULL;
    }
  if (csbfil) WriteBinStateToFile(csbfil);	/* Append state to .csb file*/

  return;
}




/*==========================================================================*/

int	AddCohorts(population *pop, int popnr, int cohnr)

  /*
   * AddCohorts - Routine extends the population with number "popnr"
   *		  with "cohnr" cohorts. Routine can be called by user
   *		  in, for example, the routine UserInit().
   */

{
  int			newindex;
  uint32_t		mem_req;

  if ((popnr < 0) || (popnr >= POPULATION_NR)) Warning(IPAC);
  if (cohnr <1) Warning(ICAC);

  mem_req = (CohortNo[popnr]+cohnr)*COHORT_SIZE;
  if (!(mem_req < DataMemAllocated[popnr]))
    {
      DataMemAllocated[popnr] = MemBlocks(mem_req);
      pop[popnr] = (population)Myalloc((void *)pop[popnr],
				       (size_t)DataMemAllocated[popnr],
				       sizeof(double));
      if(!(pop[popnr])) ErrorAbort(MAFC);
#ifdef MODULE
      if (error_code & FATAL_ERROR) return -1;	// ok?
#endif
    }
#if (I_CONST_DIM > 0)
  mem_req = (CohortNo[popnr]+cohnr)*I_CONST_DIM;
  if (!(mem_req < IDMemAllocated[popnr]))
    {
      IDMemAllocated[popnr] = MemBlocks(mem_req);
      popIDcard[popnr] = (popID)Myalloc((void *)popIDcard[popnr],
					(size_t)IDMemAllocated[popnr],
					sizeof(double));
      if(!(popIDcard[popnr])) ErrorAbort(MAFI);
#ifdef MODULE
      if (error_code & FATAL_ERROR) return -1;	// ok?
#endif
    }
#endif

  newindex = CohortNo[popnr];
  CohortNo[popnr] += cohnr;
  cohort_no[popnr] = CohortNo[popnr];

  return newindex;
}
#endif // (POPULATION_NR > 0)




/*==========================================================================*/
#if (POPULATION_NR > 0)
void LabelState(int popnr, const char *fmt, ...)

{
  va_list		argpnt;
  char			tmpbuf[1024];

  va_start(argpnt, fmt);
  vsprintf(tmpbuf, fmt, argpnt);
  va_end(argpnt);
  strncpy(statelabels[popnr], tmpbuf, (DESCRIP_MAX-1)*sizeof(char));
  statelabels[popnr][DESCRIP_MAX-1] = '\0';

  return;
} /* LabelState */

#endif


/*==========================================================================*/
#if (BIFURCATION == 1)

static double		next_bif_output;
static int		DoBifOutput = 0;

#if (MEASUREBIFSTATS == 1)
#include "ebtbifstats.c"
#endif

void	SetBifOutputTimes(double *env)

{
  static int			first = 1;

  // At start no (state) output
  if (first)
    {
      BifPeriod		= max_time;

      if (BifParLogStep)
	max_time        = ceil((log10(BifParLastVal/parameter[BifParIndex])/BifParStep) + 1.0 + BIFTINY);
      else
	max_time        = floor(((BifParLastVal - parameter[BifParIndex])/BifParStep) + 1.0 + BIFTINY);

      max_time	       *= BifPeriod;

      next_state_output = ((floor((BIFTINY+env[0])/BifPeriod)+1)*BifPeriod -
			   BifStateOutput);
      next_output	= ((floor((BIFTINY+env[0])/BifPeriod)+1)*BifPeriod -
			   BifOutput);
      next_bif_output   =  (floor((BIFTINY+env[0])/BifPeriod)+1)*BifPeriod;

      first = 0;

      return;
    }

  if (env[0] >= (next_bif_output-identical_zero))
    {
      // If env[0] equal to integer multiple of BifPeriod both state output
      // and regular output, unless this already last time we were here

      next_state_output  = env[0];
      next_output        = env[0];
      next_bif_output   += BifPeriod;

      DoBifOutput = 1;
    }
  else
    {
      // Otherwise schedule next state output for the end of the
      // current period with constant bifurcation parameter and
      // regular output for the last BifOutput timesteps of this
      // period
      //
      next_state_output = max(next_state_output, next_bif_output - BifStateOutput);
      next_output	= max(next_output, next_bif_output - BifOutput);
      DoBifOutput = 0;
    }

  return;
}

#endif // (BIFURCATION == 1)



/*=============================================================================*/
