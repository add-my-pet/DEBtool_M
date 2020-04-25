/***
  NAME
    ebtcohrt.c
  PURPOSE
    This file contains NewCohort() routine and all the functions used by
    it to keep the set of population cohorts organized and to deal with
    their increasing and decreasing number. 
  NOTES
    
  HISTORY
    AMdR - Jul 21, 1995 : Created.
    AMdR - Mar 08, 2018 : Revised last.
***/

#define EBTCOHRT_C                                                                  // Identification of file   
#define EBTLIB                                                                      // and file grouping   

#include "escbox.h"                                                                 // Include general header   
#include "ebtmain.h"
#include "ebtcohrt.h"
#include "ebttint.h"
#include "ebtutils.h"

/* Bas Kooijman 2020/04/02 */
#include "ebttint.h"



/*==================================================================================================================================*/
/*
 * The error messages that occur in the routines in the present file.
 */

#define AEXT                      "All populations are extinct!"
#define MAFB                      "Memory allocation failure for boundary points!"
#define MAFC                      "Memory allocation failure for i-state variables!"
#define MAFI                      "Memory allocation failure for cohort constants!"
#define MAFT                      "Memory allocation failure while inserting boundary cohorts!"


/*==================================================================================================================================*/
/*
 * Definitions of static variables, restricted to this file.
 */

#if (POPULATION_NR > 0)
static population                 BPData = NULL;                                    // Pointer to bpoints data  
static long                       BPAllocated = 0L;                                 // # of doubles allocated   
#endif // (POPULATION_NR > 0)
static double                     maxss, minss;


/*==================================================================================================================================*/
/*
 * Start of function implementations.
 */
/*==================================================================================================================================*/
#if (POPULATION_NR > 0)

int   InsCohort(cohort newcoh,
#if (I_CONST_DIM > 0)
                cohortID id,
#endif
                int pop_nr)

  /* 
   * InsCohort -  Routine inserts a new cohort on its appropriate, ordered 
   *              position in the population with number "pop_nr". The 
   *              pointer "new" points to an array of i-state variables of
   *              length COHORT_SIZE, the pointer "id" points to an array
   *              of i-state constants of length I_CONST_DIM.
   */

{
  register int                    found, equal;
  register int                    i, pos;
  cohort_pnt                      p;
#if (I_CONST_DIM > 0)
  cohortID_pnt pid;
#endif
  // Top-down search for appropriate cohort place
  p = pop[pop_nr];
  for (pos = CohortNo[pop_nr] - 1, found = 0; pos >= 0; pos--)
    {
      for (i = 1, equal = 1; (i < COHORT_SIZE) && equal; i++)
        {
          equal = (p[pos][i] == newcoh[i]);
          found = (p[pos][i] > newcoh[i]);
        }
      if (found) break;
    }

  pos++;                                                                             // Shift all entries lying above position upwards
  p = pop[pop_nr] + pos;
  if (pos < CohortNo[pop_nr]) (void)memmove(*(p + 1), *p, (CohortNo[pop_nr] - pos)*COHORT_SIZE*sizeof(double));
  // Place new cohort
  (void)memcpy((DEF_TYPE *)*p, (DEF_TYPE *)newcoh, COHORT_SIZE*sizeof(double));
#if (I_CONST_DIM > 0)
  pid = popIDcard[pop_nr] + pos;
  if (pos < CohortNo[pop_nr]) (void)memmove(*(pid + 1), *pid, (CohortNo[pop_nr] - pos)*I_CONST_DIM*sizeof(double));

  // Place new cohort id
  (void)memcpy((DEF_TYPE *)*pid, (DEF_TYPE *)id, I_CONST_DIM*sizeof(double));
#endif

  return (++CohortNo[pop_nr]);
}


/*==================================================================================================================================*/

static void CreateBcohorts()

  /* 
   * CreateBcohorts - Routine sets up the boundary cohorts and the fixed boundary points.
   */

{
  register int                    i, base;
  long                            mem_req, bp_req;

  for (i = 0; i < POPULATION_NR; i++)
    {
      if (BpointNo[i])
        {
          mem_req = (CohortNo[i] + BpointNo[i])*COHORT_SIZE;
          if (!(mem_req < DataMemAllocated[i]))                                      // Create memory for new cohorts if necessary
            {
              DataMemAllocated[i] = MemBlocks(mem_req);
              pop[i]              = (population)Myalloc((void *)pop[i], (size_t)DataMemAllocated[i], sizeof(double));
              if (!(pop[i])) ErrorAbort(MAFC);
            }
#ifdef MODULE
          if (error_code & FATAL_ERROR) return;
#endif // MODULE

          ofs[i] = pop[i] + CohortNo[i];                                             // set up pointer to offspring cohort
          (void)memset((DEF_TYPE *)(ofs[i][0]), 0, BpointNo[i]*COHORT_SIZE*sizeof(double));
#if (I_CONST_DIM > 0)
          mem_req = (CohortNo[i] + BpointNo[i])*I_CONST_DIM;
          if (!(mem_req < IDMemAllocated[i]))
            {
              IDMemAllocated[i] = MemBlocks(mem_req);
              popIDcard[i]      = (popID)Myalloc((void *)popIDcard[i], (size_t)IDMemAllocated[i], sizeof(double));
              if (!(popIDcard[i])) ErrorAbort(MAFI);
            }
#ifdef MODULE
          if (error_code & FATAL_ERROR) return;
#endif // MODULE

          ofsIDcard[i] = popIDcard[i] + CohortNo[i];
          (void)memset((DEF_TYPE *)(ofsIDcard[i][0]), 0, BpointNo[i]*I_CONST_DIM*sizeof(double));
#endif
        }
      else
        {
          ofs[i] = NULL;
#if (I_CONST_DIM > 0)
          ofsIDcard[i] = NULL;
#endif
        }
    }

  for (i = 0, bp_req = 0; i < POPULATION_NR; i++) bp_req += BpointNo[i];
  bp_req *= COHORT_SIZE;

  if ((bp_req > 0) && !(bp_req < BPAllocated))
    {
      BPAllocated = MemBlocks(bp_req);
      BPData      = (population)Myalloc((void *)BPData, (size_t)BPAllocated, sizeof(double));
      if (!(BPData)) ErrorAbort(MAFB);
    }
#ifdef MODULE
  if (error_code & FATAL_ERROR) return;
#endif // MODULE

  for (i = 0, base = 0; i < POPULATION_NR; i++)
    {
      if (BpointNo[i] > 0)
        bpoints[i] = BPData + base;
      else
        bpoints[i] = NULL;
      bpoint_no[i] = BpointNo[i];
      base += BpointNo[i];
    }

  if (BPData && BPAllocated) (void)memset((DEF_TYPE *)(BPData), 0, BPAllocated*sizeof(double));

  return;
}


/*==================================================================================================================================*/

EXTERN_C void TransBcohorts()

  /* 
   * TransBcohorts - Routine transforms the boundary cohorts into internal cohorts and clears the current boundary points.
   */


{
  register int        i;
  register int        j, k;
  register cohort_pnt p, bp;

  for (i = 0; i < POPULATION_NR; i++)
    {
      if (!bpoints[i]) continue;
      p  = ofs[i];
      bp = bpoints[i];
      for (j = 0; j < BpointNo[i]; j++)
        {
          if (p[j][number] > 0)                                                     // If new cohorts are not empty, transform i-state
            {
              for (k = 1; k < COHORT_SIZE; k++) p[j][k] = bp[j][k] + p[j][k]/p[j][number];
            }
          else                                                                      // Reset cohort to empty
            (void)memset((DEF_TYPE *)p[j], 0, COHORT_SIZE*sizeof(double));
        }
      bpoints[i] = NULL;                                                            // Set the pointers back to NULL pointers
    }

  return;
}


/*==================================================================================================================================*/

static void InsertBcohorts()

  /* 
   * InsertBcohorts - Routine inserts the boundary cohorts into the populations, ignoring empty ones.
   */

{
  register int                    i;
  register int                    j;
  static cohort_pnt               p = NULL;
#if (I_CONST_DIM > 0)
  static cohortID_pnt             pid = NULL;
#endif
  static int                      max_bcohorts = -1;
  int                             cbc;

  for (i = 0, cbc = 0; i < POPULATION_NR; i++) cbc = imax(cbc, BpointNo[i]);
  if (!cbc) return;

  if (cbc > max_bcohorts)
    {
      max_bcohorts = cbc;
      p            = (cohort_pnt)Myalloc((void *)p, (size_t)(max_bcohorts*COHORT_SIZE), sizeof(double));
      if (!p) ErrorAbort(MAFT);
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif // MODULE

#if (I_CONST_DIM > 0)
      pid = (cohortID_pnt)Myalloc((void *)pid, (size_t)(max_bcohorts*I_CONST_DIM), sizeof(double));
      if (!pid) ErrorAbort(MAFT);
#ifdef MODULE
      if (error_code & FATAL_ERROR) return;
#endif // MODULE
#endif
    }

  for (i = 0; i < POPULATION_NR; i++)
    {
      (void)memcpy((DEF_TYPE *)p, (DEF_TYPE *)(ofs[i]), BpointNo[i]*COHORT_SIZE*sizeof(double));
      (void)memset((DEF_TYPE *)(ofs[i]), 0, BpointNo[i]*COHORT_SIZE*sizeof(double));
#if (I_CONST_DIM > 0)
      (void)memcpy((DEF_TYPE *)pid, (DEF_TYPE *)(ofsIDcard[i]), BpointNo[i]*I_CONST_DIM*sizeof(double));
      (void)memset((DEF_TYPE *)(ofsIDcard[i]), 0, BpointNo[i]*I_CONST_DIM*sizeof(double));
#endif
      for (j = 0; j < BpointNo[i]; j++)                                             // If new cohorts are not empty, insert in population
        {
          if (p[j][number] > abs_tols[i][0])
            CohortNo[i] = InsCohort(p[j],
#if (I_CONST_DIM > 0)
                                    pid[j],
#endif
                                    i);
        }
      ofs[i]      = NULL;                                                           // Set the pointers back to NULL pointers
      BpointNo[i] = 0; 
    }

  return;
}


/*==================================================================================================================================*/

void SievePop()

  /* 
   * SievePop - Routine that scans all the cohorts, removing the ones that are below the minimum size and conjugating cohorts that 
   *            have become too similar.
   */

{
  register int                    i;
  register int                    j, k, ind1, ind2;
  register cohort_pnt             p;
#if (I_CONST_DIM > 0)
  register cohortID_pnt           pid;
#endif
  double                          diff, comp;
  int                             equal;

  for (i = 0; i < POPULATION_NR; i++)
    {                                                                               // Join similar cohorts
      if (!(tol_zero[i]))                                                           // If all tolerances zero skip this part
        {
          p = pop[i];
#if (I_CONST_DIM > 0)
          pid = popIDcard[i];
#endif
          for (j = 1, ind1 = 0; j < CohortNo[i]; j++)
            {
              // Skip cohorts that are too small as base cohort
              if (p[ind1][0] < abs_tols[i][0])
                {
                  ind1 = j;
                  continue;
                }
              // Determine similarity
              for (k = 1, equal = 1; equal && (k < COHORT_SIZE); k++)
                {                                                                   // Use relative and absolute tolerances
                  diff  = fabs(p[ind1][k] - p[j][k]);
                  comp  = fabs(p[ind1][k] + p[j][k] + 1.0E-15);
                  equal = ((diff < abs_tols[i][k]) || (diff < rel_tols[i][k]*comp/2.0));
                }
              if (!equal)
                ind1 = j;                                                           // If unequal skip
              else                                                                  // If equal join, i-state and constants become
                {                                                                   // weigthed mean
                  for (k = 1; k < COHORT_SIZE; k++)
                    p[ind1][k] = ((p[ind1][k]*p[ind1][0] + p[j][k]*p[j][0])/(p[ind1][0] + p[j][0]));
#if (I_CONST_DIM > 0)
                  for (k = 0; k < I_CONST_DIM; k++) pid[ind1][k] = ((pid[ind1][k]*p[ind1][0] + pid[j][k]*p[j][0])/(p[ind1][0] + p[j][0]));
#endif
                  p[ind1][0] += p[j][0];
                  p[j][0] = -1.0E-15;
                }
            }
        }

      // Test the cohorts that are left upon size
      j = 0;
      p = pop[i];
#if (I_CONST_DIM > 0)
      pid = popIDcard[i];
#endif
      while ((j < CohortNo[i]) && (p[j][0] > abs_tols[i][0])) j++;
      ind1 = j;
      while (j < CohortNo[i])
        {
          while ((j < CohortNo[i]) && !(p[j][0] > abs_tols[i][0])) j++;
          ind2 = j;
          while ((j < CohortNo[i]) && (p[j][0] > abs_tols[i][0])) j++;
          if (j > ind2)
            {
              (void)memmove((DEF_TYPE *)p[ind1], (DEF_TYPE *)p[ind2], (j - ind2)*COHORT_SIZE*sizeof(double));
#if (I_CONST_DIM > 0)
              (void)memmove((DEF_TYPE *)pid[ind1], (DEF_TYPE *)pid[ind2], (j - ind2)*I_CONST_DIM*sizeof(double));
#endif
              ind1 += (j - ind2);
            }
        }
      CohortNo[i] = ind1;
    }

  for (i = 0; i < POPULATION_NR; i++) cohort_no[i] = CohortNo[i];

  return;
}


#endif // (POPULATION_NR > 0)

/*==================================================================================================================================*/

void CohortCycle(double next)

/* 
   * CohortCycle - Routine loops through one cycle of cohort creation and output
   *               generation. First new boundary cohorts are created, then
   *               integration of the continuous dynamics takes place, after
   *               which instantaneous dynamics can occur at the end of a cohort
   *               cycle. Finally the boundary cohorts are merged with  the
   *               existing population and output is produced if necessary.
   */

{
  register int i;

#if ((CHECK_EXTINCTION > 0) && (POPULATION_NR > 0))
  int  all_zero = 1;
  char pext[80];

  for (i = 0; i < POPULATION_NR; i++)                                               // If all populations are extinct exit
    {
      if ((!CohortNo[i]) && (!pop_extinct[i]))
        {
          sprintf(pext, "Population %d is extinct at time %.2f", i, env[0]);
          Warning(pext);
          pop_extinct[i] = 1;
        }
      else if (CohortNo[i])
        pop_extinct[i] = 0;
      all_zero *= pop_extinct[i];
    }
#if (CHECK_EXTINCTION > 1)
  if (all_zero) ErrorExit(0, AEXT);
#endif

  for (i = 0; i < POPULATION_NR; i++) cohort_no[i] = CohortNo[i];
#endif // ((CHECK_EXTINCTION > 0) && (POPULATION_NR > 0))

#if (BIFURCATION == 1)
  // Set the current bifurcation parameter value
  if (BifParLogStep)
    parameter[BifParIndex] = (BifParBase*pow(10.0, BifParStep*floor((env[0] + BIFTINY)/BifPeriod)));
  else
    parameter[BifParIndex] = (BifParBase + floor((env[0] + BIFTINY)/BifPeriod)*BifParStep);
#endif // (BIFURCATION == 1)

#if (POPULATION_NR > 0)
  // User specifies no. of birth points at the start of each cohort cycle
  SetBpointNo(env, pop, BpointNo);

  // Create boundary cohorts and bpoints
  CreateBcohorts();                                                                  

  SetBpoints(env, pop, bpoints);                                                    // User defines bpoints
#else
  SetBpointNo(env, NULL, NULL);
#endif // (POPULATION_NR > 0)

#if ((BIFURCATION == 1) && (MEASUREBIFSTATS == 1))
#if (POPULATION_NR > 0)
  measureBifstats(env, pop);
#else
  measureBifstats(env, NULL);
#endif
#endif

  if (step_size <= SMALLEST_STEP) step_size = cohort_limit;
  minss = maxss = step_size;

  // Do as many integration steps as possible with adaptable stepsize and end with an optional rest step
  PrepareCycle();
  ForcedCohortEnd = cohort_end = 0;

  while ((!((next - env[0]) < SMALLEST_STEP)) && (!cohort_end))
    {
      (void)IntegrationStep(step_size, (next - (env[0])), 0);

      initState    = NULL;
      currentState = NULL;
      for (i = 0; i < MAXDERS; i++) currentDers[i] = NULL;

      minss = min(minss, step_size);
      maxss = max(maxss, step_size);
    }
  ForcedCohortEnd = cohort_end;

  if (EBTDEBUG(2))
    {
      (void)fprintf(dbgfil, "Cohort end: T = %15.8f   min. dt: %12.7E  max. dt: %12.7E\n", env[0], minss, maxss);
      (void)fflush(dbgfil);
    }
#if (POPULATION_NR > 0)
  TransBcohorts();                                                                  // Transform boundary cohorts

  InstantDynamics(env, pop, ofs);                                                   // Instantaneous dynamics at the end of cycle

  for (i = 0; i < POPULATION_NR; i++)                                               // Create empty state labels
    strcpy(statelabels[i], "");                                                     // AvdM, moved here from FileState()

  InsertBcohorts();                                                                 // Insert boundary cohorts

  SievePop();                                                                       // Delete all cohorts that are too small
#else
  InstantDynamics(env, NULL, NULL);
#endif // (POPULATION_NR > 0)

#if (BIFURCATION == 1)
  SetBifOutputTimes(env);
#endif // (BIFURCATION == 1)

  outputDefined = 0;
  if (env[0] >= (next_output - identical_zero))
    {                                                                               // Increment next time
      next_output = (floor((env[0] + identical_zero)/delt_out))*delt_out;
      next_output += delt_out;                                                      // Produce output if required at this time
      FileOut();
      outputDefined = 1;
    }

#if ((BIFURCATION == 1) && (MEASUREBIFSTATS == 1))
  outputMeasureBifstats(env, pop);
#endif

#if (POPULATION_NR > 0)
  if (state_out > 0.0)
    {
      if (env[0] >= (next_state_output - identical_zero))
        {                                                                           // Increment next time
          next_state_output = (floor((env[0] + identical_zero)/state_out))*state_out;
          next_state_output += state_out;                                           // Output complete state if required at this time
          FileState();
        }
    }
#endif // (POPULATION_NR > 0)

#if (DYNAMIC_COHORTS == 1)
  next_cohort_end = max_time;
#else
  if (fabs(next_cohort_end - env[0]) < SMALLEST_STEP)
    next_cohort_end += cohort_limit;
  else if ((next_cohort_end - env[0]) < SMALLEST_STEP)
    next_cohort_end = env[0] + cohort_limit;
#endif // DYNAMIC_COHORTS

  return;
}


/*==================================================================================================================================*/

#if defined(MODULE)

EXTERN_C int CycleInit()

{
  register int    i;

#ifdef MODULE
  strcpy(error_msg, "");
#endif
  error_code    = 0;

  if ((env[0] >= max_time) || ForcedRunEnd) return 1;

#if ((CHECK_EXTINCTION > 0) && (POPULATION_NR > 0))
  int                             all_zero=1;
  char                            pext[80];

  for (i=0; i<POPULATION_NR; i++)                                                   // If all populations are extinct exit
    {
      if ((!CohortNo[i]) && (!pop_extinct[i]))
        {
          sprintf(pext, "Population %d is extinct at time %.2f", i, env[0]);
          Warning(pext);
          pop_extinct[i]=1;
        }
      else if (CohortNo[i]) pop_extinct[i]=0;
      all_zero *= pop_extinct[i];
    }
#if (CHECK_EXTINCTION > 1)
  if (all_zero) return (1 | error_code);
#endif

  for (i=0; i<POPULATION_NR; i++) cohort_no[i] = CohortNo[i];
#endif // ((CHECK_EXTINCTION > 0) && (POPULATION_NR > 0))

#if (BIFURCATION == 1)
  // Set the current bifurcation parameter value
  if (BifParLogStep)
    parameter[BifParIndex] = (BifParBase*pow(10.0, BifParStep*floor((env[0]+BIFTINY)/BifPeriod)));
  else
    parameter[BifParIndex] = (BifParBase + floor((env[0]+BIFTINY)/BifPeriod)*BifParStep);
#endif // (BIFURCATION == 1)

#if (POPULATION_NR > 0)
  // User specifies no. of birth points at the start of each cohort cycle
  SetBpointNo(env, pop, BpointNo);

  CreateBcohorts();                                                                 // Create boundary cohorts and bpoints

  if (error_code & FATAL_ERROR) return error_code;

  SetBpoints(env, pop, bpoints);                                                    // User defines bpoints
#else
  SetBpointNo(env, NULL, NULL);
#endif // (POPULATION_NR > 0)

#if ((BIFURCATION == 1) && (MEASUREBIFSTATS == 1))
#if (POPULATION_NR > 0)
  measureBifstats(env, pop);
#else
  measureBifstats(env, NULL);
#endif
#endif

  if (step_size <= SMALLEST_STEP) step_size = cohort_limit;
  minss = maxss = step_size;

  // Do as many integration steps as possible with adaptable stepsize and end with an optional rest step
  PrepareCycle();
  ForcedCohortEnd = cohort_end   = 0;

  return error_code;
}



/*==================================================================================================================================*/

EXTERN_C int CycleStep()

{
  int                             i, ret_val;                                       //AvdM

#ifdef MODULE
  strcpy(error_msg, "");
#endif
  error_code = 0;

  if ((env[0] >= max_time) || ForcedRunEnd) return END_OF_COHORT;

  /*
  if ((!((next_cohort_end-env[0]) < SMALLEST_STEP)) && (!cohort_end))
  {
  (void)IntegrationStep(step_size, (next_cohort_end-(env[0])), 0);
  minss = min(minss, step_size);
  maxss = max(maxss, step_size);
  return 0;
  }
  */                                                                                //AvdM

  while ((!((next_cohort_end - env[0]) < SMALLEST_STEP)) && (!cohort_end))
    {
      (void)IntegrationStep(step_size, (next_cohort_end - (env[0])), 0);
      minss = min(minss, step_size);
      maxss = max(maxss, step_size);
    }

  ForcedCohortEnd = cohort_end;

  ret_val = END_OF_COHORT;                                                          //AvdM

  if (EBTDEBUG(2))
    {
      (void)fprintf(dbgfil, "Cohort end: T = %15.8f   min. dt: %12.7E  max. dt: %12.7E\n", env[0], minss, maxss);
      (void)fflush(dbgfil);
    }
#if (POPULATION_NR > 0)
  TransBcohorts();                                                                  // Transform boundary cohorts

  InstantDynamics(env, pop, ofs);                                                   // Instantaneous dynamics at the end of cycle

  for (i = 0; i < POPULATION_NR; i++)                                               // Create empty state labels
    strcpy(statelabels[i], "");                                                     // AvdM, moved here from FileState()

  InsertBcohorts();                                                                 // Insert boundary cohorts

  if (error_code & FATAL_ERROR) return (ret_val | error_code);

  SievePop();                                                                       // Delete all cohorts that are too small
#else
  InstantDynamics(env, NULL, NULL);
#endif // (POPULATION_NR > 0)

#if (BIFURCATION == 1)
  SetBifOutputTimes(env);
#endif // (BIFURCATION == 1)

  outputDefined = 0;
  if (env[0] >= (next_output - identical_zero))
    {                                                                               // Increment next time
      next_output = (floor((env[0] + identical_zero)/delt_out))*delt_out;
      next_output += delt_out;                                                      // Produce output if required at this time
      FileOut();
      ret_val |= NORMAL_OUT;                                                        //AvdM
      outputDefined = 1;
    }

#if ((BIFURCATION == 1) && (MEASUREBIFSTATS == 1))
  outputMeasureBifstats(env, pop);
#endif

#if (POPULATION_NR > 0)
  if (state_out > 0.0)
    {
      if (env[0] >= (next_state_output - identical_zero))
        {                                                                           // Increment next time
          next_state_output = (floor((env[0] + identical_zero)/state_out))*state_out;
          next_state_output += state_out;                                           // Output complete state if required at this time
          FileState();
          ret_val |= STATE_OUT;                                                     //AvdM
        }
    }
#endif // (POPULATION_NR > 0)

#if (DYNAMIC_COHORTS == 1)
  next_cohort_end = max_time;
#else
  if (fabs(next_cohort_end - env[0]) < SMALLEST_STEP)
    next_cohort_end += cohort_limit;
  else if ((next_cohort_end - env[0]) < SMALLEST_STEP)
    next_cohort_end = env[0] + cohort_limit;
#endif // DYNAMIC_COHORTS

  ret_val |= error_code;

  return ret_val;                                                                   //AvdM
}

/*==================================================================================================================================*/

#endif // defined(MODULE)
