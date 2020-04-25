/***
   NAME
     ebttint.h
   PURPOSE
     Interface header file to the functions defined in ebttint.c
   NOTES
     
   HISTORY
     AMdR - Nov 08, 1998 : Created.
     AMdR - Nov 15, 2015 : Revised last.
***/

#ifndef EBTTINT_H
#define EBTTINT_H

#ifdef	EBTTINT_C
#undef	EXTERN
#define EXTERN
#else
#undef	EXTERN
#define EXTERN	extern
#endif

EXTERN void	PrepareCycle(void);
EXTERN double	IntegrationStep(double, double, int);


/*===========================================================================*/
#endif /* EBTTINT_H */
