/***
   NAME
     ebtstop.c
   PURPOSE
     This file contains the ShutDown() routine and the routine
     WriteRepport() to generate a report of the run statistics. 
   NOTES
     
   HISTORY
     AMdR - Jul 20, 1995 : Created.
     AMdR - Feb 11, 2018 : Revised last.
***/

#define	EBTSTOP_C				/* Identification of file   */
#define	EBTLIB					/* and file grouping        */

#include "escbox.h"				/* Include general header   */
#include "ebtmain.h"
#include "ebtstop.h"
#include "ebtutils.h"


/* Bas Kooijman 2020/04/02 */
#include "ebttint.h"

/*==========================================================================*/
/*
 * The error messages that occur in the routines in the present file.
 */

#define ESF  "Unable to open ESF file for storing end state of populations!"
#define REP  "Unable to open REP file for generating report file of the run!"
#define MARN "Memory allocation failure in storing user defined report notes!"



/*==========================================================================*/
/*
 * Start of function implementations.
 */
						/* ARGSUSED                 */
#ifndef MODULE
EXTERN_C void	ShutDown(int exitcode)
#else
EXTERN_C int	ShutDown(int exitcode)
#endif

  /* 
   * ShutDown - Routine closes the output file and saves the entire end
   *		state of the population and the environment in the end
   *		state file. 
   */

{
  char                  filename[MAXFILENAMELEN];
  FILE                  *esf;

  if (resfil) (void)fclose(resfil);		/* Close result file        */
  if (csbfil) (void)fclose(csbfil);		/* Close binary state file  */

#if ((BIFURCATION == 1) && (MEASUREBIFSTATS == 1))
  if (averages)  (void)fclose(averages);	// Close bifurcation output
  if (gaverages) (void)fclose(gaverages);	// files
  if (variances) (void)fclose(variances);
  if (extrema)   (void)fclose(extrema);
#endif
						/* Save final state         */
						/* Open ESF file with       */
						/* lower case extension     */
  (void)strcpy(filename, runname);
  (void)strcat(filename, "esf");
  esf=fopen(filename, "w");
  if(!esf)                                      /* On error try upper case  */
    {
      (void)strcpy(filename, runname); (void)strcat(filename, "ESF");
      esf=fopen(filename, "w");
      if(!esf) ErrorAbort(ESF);                 /* On repeated error exit   */
#ifdef MODULE
      if (error_code & FATAL_ERROR) return error_code;
#endif
    }

  WriteStateToFile(esf, NULL);			/* Write state to .esf file */
  (void)fclose(esf);                            /* Close end state file     */

#ifndef MODULE
  (void)strcpy(filename, runname);
  filename[strlen(filename)-1] = '\0';		// Remove trainling dot
  (void)fprintf(stderr, "\n\nRUN %-s COMPLETED at T = %.2f:\n", filename, env[0]);
  (void)fprintf(stderr, "** %-70s **\n\n", 
	  "Program terminated. Normal closure of output files succeeded.");

  (void)fflush(stdout); 
  (void)fflush(stderr);

  if (exitcode >= 0)
    {
#if (DEBUG > 0)
      if (exitcode) abort();
      else
#endif  /* DEBUG */
      exit(exitcode);
    }
  return;
#else
  return error_code;
#endif /* MODULE */
}



/*==========================================================================*/

void ReportNote(const char *fmt, ...)

{
  va_list		argpnt;
  register int		i;
  static int		lines = 0, count = 0;
  
  if ((!usernotes) || (count >= (lines-1)))
    {
      lines += 10;
      usernotes = (char **)Myalloc((void *)usernotes,
				   (size_t)lines, sizeof(char *));
      if (!usernotes) ErrorAbort(MARN);
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif
      for (i=count; i<lines; i++) usernotes[i] = (char *)NULL;
    }
  usernotes[count] = (char *)Myalloc((void *)NULL, REPORTNOTE_MAX, sizeof(char));
  if (!(usernotes[count])) ErrorAbort(MARN);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif

  va_start(argpnt, fmt);
#ifdef _MSC_VER
  _vsnprintf(usernotes[count], REPORTNOTE_MAX, fmt, argpnt);
#else
  vsnprintf(usernotes[count], REPORTNOTE_MAX, fmt, argpnt);
#endif
  va_end(argpnt);
  
  count++;

  return;
} /* ReportNotes */



/*==========================================================================*/

void	  WriteReport(int argc, char **argv)

{
  register int		i;
  char			filename[MAXFILENAMELEN], *ch, **unp;
  FILE			*rep;
						/* Open REP file with	    */
						/* lower case extension	    */
  ch=strcpy(filename, runname); ch=strcat(filename, "rep");
  rep=fopen(filename, "w");
  
  if(!rep)					/* On error try upper case  */
    {
      ch=strcpy(filename, runname); ch=strcat(filename, "REP");
      rep=fopen(filename, "w");
      if(!rep) ErrorAbort(REP);			/* On repeated error exit   */
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif
    }
  
  while(*ch) ch++;
  while(*(--ch)!='.') *ch=' ';
  *ch='\0';
  
  for(i=0; i<79; i++) (void)fprintf(rep, "*");
  (void)fprintf(rep, "\n");
  (void)fprintf(rep, "\n%2s%-s\n", " ", "PROGRAM, RUN AND ARGUMENTS");
  (void)fprintf(rep, "%4sProgram   : %-s\n", " ", progname);
  (void)fprintf(rep, "%4sRun       : %-s\n", " ", filename);
  (void)fprintf(rep, "%4sArguments : ", " ");
  for (i=2; i<argc; i++) (void)fprintf(rep, " %-s", argv[i]);
  (void)fprintf(rep, "\n");

  if (usernotes)
    {
      unp = usernotes;
      (void)fprintf(rep, "\n%2s%-s\n", " ", "MODEL SPECIFIC NOTES");
      while (*unp)
	{
	  (void)fprintf(rep, "%4s%-s\n", " ", *unp);
	  unp++;
	}
    }
  
  (void)fprintf(rep, "\n%2s%-s\n", " ", "USED VALUES FOR CONTROL VARIABLES");
  (void)fprintf(rep, "%4s%-65s%5s%-s\n", " ", 
		"Time integration method", "  :  ",
#if    (TIME_METHOD ==  RK2)
                "RK2");
#elif  (TIME_METHOD ==  RK4)
                "RK4");
#elif  (TIME_METHOD  == RKF45)
		"RKF45");
#elif  (TIME_METHOD ==  RKCK)
                "RKCK");
#elif  (TIME_METHOD ==  DOPRI5)
                "DOPRI5");
#elif  (TIME_METHOD ==  DOPRI8)
                "DOPRI8");
#elif  (TIME_METHOD ==  RADAU5)
                "RADAU5");
#else
		"RKCK");
#endif
  (void)fprintf(rep, "%4s%-65s%5s%-10.4G\n", " ", 
		description.accuracy, "  :  ", accuracy);
  (void)fprintf(rep, "%4s%-65s%5s%-10.4G\n", " ", 
		description.cohort_limit, "  :  ", cohort_limit);
  (void)fprintf(rep, "%4s%-65s%5s%-10.4G\n", " ", 
		description.identical_zero, "  :  ", identical_zero);

  (void)fprintf(rep, "%4s%-65s%5s%-10.2f\n", " ", 
		description.max_time, "  :  ", max_time);
  (void)fprintf(rep, "%4s%-65s%5s%-10.2f\n", " ", 
		description.delt_out, "  :  ", delt_out);

#if (POPULATION_NR > 0)
  register int		j;

  (void)fprintf(rep, "%4s%-65s%5s%-10.2f\n", " ", 
		description.state_out, "  :  ", state_out);
  
  (void)fprintf(rep, "\n%2s%-s\n", " ", "USED VALUES OF TOLERANCES");

  (void)fprintf(rep, "%4s%-65s%5s", " ",
		description.abs_tols[number], "  :  ");
  for(i=0; i<POPULATION_NR; i++)
      (void)fprintf(rep, "%-7.4G", abs_tols[i][number]);
  (void)fprintf(rep, "\n");

  for(j=0; j<I_STATE_DIM; j++)
    {
      (void)fprintf(rep, "%4s%-65s%5s", " ",
		    description.rel_tols[i_state(j)], "  :  ");
      for(i=0; i<POPULATION_NR; i++)
	  (void)fprintf(rep, "%-7.4G", rel_tols[i][i_state(j)]);
      (void)fprintf(rep, "\n");
    }
  
  for(j=0; j<I_STATE_DIM; j++)
    {
      (void)fprintf(rep, "%4s%-65s%5s", " ",
		    description.abs_tols[i_state(j)], "  :  ");
      for(i=0; i<POPULATION_NR; i++)
	  (void)fprintf(rep, "%-7.4G", abs_tols[i][i_state(j)]);
      (void)fprintf(rep, "\n");
    }
#endif // (POPULATION_NR > 0)
  
#if PARAMETER_NR
  (void)fprintf(rep, "\n%2s%-s\n", " ", "USED VALUES OF PARAMETERS");
  
  for(i=0; i<PARAMETER_NR; i++)
      (void)fprintf(rep, "%4s%-65s%5s%-10.4G\n", " ", 
		    description.parameter[i], "  :  ", parameter[i]);
#endif

#if (BIFURCATION == 1)
  (void)fprintf(rep, "\n%2s%-s\n", " ", "USED VALUES OF BIFURCATION VARIABLES");
  
  (void)fprintf(rep, "%4s%-65s%5s%-4d\n", " ", 
		description.bifparindex, "  :  ", BifParIndex);

  (void)fprintf(rep, "%4s%-65s%5s%-10.4G\n", " ", 
		description.bifparstep , "  :  ", BifParStep);

  (void)fprintf(rep, "%4s%-65s%5s%-10.4G\n", " ", 
		description.bifparlastval , "  :  ", BifParLastVal);

  (void)fprintf(rep, "%4s%-65s%5s%-4d\n", " ", 
		description.bifparlogstep, "  :  ", BifParLogStep);

  (void)fprintf(rep, "%4s%-65s%5s%-10.4G\n", " ", 
		description.bifoutput , "  :  ", BifOutput);

#if (POPULATION_NR > 0)
  (void)fprintf(rep, "%4s%-65s%5s%-10.4G\n", " ", 
		description.bifstateoutput , "  :  ", BifStateOutput);
#endif // (POPULATION_NR > 0)
#endif // (BIFURCATION == 1)

  for(i=0; i<79; i++) (void)fprintf(rep, "*");
  (void)fprintf(rep, "\n");
  
  (void)fclose(rep);
  
  return;
}



/*==========================================================================*/
