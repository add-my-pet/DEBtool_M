/***
   NAME
     ebttune
   PURPOSE
     Include file to tailor the EBT to the current system
   NOTES
     
   HISTORY
     AMdR - Feb 25, 1998 : Created.
     AMdR - Nov 15, 2015 : Last revision.

     Explicit support include for

				__linux__
				MS Windows (WIN64 || _WIN64 || __WIN64__ || WIN32 || _WIN32 || __WIN32__ || __NT__)

     See the sections for these systems at the bottom of the file. 
***/

#ifndef EBTTUNE_H
#define EBTTUNE_H

/*
 * _GNU_SOURCE determines whether to use the GNU extensions to the C language.
 *
 * Default: yes, if __GNUC__ is defined, otherwise no.
 *
 */
#ifndef _GNU_SOURCE
#if defined(__GNUC__)
#define _GNU_SOURCE
#endif
#endif


/*
 * HAS_FLOAT_H determines whether the include file "float.h" is present 
 * on this system. Usually present when using gcc.
 *
 * Default: yes, if using gcc, otherwise no.
 *
 */
#ifndef HAS_FLOAT_H
#if defined(__GNUC__)
#define HAS_FLOAT_H		1
#else
#define HAS_FLOAT_H		0
#endif
#endif

/*
 * HAS_SIGNALS determines whether signal handling is fully functional
 * on this system. Usually present when using an ANSI C compiler.
 *
 * Default: yes, if using an ANSI C compiler.
 *
 */
#ifndef HAS_SIGNALS
#define HAS_SIGNALS		1
#endif

/*
 * HAS_MALLINFO determines whether the mallinfo structure is available
 * on this system.
 *
 * Default: no, unless Linux is the operating system
 *
 */
#ifndef HAS_MALLINFO
#define HAS_MALLINFO	0
#endif
/*
 * To avoid name mangling of exported function when compiling with a C++ 
 * compiler:
 */
#if defined(__cplusplus)
#define EXTERN_C extern "C"
#else
#define EXTERN_C extern
#endif

/*
 * The following settings are valid for a Linux system using 
 * the gcc compiler.
 */
#if defined(__linux__)
#undef  HAS_FLOAT_H
#define HAS_FLOAT_H		1
#undef  HAS_SIGNALS
#define HAS_SIGNALS		1
typedef 			void (*sighandler)(int);     
#undef  HAS_MALLINFO
#define HAS_MALLINFO		1
/*
 * The following settings are supposed to be valid for MS Windows systems
 */
#elif defined(WIN64) || defined(_WIN64) || defined(__WIN64__) || defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
#undef  HAS_FLOAT_H
#define HAS_FLOAT_H		1
#undef  HAS_SIGNALS
#define HAS_SIGNALS		1
#define LIMITED_SIGNALS		1
#undef  EXPORTING
#define EXPORTING   __declspec(dllexport)
#undef EXTERN_C
#if defined(__cplusplus)
#define EXTERN_C extern "C" __declspec(dllexport)
#define NOMINMAX		1
#else
#define EXTERN_C extern __declspec(dllexport)
#endif

// When using MSVC disable the warning about the unsafe functions like sprinf(), sscanf(), etc.
#if defined(_MSC_VER)
#define _CRT_SECURE_NO_DEPRECATE
#define _SCL_SECURE_NO_DEPRECATE
#endif

#endif	/* different os's */

#endif /* EBTTUNE_H */
