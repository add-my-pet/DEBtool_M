/***
   NAME
     ebtinit.c
   PURPOSE
     This file contains the Initialize() routine and all functions that are
     used by it to initialize global variables, to read the input file with
     the initial state values of the environment and the populations and to
     read the control variable file. 
   NOTES
     
   HISTORY
     AMdR - Jul 21, 1995 : Created.
     AMdR - Dec 27, 2012 : Revised last.
***/

#define	EBTINIT_C				/* Identification of file   */
#define	EBTLIB					/* and file grouping	    */

#include "escbox.h"				/* Include general header   */
#include "ebtinit.h"
#include "ebtmain.h"
#include "ebtcohrt.h"
#include "ebtutils.h"

/* Bas Kooijman 2020/04/02 */
#include "ebttint.h"

/*==========================================================================*/
/*
 * Defining all constants that are local to this specific file.
 */
						/* The maximum length of    */
#define	  MAX_INPUT_LINE 2048			/* a line of input	    */




/*==========================================================================*/
/*
 * The error messages that occur in the routines in the present file.
 */

#define DBG  "Unable to open DBG file for event location information!"
#define CVF  "Unable to open CVF file with control variables for program!"
#define EACC "Error during input of accuracy value from CVF file!"
#define EATL "Error during input of absolute tolerances from the CVF file!"
#define EBIF "Error during input of bifurcation control variables from the CVF file!"
#define ECL  "Error during input of cohort time limit from CVF file!"
#define ECSO "Error during reading of state output interval from CVF file!"
#define ECVF "Unexpected end/error while reading CVF file!"
#define EENV "Unexpected end/error while reading environment from ISF file!"
#define EISF "Unexpected end/error while reading populations from ISF file!"
#define EIZ  "Error during input of zero comparison value from CVF file!"
#define EMIN "Error during input of the cohort minima from the CVF file!"
#define EMT  "Error during input of maximum integration time from CVF file!"
#define EOUT "Error during reading of output time interval from CVF file!"
#define ERTL "Error during input of relative tolerances from the CVF file!"
#define FISF "ESF file not found for resuming; Using ISF file instead!"
#define ICS  "Incomplete cohort specification(s) encountered in ISF file!"
#define ISF  "Unable to open ISF file! Expecting initialization in UserInit()!"
#define MAFC "Memory allocation failure for cohort variables!"
#define MAFI "Memory allocation failure for cohort constants!"
#define NEA  "Not enough arguments : Usage '<program name> <run name>'"
#define OUT  "Failure in opening OUT file for writing!"
#define RETS "Relative accuracy required too small. Use accuracy > 1.0E-12!"
#define WNEV "Incomplete environment specification encountered in ISF file! Expecting initialization in UserInit()!"


/*==========================================================================*/
/*
 * Start of function implementations.
 */
/*==========================================================================*/

static char	*ReadDouble(double *val, char *cpnt)

  /* 
   * ReadDouble - Routine reads a double value from the string pointed to
   *		  by "cpnt". Invalid characters are skipped. It returns a 
   *		  pointer to the rest of the string or NULL on error.
   */

{
  register char		*ch, *end=NULL;
  int			dot_start=0;

  ch=cpnt; while((!isdigit(*ch)) && *ch) ch++;	/* Skip non digits          */
  if(isdigit(*ch))
    {
      end=ch;
      if((ch!=cpnt) && (*(ch-1)=='.'))		/* Is previous a dot?	    */
	{
	  ch--; dot_start=1;
	}
      if((ch!=cpnt) && (*(ch-1)=='-')) ch--;	/* Is previous a minus?	    */

      while(isdigit(*end)) end++;		/* Skip digits		    */
      if((!dot_start) && (*end=='.'))		/* Dot starts mantissa	    */
	{
	  end++; while(isdigit(*end)) end++;
	}

      if((*end=='e') || (*end=='E'))		/* Possible exponent        */
	{
	  end++; if((*end=='+') || (*end=='-')) end++;
	  while(isdigit(*end)) end++;
	}
      *val = 0.0;
      (void)sscanf(ch, "%lg", val);
    }

  return end;
}



/*==========================================================================*/

static int	ScanLineDouble(FILE *infile, char *descr, double *value, int var_nr)

  /* 
   * ScanLineDouble - Routine reads one line from the control variable file, 
   *		      splits it up in the description and the value part and 
   *		      returns the number of values read. "var_nr" is the number
   *		      of variables to be read.
   */

{
  register char		*ch=NULL, *dsp;
  char			input[MAX_INPUT_LINE], tmp_str[MAX_INPUT_LINE];
  int			read_no=0, desclen = 0;

  // Input a single line. Skip empty lines and lines starting with a hatch (#) sign
  while((!feof(infile)) && (!ferror(infile)) && (!ch))
    {
      if ((ch=fgets(input, MAX_INPUT_LINE, infile)))
	{
	  while(*ch==' ') ch++;
	  if ((*ch == '#') || (*ch == '\n')) ch=NULL;
	}
    }
  if(feof(infile) || ferror(infile)) ErrorAbort(ECVF);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return read_no;
#endif

  dsp=descr;
  if(*ch == '"')				/* Comment is in quotes	    */
    {
      ch++;					/* Skip the first quote	    */
      while(*ch != '"')				/* Search for the closing   */
	{					/* quotes, storing string   */
	  if(desclen<DESCRIP_MAX) (*dsp)=(*ch); /* between them		    */
	  dsp++; ch++; desclen++;
	}
      ch++;					/* Skip closing quotes	    */
    }
  else						/* Comment is not quoted    */
    {
      while((!isdigit(*ch)) && *ch)		/* Skip non-digits and put  */
	{					/* them in description	    */
	  if(desclen<DESCRIP_MAX) (*dsp)=(*ch);
	  dsp++; ch++; desclen++;
	}					/* Remove trailing blanks   */
						/* and tabs                 */
      while((*(dsp-1)==' ') || (*(dsp-1)=='\t')) *(--dsp)='\0';
    }
  descr[DESCRIP_MAX-1] = '\0';

  ch=strcpy(tmp_str, ch);			/* Copy rest to string      */

  while(ch)
      if((ch=ReadDouble(value+read_no, ch)) != NULL)
	  if((++read_no)==var_nr) return read_no;

  return read_no;
}



/*==========================================================================*/
#if (BIFURCATION == 1)

static char	*ReadInt(int *val, char *cpnt)

  /* 
   * ReadInt - Routine reads an integer value from the string pointed to
   *	       by "cpnt". Invalid characters are skipped. It returns a 
   *	       pointer to the rest of the string or NULL on error.
   */

{
  register char		*ch, *end=NULL;

  ch=cpnt; while((!isdigit(*ch)) && *ch) ch++;	/* Skip non digits          */

  if(isdigit(*ch))
    {
      end=ch;

      // Locate all consecutive digits
      while(isdigit(*end)) end++;

      // Turn into integer value
      *val = 0;
      (void)sscanf(ch, "%d", val);
    }

  return end;
}



/*==========================================================================*/

static int	ScanLineInt(FILE *infile, char *descr, int *value, int var_nr)

  /* 
   * ScanLineInt - Routine reads one line from the control variable file, 
   *		   splits it up in the description and the value part and 
   *		   returns the number of values read. "var_nr" is the number
   *		   of variables to be read.
   */

{
  register char		*ch=NULL, *dsp;
  char			input[MAX_INPUT_LINE], tmp_str[MAX_INPUT_LINE];
  int			read_no=0, desclen = 0;
						/* Input line		    */
  dsp=descr;					/* Skip empty lines	    */
  while((!feof(infile)) && (!ferror(infile)) && (!ch))
    {
      if ((ch=fgets(input, MAX_INPUT_LINE, infile)))
	{
	  while(*ch==' ') ch++;
	  if(*ch == '\n') ch=NULL;
	}
    }
  if(feof(infile) || ferror(infile)) ErrorAbort(ECVF);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return read_no;
#endif

  if(*ch == '"')				/* Comment is in quotes	    */
    {
      ch++;					/* Skip the first quote	    */
      while(*ch != '"')				/* Search for the closing   */
	{					/* quotes, storing string   */
	  if(desclen<DESCRIP_MAX) (*dsp)=(*ch); /* between them		    */
	  dsp++; ch++; desclen++;
	}
      ch++;					/* Skip closing quotes	    */
    }
  else						/* Comment is not quoted    */
    {
      while((!isdigit(*ch)) && *ch)		/* Skip non-digits and put  */
	{					/* them in description	    */
	  if(desclen<DESCRIP_MAX) (*dsp)=(*ch);
	  dsp++; ch++; desclen++;
	}					/* Remove trailing blanks   */
						/* and tabs                 */
      while((*(dsp-1)==' ') || (*(dsp-1)=='\t')) *(--dsp)='\0';
    }
  descr[DESCRIP_MAX-1] = '\0';

  ch=strcpy(tmp_str, ch);			/* Copy rest to string      */

  while(ch)
    if((ch=ReadInt(value+read_no, ch)) != NULL)
      if((++read_no)==var_nr) return read_no;

  return read_no;
}
#endif // (BIFURCATION == 1)



/*==========================================================================*/

static void	  InitVars()

  /* 
   * InitVars - Routine initializes all global variables to 0.
   */

{
  register int		i;

  step_size=DEFAULT_STEP;
  usernotes = NULL;

  for(i=0; i<ENVIRON_DIM; i++) env[i] = 0.0;	/* Create zero environment   */

  initState = NULL;
  currentState = NULL;
  for (i=0; i<MAXDERS; i++) currentDers[i] = NULL;
  ForcedRunEnd = 0;

#if (POPULATION_NR > 0)
  for(i=0; i<POPULATION_NR; i++)
    {
      CohortNo[i]=0;
      BpointNo[i]=0;
      tol_zero[i]= ((I_STATE_DIM > 0) ? 0:1);
      pop_extinct[i]=0;
      pop[i] = NULL;
      DataMemAllocated[i] = 0;
#if (I_CONST_DIM > 0)
      popIDcard[i]	= NULL;
      IDMemAllocated[i] = 0;
#endif

      strcpy(statelabels[i], "");		/* Create empty state labels */
    }
#endif // (POPULATION_NR > 0)

  return;
}



/*==========================================================================*/

static void	  ReadCvf(FILE *infile)

  /* 
   * ReadCvf - Routine reads all the values of the control variables from 
   *	       the already opened .cvf file.
   */

{
  register int		i;
  char			msg[MAX_INPUT_LINE];
  int			read_no;

  read_no=ScanLineDouble(infile, description.accuracy, &accuracy, 1);
  if(read_no != 1) ErrorAbort(EACC);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
  if(accuracy < MIN_ACCURACY) ErrorAbort(RETS);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
  read_no=ScanLineDouble(infile, description.cohort_limit, &cohort_limit, 1);
  if(read_no != 1) ErrorAbort(ECL);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
  read_no=ScanLineDouble(infile, description.identical_zero, &identical_zero, 1);
  if(read_no != 1) ErrorAbort(EIZ);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
  equal2zero = identical_zero;

  read_no=ScanLineDouble(infile, description.max_time, &max_time, 1);
  if(read_no != 1) ErrorAbort(EMT);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
  read_no=ScanLineDouble(infile, description.delt_out, &delt_out, 1);
  if(read_no != 1) ErrorAbort(EOUT);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif

#if (POPULATION_NR > 0)
  register int		j;
  double		tmp[POPULATION_NR];

  read_no=ScanLineDouble(infile, description.state_out, &state_out, 1);
  if(read_no != 1) ErrorAbort(ECSO);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif

  read_no=ScanLineDouble(infile, description.abs_tols[0], tmp, POPULATION_NR);
  if(read_no != POPULATION_NR) ErrorAbort(EMIN);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
  for(i=0; i<POPULATION_NR; i++) abs_tols[i][0] = tmp[i];
  
  for(j=1; j<COHORT_SIZE; j++)
    {
      read_no=ScanLineDouble(infile, description.rel_tols[j], tmp, POPULATION_NR);
      if(read_no != POPULATION_NR) ErrorAbort(ERTL);
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif
      for(i=0; i<POPULATION_NR; i++) rel_tols[i][j] = tmp[i];
    }
  for(j=1; j<COHORT_SIZE; j++)
    {
      read_no=ScanLineDouble(infile, description.abs_tols[j], tmp, POPULATION_NR);
      if(read_no != POPULATION_NR) ErrorAbort(EATL);
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif
      for(i=0; i<POPULATION_NR; i++) abs_tols[i][j] = tmp[i];
    }

  for(i=0; i<POPULATION_NR; i++) 
      for(j=1; j<COHORT_SIZE; j++) 
	  tol_zero[i] = (tol_zero[i] ||
			 ((rel_tols[i][j]<=0.0) && (abs_tols[i][j]<=0.0)));
#endif // (POPULATION_NR > 0)

#if PARAMETER_NR
  for(i=0; i<PARAMETER_NR; i++)
    {
      read_no=ScanLineDouble(infile, description.parameter[i], parameter+i, 1);
      if(read_no != 1)
	{
	  (void)sprintf(msg,
			"Error while reading parameter %d from CVF file!",
			i);
	  ErrorAbort(msg);
#ifdef MODULE
	  if (error_code & FATAL_ERROR) return;
#endif
	}
    }
#endif

#if (BIFURCATION == 1)
  read_no=ScanLineInt(infile, description.bifparindex, &BifParIndex, 1);
  if(read_no != 1) ErrorAbort(EBIF);

  if ((BifParIndex < 0) || (BifParIndex > PARAMETER_NR)) ErrorAbort(EBIF);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif

  read_no=ScanLineDouble(infile, description.bifparstep, &BifParStep, 1);
  if(read_no != 1) ErrorAbort(EBIF);

  // Sanitize the bifurcation control variable: Make it absolute
  BifParStep = fabs(BifParStep);
  if (BifParStep < SMALLEST_STEP) ErrorAbort(EBIF);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif

  read_no=ScanLineDouble(infile, description.bifparlastval, &BifParLastVal, 1);
  if(read_no != 1) ErrorAbort(EBIF);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif

  read_no=ScanLineInt(infile, description.bifparlogstep, &BifParLogStep, 1);
  if(read_no != 1) ErrorAbort(EBIF);

  // Sanitize the bifurcation control variable:
  // Check inappropriate values for log scale
  if (BifParLogStep &&
      ((fabs(parameter[BifParIndex]) < SMALLEST_STEP) || (fabs(BifParLastVal) < SMALLEST_STEP) ||
       (parameter[BifParIndex]*BifParLastVal < 0.0))) ErrorAbort(EBIF);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
  // Set the sign of bifurcation step size
  if (parameter[BifParIndex] > BifParLastVal) BifParStep *= -1;

  read_no=ScanLineDouble(infile, description.bifoutput, &BifOutput, 1);
  if(read_no != 1) ErrorAbort(EBIF);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
  // Sanitize the bifurcation control variable
  BifOutput = max(BifOutput, 0.0);
  BifOutput = min(BifOutput, max_time);

#if (POPULATION_NR > 0)
  read_no=ScanLineDouble(infile, description.bifstateoutput, &BifStateOutput, 1);
  if(read_no != 1) ErrorAbort(EBIF);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
#endif // (POPULATION_NR > 0)

  // Sanitize the bifurcation control variable
  BifStateOutput = max(BifStateOutput, 0.0);
  BifStateOutput = min(BifStateOutput, max_time);
#endif // (BIFURCATION == 1)

  return;
}



/*==========================================================================*/

static int	ReadInputEnv(FILE *infile)

  /* 
   * ReadInputEnv - Read the initial values of the environment variables 
   *		    from the already opened .isf file.
   */

{
  char			*ch, input[MAX_INPUT_LINE];
  int			read_no;
						/* Number of variables	    */
  read_no=0;					/* already read into array  */
  while((!feof(infile)) && (!ferror(infile)))
    {
      ch=fgets(input, MAX_INPUT_LINE, infile);	/* Input line		    */

						/* Read double from string, */
      while(ch)					/* stop on line end	    */
	  if((ch=ReadDouble(env+read_no, ch)) != NULL)
	      if((++read_no)==ENVIRON_DIM) return read_no;
    }						/* Stop loop if array	    */
						/* contains enough  data    */

  if(feof(infile) || ferror(infile)) Warning(EENV);

  return read_no;
}




/*==========================================================================*/
#if (POPULATION_NR > 0)

static void	  ReadInputPop(FILE *infile)

  /* 
   * ReadInputPop - Routine reads the initial values for the state of all 
   *		    populations from the already opened .isf file.
   */

{
  register int		i, j;
  char			*ch, input[MAX_INPUT_LINE];
  int			done, read_no, warnics = 1;
  double		val_tmp[COHORT_SIZE+I_CONST_DIM];
  long			mem_req;

  for(i=0; i<POPULATION_NR; i++)
    {						/* Flag indicating end of   */
      done=0;					/* population data	    */
      while((!feof(infile)) && (!ferror(infile)) && (!done))
	{					/* Input line		    */
	  ch=fgets(input, MAX_INPUT_LINE, infile);
						/* Initialize all data to   */
						/* default: MISSING_VALUE   */
	  for(j=0; j<(COHORT_SIZE+I_CONST_DIM); j++)
	    val_tmp[j] = MISSING_VALUE;
						/* Read complete cohort	    */
						/* from one line. Stop on   */
						/* line end or full cohort  */
	  for(j=0, read_no=0; (j<(COHORT_SIZE+I_CONST_DIM)) && (ch); j++)
	      if((ch=ReadDouble(val_tmp+j, ch)) != NULL) read_no++;
						/* End of population reached*/
          if ((read_no == 0) && CohortNo[i]) done = 1;
	  else if (read_no > 0)			/* Store cohort read        */
	    {
						/* Warn of incomplete cohort*/
	      if ((read_no != (COHORT_SIZE+I_CONST_DIM)) && warnics)
		{
		  Warning(ICS);
		  warnics =0;
		}
	      mem_req = (CohortNo[i]+1)*COHORT_SIZE;
	      if (!(mem_req < DataMemAllocated[i]))
		{
		  DataMemAllocated[i] = MemBlocks(mem_req);
		  pop[i] =
		      (population)Myalloc((void *)pop[i],
					  (size_t)DataMemAllocated[i],
					  sizeof(double));
		  if(!(pop[i])) ErrorAbort(MAFC);
#ifdef MODULE
		  if (error_code & FATAL_ERROR) return;
#endif
		}
#if (I_CONST_DIM > 0)
	      mem_req = (CohortNo[i]+1)*I_CONST_DIM;
	      if (!(mem_req < IDMemAllocated[i]))
		{
		  IDMemAllocated[i] = MemBlocks(mem_req);
		  popIDcard[i] =
		      (popID)Myalloc((void *)popIDcard[i],
				     (size_t)IDMemAllocated[i],
				     sizeof(double));
		  if(!(popIDcard[i])) ErrorAbort(MAFI);
#ifdef MODULE
		  if (error_code & FATAL_ERROR) return;
#endif
		}
#endif
	      if (CohortNo[i])
		  CohortNo[i] = InsCohort(val_tmp,
#if (I_CONST_DIM > 0)
					  val_tmp+COHORT_SIZE,
#endif
					  i);
	      else
		{
		  for (j=0; j<COHORT_SIZE; j++)
		      pop[i][CohortNo[i]][j] = val_tmp[j]; 
#if (I_CONST_DIM > 0)
		  for (j=0; j<I_CONST_DIM; j++)
		      popIDcard[i][CohortNo[i]][j] = val_tmp[j+COHORT_SIZE]; 
#endif
		  CohortNo[i]++;
		}
	    }
	}
      if(ferror(infile) || (feof(infile) && !CohortNo[POPULATION_NR-1]))
	  Warning(EISF);			/* On read error exit	    */
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif
    }

  for(i=0; i<POPULATION_NR; i++)
    {
      (void)sprintf(input, "Initial population %d is empty! %s",
		    i, "Expecting initialization in UserInit()!");
      if(!CohortNo[i]) Warning(input);
      cohort_no[i] = CohortNo[i];
    }

  return;
}

#endif // (POPULATION_NR > 0)


/*==========================================================================*/

void	  Initialize(int argc, char **argv)

  /* 
   * Initialize - Routine initializes the global variables, reads the 
   *		  constants from the .cvf file and the initial state from
   *		  the .isf file and takes care of the output at start up.
   */

{
  char			filename[MAXFILENAMELEN], *ch;
  FILE			*isf, *cvf;

  InitVars();
  if (argc < 2) ErrorAbort(NEA);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif

  ch=strcpy(progname, argv[0]);			/* Store name of  program   */

  ch=strcpy(runname, argv[1]);			/* Store name of the run    */
  while((*ch!='\0')) ch++;
  *ch='.'; ch++; *ch='\0';
						/* Open CVF file with	    */
						/* lower case extension	    */
  ch=strcpy(filename, runname); ch=strcat(filename, "cvf");
  cvf=fopen(filename, "r");

  if(!cvf)					/* On error try upper casee */
    {
      ch=strcpy(filename, runname); ch=strcat(filename, "CVF");
      cvf=fopen(filename, "r");
      if(!cvf) ErrorAbort(CVF);			/* On repeated error exit   */
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif
    }
  ReadCvf(cvf); (void)fclose(cvf);
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif
						/* Open ISF file with	    */
						/* lower case extension	    */
  ch=strcpy(filename, runname);			/* or ESF file if resuming  */
  if (Resume) ch=strcat(filename, "esf");
  else ch=strcat(filename, "isf");
  isf=fopen(filename, "r");
  if(!isf)					/* On error try upper case  */
    {
      ch=strcpy(filename, runname);
      if (Resume) ch=strcat(filename, "ESF");
      else ch=strcat(filename, "ISF");
      isf=fopen(filename, "r");
    }
  if (Resume && !isf)				/* ESF not found: restart   */
    {
      Warning(FISF);
      ch=strcpy(filename, runname);
      ch=strcat(filename, "isf");
      isf=fopen(filename, "r");
      if(!isf)					/* On error try upper case  */
	{
	  ch=strcpy(filename, runname);
	  ch=strcat(filename, "ISF");
	  isf=fopen(filename, "r");
	}
    }
  if(isf)					/* Read initial state	    */
    {						/* of environment	    */
      if(ReadInputEnv(isf) != ENVIRON_DIM) Warning(WNEV);
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif

#if (POPULATION_NR > 0)
      ReadInputPop(isf);			/* Read initial state	    */
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif
#endif // (POPULATION_NR > 0)

      (void)fclose(isf);
    }
#ifndef MODULE					/* Expect initial state in  */
  else Warning(ISF);				/* UserInit()               */
#endif
						/* Open OUT file with	    */
						/* lower case extension	    */
  ch=strcpy(filename, runname); ch=strcat(filename, "out");
  resfil=fopen(filename, "a");
  if(!resfil)					/* On error try upper case  */
    {
      ch=strcpy(filename, runname); ch=strcat(filename, "OUT");
      resfil=fopen(filename, "a");
      if(!resfil) ErrorAbort(OUT);		/* On repeated error exit   */
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif
    }

  if (debug_level)				/* Open DBG file with	  */
    {						/* lower case extension	  */
      (void)strcpy(filename, runname); (void)strcat(filename, "dbg");
      dbgfil=fopen(filename, "a");
      if(!dbgfil)				/* On error try upper case  */
	{
	  (void)strcpy(filename, runname); (void)strcat(filename, "DBG");
	  dbgfil=fopen(filename, "a");
	  if(!dbgfil) Warning(DBG);		/* On repeated error warn   */
	}
    }
  else dbgfil = NULL;

  csbnew = 0;
#if (POPULATION_NR > 0)
  struct stat           st;

  if (!csbfil)
    {						/* Open CSB file	    */
      (void)strcpy(filename, runname); (void)strcat(filename, "csb");
      if ((stat(filename, &st) != 0) || (st.st_size == 0))
	{
	  csbfil=fopen(filename, "wb");		// New CSB file
	  if (csbfil) csbnew = 1;
	}
      else csbfil=fopen(filename, "ab");
      if(!csbfil)				/* On error try upper case  */
	{
	  (void)strcpy(filename, runname); (void)strcat(filename, "CSB");
	  if ((stat(filename, &st) != 0) || (st.st_size == 0))
	    {
	      csbfil=fopen(filename, "wb");	// New CSB file
	      if (csbfil) csbnew = 1;
	    }
	  else csbfil=fopen(filename, "ab");
	}
      if(csbfil) return;
    }
#endif // (POPULATION_NR > 0)
  csbfil=NULL;

  return;
}



/*==========================================================================*/
