/***
   NAME
     ebtcsbdefs.h
   PURPOSE
     Define some structs used both in ebtutils.c and in ebtcsbfile (in the ebttool)
   NOTES

   HISTORY
     AMdR - Oct 07, 2016 : Revised.
     AvdM - May 11, 2005 : Created.
***/

#ifndef EBTCSBDEFS_H
#define EBTCSBDEFS_H

#if defined(_MSC_VER) && (_MSC_VER <= 1600)
   typedef __int32 uint32_t;
#else
   #include <stdint.h>
#endif

typedef struct envdim {
                        double          timeval;
                        int             columns;
                        int             data_offset;
                        uint32_t        memory_used;
                       } Envdim;

typedef struct popdim {
                        double          timeval;
                        int             population;
                        int             cohorts;
                        int             columns;
                        int             data_offset;
                        int             lastpopdim;
                       } Popdim;



/*===========================================================================*/
#endif /* EBTCSBDEFS_H */
