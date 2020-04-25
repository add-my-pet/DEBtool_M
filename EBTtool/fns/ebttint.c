/***
   NAME
     ebttint.c
   PURPOSE
     This file contains the specification of the actual time integration
     routine for the Escalator Boxcar Train program.  It includes the
     appropriate source file, dependent on the defined variable
     TIME_METHOD. The source file implements the actual method and supplies to
     routines: PrepareCycle() and IntegrationStep(). These are called by
     NewCohort() to integrate all the variables during the time interval
     between cohort closures. Cohort cycles end at regularly spaced points in
     time or when forced by the ForceCohortEnd() routine (DOPRI5, DOPRI8 and
     RADAU5 methods only).
   NOTES
     
   HISTORY
     AMdR - Nov 08, 1998 : Created.
     AMdR - Jan 08, 2014 : Revised last.
***/

#define EBTTINT_C				/* Identification of file   */
#define EBTLIB					/* and file grouping	    */

#include "escbox.h"				/* Include general header   */
#include "ebtmain.h"
#include "ebtcohrt.h"
#include "ebtutils.h"

/* Bas Kooijman 2020/04/02 */
#include "ebttint.h"

/*==========================================================================*/
/*
 * Including the file with the selected time integration method
 */

#ifndef TIME_METHOD
#define TIME_METHOD	RKCK
#endif /* TIME_METHOD */
#if    (TIME_METHOD ==  RK2)
#include "ebtrk2.c"
#elif  (TIME_METHOD ==  RK4)
#include "ebtrk4.c"
#elif  (TIME_METHOD ==  RKF45)
#include "ebtrkf45.c"
#elif  (TIME_METHOD ==  RKCK)
#include "ebtrkck.c"
#elif  (TIME_METHOD ==  DOPRI5)
#include "ebtdopri5.c"
#elif  (TIME_METHOD ==  DOPRI8)
#include "ebtdopri8.c"
#elif  (TIME_METHOD ==  RADAU5)
#include "ebtradau.c"
#elif  (TIME_METHOD ==  CVODE)
#include "ebtcvode.c"
#elif  (TIME_METHOD ==  CVBDF)
#include "ebtcvode.c"
#else
#error Internal EBT error: TIME_METHOD not specified!
#endif



/*==============================================================================*/
