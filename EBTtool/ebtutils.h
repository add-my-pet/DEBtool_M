/***
  NAME
    ebtutils.h
  PURPOSE
    Interface header file to the functions defined in ebtutils.c
  NOTES
     
  HISTORY
    AMdR - Jul 19, 1995 : Created.
    AMdR - May 23, 2019 : Revised last.
***/

/*==================================================================================================================================*/
#ifndef EBTUTILS_H
#define EBTUTILS_H

#ifdef  EBTUTILS_C
#undef  EXTERN
#define EXTERN
#else
#undef  EXTERN
#define EXTERN                    extern
#endif
#ifdef iszero
#undef iszero
#endif

EXTERN int                        imin(int, int);
EXTERN int                        imax(int, int);
EXTERN double                     min(double, double);
EXTERN double                     max(double, double);
EXTERN int                        iszero(double);
EXTERN int                        ismissing(double);
EXTERN int                        isequal(double, double);
EXTERN void                       SetStepSize(double);
EXTERN void                       ErrorAbort(const char *);
EXTERN void                       ErrorExit(const int, const char *);
EXTERN void                       Warning(const char *);
EXTERN void                       FileOut(void);
EXTERN void                       FileState(void);
EXTERN void                       *Myalloc(void *, size_t, size_t);
EXTERN void                       PrettyPrint(FILE *fp, double output);
EXTERN void                       WriteStateToFile(FILE *fp, double *data);
EXTERN void                       kill_shmem(void);
EXTERN int                        init_shmem(void);
EXTERN void                       ReportNote(const char *, ...);
#if (BIFURCATION == 1)
EXTERN void                       SetBifOutputTimes(double *);
#if (MEASUREBIFSTATS == 1)
EXTERN void                       outputMeasureBifstats(double *env, population *pop);
EXTERN void                       measureBifstats(double *env, population *pop);
#endif
#endif // (BIFURCATION == 1)


/*==================================================================================================================================*/
#endif // EBTUTILS_H
