/***
   NAME
     ebtinit.h
   PURPOSE
     Interface header file to the functions defined in ebtinit.c
   NOTES
     
   HISTORY
     AMdR - Jul 19, 1995 : Created.
     AMdR - Nov 15, 2015 : Revised last.
***/

/*==========================================================================*/
#ifndef EBTINIT_H
#define EBTINIT_H

#ifdef	EBTINIT_C
#undef	EXTERN
#define EXTERN
#else
#undef	EXTERN
#define EXTERN	extern
#endif
EXTERN void	Initialize(int, char **);



/*===========================================================================*/
#endif /* EBTINIT_H */
