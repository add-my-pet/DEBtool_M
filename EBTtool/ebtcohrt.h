/***
   NAME
     ebtcohrt.h
   PURPOSE
     Interface header file to the functions defined in ebtcohrt.c
   NOTES
     
   HISTORY
     AMdR - Jul 19, 1995 : Created.
     AMdR - Nov 15, 2015 : Revised last.
***/

/*==========================================================================*/
#ifndef EBTCOHRT_H
#define EBTCOHRT_H

#ifdef	EBTCOHRT_C
#undef	EXTERN
#define EXTERN
#else
#undef	EXTERN
#define EXTERN	extern
#endif
EXTERN   void     	CohortCycle(double);
#if (I_CONST_DIM > 0)
EXTERN int		InsCohort(cohort, cohortID, int);
#else
EXTERN   int		InsCohort(cohort, int);
#endif
EXTERN_C void		TransBcohorts(void);
EXTERN   void		SievePop(void);



/*==========================================================================*/
#endif /* EBTCOHRT_H */
