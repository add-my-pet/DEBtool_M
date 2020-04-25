/***
   NAME
     ebtstop.h
   PURPOSE
     Interface header file to the functions defined in ebtstop.c
   NOTES
     
   HISTORY
     AMdR - Jul 19, 1995 : Created.
     AMdR - Nov 15, 2015 : Revised last.
***/

/*==========================================================================*/
#ifndef EBTSTOP_H
#define EBTSTOP_H

#ifdef	EBTSTOP_C
#undef	EXTERN
#define EXTERN
#else
#undef	EXTERN
#define EXTERN	extern
#endif
EXTERN   void	WriteReport(int, char **);

#ifndef MODULE
EXTERN_C void	ShutDown(int);
#else
EXTERN_C int	ShutDown(int);
#endif

/*==========================================================================*/
#endif /* EBTSTOP_H */
