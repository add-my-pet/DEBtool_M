/***
   NAME
     methtest
   DESCRIPTION
     This file is only processed by the preprocessor to issue a statement which 
     time integration method is being used. Not compiled into the code.
   NOTES
     
   HISTORY
     AMdR - Nov 08, 1998 : Created.
     AMdR - Nov 15, 2014 : Revised last.
***/
#ifndef METHTEST
#define METHTEST
#endif

#include "escbox.h"

#ifndef TIME_METHOD
#define TIME_METHOD	RKCK
#endif /* TIME_METHOD */
#if    (TIME_METHOD ==  RK2)
#error ==> Using RK2 method for time integration of ODEs....
#elif  (TIME_METHOD ==  RK4)
#error ==> Using RK4 method for time integration of ODEs....
#elif  (TIME_METHOD  == RKF45)
#error ==> Using RKF45 method for time integration of ODEs....
#elif  (TIME_METHOD ==  RKCK)
#error ==> Using RKCK method for time integration of ODEs....
#elif  (TIME_METHOD ==  DOPRI5)
#error ==> Using DOPRI5 method for time integration of ODEs....
#elif  (TIME_METHOD ==  DOPRI8)
#error ==> Using DOPRI8 method for time integration of ODEs....
#elif  (TIME_METHOD ==  RADAU5)
#error ==> Using RADAU5 method for time integration of ODEs....
#elif  (TIME_METHOD ==  CVODE)
#error ==> Using CVODE (ADAMS) method for time integration of ODEs....
#elif  (TIME_METHOD ==  CVBDF)
#error ==> Using CVODE (BDF) method for time integration of ODEs....
#else
#error ==> Internal EBT error: TIME_METHOD not specified!
#endif



/*==========================================================================*/
