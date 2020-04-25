/***
  NAME
    escbox.h
  PURPOSE
    This file contains all include statements for the program, some
    constant and type definitions that are used in the population data
    representations and the prototypes of various functions.
    This file is meant to be included in all escalator boxcar train
    modules, as it contains the global definitions that are accessible to
    all modules. 
  NOTES
     
  HISTORY
    AMdR - Jul 19, 1995 : Created.
    AMdR - May 23, 2019 : Revised last.
***/

#ifndef ESCBOX_H
#define ESCBOX_H

#if defined(MODULE)
#include "ebttooldefs.h"
#endif

#define RK2                       98110801                                          // Key values to indicate the different integration methods
#define RK4                       98110802
#define RKF45                     98110803
#define RKCK                      98110804
#define DOPRI5                    98110805
#define DOPRI8                    98110806
#define RADAU5                    98110807
#define CVODE                     98110808
#define CVBDF                     98110809

#define MAXDERS                   20                                                // Max. stages in ODE solver

#if defined(PROBLEMFILE)                                                            // If program header file is defined, include it. 
#include PROBLEMFILE
#else
#error You failed to specify the PROBLEMFILE constant. Use the "ebt" script!
#endif

#ifndef TIME_METHOD
#define TIME_METHOD               RKCK
#endif

#ifndef DYNAMIC_COHORTS
#define DYNAMIC_COHORTS           0
#endif
#if (DYNAMIC_COHORTS > 0)
#define DYNAMIC_COHORTS    1
#if ((TIME_METHOD != DOPRI5) && (TIME_METHOD != DOPRI8) && \
     (TIME_METHOD != RADAU5) && (TIME_METHOD != CVODE ) && (TIME_METHOD != CVBDF))
#undef  TIME_METHOD
#define TIME_METHOD               DOPRI5
#endif
#else
#define DYNAMIC_COHORTS           0
#endif

#ifndef EVENT_NR
#define EVENT_NR                  0
#endif
#if (EVENT_NR > 0)
#if ((TIME_METHOD != DOPRI5) && (TIME_METHOD != DOPRI8) && \
     (TIME_METHOD != RADAU5) && (TIME_METHOD != CVODE ) && (TIME_METHOD != CVBDF))
#undef  TIME_METHOD
#define TIME_METHOD               DOPRI5
#endif
#else
#define EVENT_NR                  0
#endif

#ifndef BIFURCATION
#define BIFURCATION               0
#ifndef MEASUREBIFSTATS
#define MEASUREBIFSTATS           0
#endif
#elif (BIFURCATION == 1)
#ifndef MEASUREBIFSTATS
#define MEASUREBIFSTATS           1
#endif
#endif

#ifndef CHECK_EXTINCTION
#define CHECK_EXTINCTION          2                                                 // 0: Ignore all tests; 1: Ignore run ending; 2: Test and end run
#endif

#include "ebttune.h"
#include "ctype.h"
#include "math.h"
#include "stdio.h"
#include "string.h"

#if HAS_FLOAT_H
#include "float.h"
#endif

#if HAS_SIGNALS
#include "signal.h"
#endif

#if defined(_GNU_SOURCE)
#include "fenv.h"
#endif

#include "limits.h"
#include "stddef.h"
#include "stdlib.h"
#include "stdarg.h"
#include "sys/stat.h"


/*==================================================================================================================================*/
/*
 * Definition of some global constants. Most of these definitions only take
 * effect if the flag EBTLIB is defined, which occurs in the
 * Escalator Boxcar Train module files.
 */

#if (POPULATION_NR > 0)                                                             // The number of replicate  
#define COHORT_SIZE               (1+I_STATE_DIM)                                   // size of cohort           
#else
#define I_CONST_DIM               0
#define I_STATE_DIM               0
#define COHORT_SIZE               0
#endif

#if defined(DBL_MAX)                                                                // Stub value for missing data point
#define MISSING_VALUE             (DBL_MAX)
#elif defined(MAXDOUBLE)
#define MISSING_VALUE             (MAXDOUBLE)
#else
#define MISSING_VALUE             (1.23456789e+307)
#endif

#define   BIFTINY                 1.0E-4                                            // Tiny value used in bifurcation computations 
#ifdef EBTLIB
#if defined(PATH_MAX)                                                               // Maximum length of the full path to a file      
#define MAXFILENAMELEN            (PATH_MAX)
#elif defined(MAXPATHLEN)
#define MAXFILENAMELEN            (MAXPATHLEN)
#elif defined(_MAX_PATH)
#define MAXFILENAMELEN            (_MAX_PATH)
#else
#define MAXFILENAMELEN            (512)
#endif

#define DESCRIP_MAX               80                                                // The maximum length of a quantity description   

#define REPORTNOTE_MAX            4096                                              // The maximum length of a ReportNote             

#define MEM_BLOCK_SIZE            256                                               // Number of doubles in allocated memory block   
#define SMALLEST_STEP             1.0E-12                                           // The minimum step size allowed in integration   
#define DEFAULT_STEP              0.1                                               // Default step size in integration              
#ifndef LARGEST_STEP
#define LARGEST_STEP              1.0                                               // The maximum step size allowed in integration
#endif
#define MIN_ACCURACY              1.0E-16                                           // The minimum accuracy allowed in integration   
#endif // EBTLIB 

#define NOSWITCH                  -1                                                // Stub values for problem without events
#define NO_EVENT                  -1
#define NO_COHORT_END             0
#define COHORT_END                1


#ifndef I_CONST_DIM
#define I_CONST_DIM               0
#endif


/*==================================================================================================================================*/
/*
 * Definition of the cohort structure that will hold the data of one 
 * population cohort. Also defined is a pointer type to a single cohort and
 * the population data type.
 */

typedef double                    cohort[COHORT_SIZE];
typedef cohort                    *cohort_pnt;
typedef cohort_pnt                population;
#if (I_CONST_DIM > 0)
typedef double                    cohortID[I_CONST_DIM];
typedef cohortID                  *cohortID_pnt;
typedef cohortID_pnt              popID;
#endif
typedef int                       cohort_ind[COHORT_SIZE];
typedef cohort_ind                *cohort_ind_pnt;
typedef cohort_ind_pnt            population_index;


/*==================================================================================================================================*/
/* 
 * Defining macro's for global use in all files
 */

#define number                    (0)
#define i_state(a)                ((a+1))
#define i_const(a)                ((a))

#define DEF_TYPE                  void                                              // Basic pointer type       
#define CONST                     const
#define SIZE_TYPE                 size_t

#define MemBlocks(a)              (((a/MEM_BLOCK_SIZE)+1)*MEM_BLOCK_SIZE)
#define EBTDEBUG(a)               (dbgfil && (debug_level >= (a)))


/*==================================================================================================================================*/
/*
 * Definition of global variables and functions accessible in user
 * specified problem file.
 */

#ifndef EBTLIB
#define CycleStart                SetBpointNo
#define CycleEnd                  InstantDynamics

extern double                     cohort_limit;
extern double                     next_output, next_state_output;
#if (POPULATION_NR > 0)
extern int                        cohort_no[POPULATION_NR];
extern int                        bpoint_no[POPULATION_NR];
#endif // (POPULATION_NR > 0)
extern int                        rk_level;
extern int                        ForcedCohortEnd;
extern int                        ForcedRunEnd;
extern int                        LocatedEvent;
extern int                        parameter_nr;
#if PARAMETER_NR
extern double                     parameter[PARAMETER_NR];
#endif
#if (BIFURCATION == 1)
extern int                        BifParIndex;
extern double                     BifOutput;
extern double                     BifStateOutput;
extern double                     BifPeriod;
#endif // (BIFURCATION == 1)
#if ((POPULATION_NR > 0) && (I_CONST_DIM > 0))
extern popID                      popIDcard[POPULATION_NR];
extern popID                      ofsIDcard[POPULATION_NR];
#endif
extern int                        AddCohorts(population *, int, int);

extern int                        imax(int, int);
extern int                        imin(int, int);
extern double                     max(double, double);
extern double                     min(double, double);

#ifdef iszero
#undef iszero
#endif
extern int                        iszero(double);
extern int                        ismissing(double);
extern int                        isequal(double, double);
extern void                       SetStepSize(double);
extern void                       SievePop(void);
extern void                       ErrorAbort(const char *);
extern void                       ErrorExit(const int, const char *);
extern void                       Warning(const char *);
extern void                       ReportNote(const char *, ...);
extern void                       LabelState(int, const char *, ...);
extern void                       measureBifstats(double *env, population *pop);
#endif // EBTLIB 




/*==================================================================================================================================*/
/*
 * Prototyping all functions that are defined in the problem-specific
 * program file
 */

#ifdef  EBTLIB
#undef  EXTERN
#define EXTERN                    extern
#else
#undef  EXTERN
#define EXTERN
#endif
EXTERN void                       UserInit(int, char **, double *, population *);
EXTERN void                       SetBpointNo(double *, population *, int *);
EXTERN void                       SetBpoints(double *, population *, population *);
EXTERN void                       Gradient(double *, population *, population *, double *, population *, population *, population *);
EXTERN void                       EventLocation(double *, population *, population *, population *, double *);
EXTERN int                        ForceCohortEnd(double *, population *, population *, population *);
EXTERN void                       InstantDynamics(double *, population *, population *);
EXTERN void                       DefineOutput(double *, population *, double *);


/*==================================================================================================================================*/
#endif // ESCBOX_H 
