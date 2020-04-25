/***
   NAME
     ebttooldefs.h
   PURPOSE
     This file contains some constant declarations that are used when the escalator
     boxcar train is used from within the ebttool; it should be included in ebtcohrt.c
     and in the ebttool program file
     
   NOTES
     
   HISTORY
     AvdM - Nov 22, 2004 : Created.
***/

#ifndef EBTTOOLDEFS_H
#define EBTTOOLDEFS_H

//#if defined(_GNU_SOURCE)
//#include  "fenv.h"
//#endif

const int END_OF_COHORT = 0x01;		// 1
const int NORMAL_OUT = 0x02;		// 2
const int STATE_OUT = 0x04;		// 4
const int WARNING = 0x08;		// 8
const int NON_FATAL_ERROR = 0x10;	// 16
const int FATAL_ERROR = 0x20;		// 32
const int LIB_NOT_LOADED = 0x40;        // 64
const int FPE_ERROR = 0x80;		// 128

#endif // EBTTOOLDEFS_H 
