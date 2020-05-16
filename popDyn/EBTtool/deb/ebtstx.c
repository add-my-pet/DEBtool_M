/***
  NAME
    EBTstx.c
    stx DEB model with reprod buffer handling: produce offspring as soon as buffer allows
***/

/*==========================================================================
 * INCLUDING THE HEADER FILE & splines for temp correction and food input
 *==========================================================================
 */

#include "escbox.h"
#include "spline_TC.c"
#include "spline_JX.c"

/*
 *==========================================================================
 * LABELLING ENVIRONMENT AND I-STATE VARIABLES
 *==========================================================================
 */

#define time env[0] /* d                              */
#define food env[1] /* -, scaled food density x = X/K */

#define age i_state(0)         /*  1/d   */
#define accel i_state(1)       /* 1/d^2  */
#define ageHaz i_state(2)      /*  1/d   */
#define length i_state(3)      /*   cm   */
#define resDens i_state(4)     /* J/cm^3 */
#define reprodBuf i_state(5)   /*   J    */
#define maturity i_state(6)    /*   J    */
#define weight i_state(7)      /*   g    */

/*
 *==========================================================================
 * DEFINING AND LABELLING CONSTANTS AND PARAMETERS
 *==========================================================================
 */

#define E_Hp   parameter[0]   /*    J       */
#define E_Hx   parameter[1]   /*    J       */
#define E_Hb   parameter[2]   /*    J       */
#define V_X    parameter[3]   /*    L       */
#define h_X    parameter[4]   /*   1/d      */
#define h_J    parameter[5]   /*   1/d      */
#define h_B0b  parameter[6]   /*   1/d      */
#define h_Bbx  parameter[7]   /*   1/d      */
#define h_Bxp  parameter[8]   /*   1/d      */
#define h_Bpi  parameter[9]   /*   1/d      */
#define h_a    parameter[10]  /*   1/d      */
#define s_G    parameter[11]  /*    -       */
#define thin   parameter[12]  /*    -       */
#define L_m    parameter[13]  /*   cm       */
#define E_m    parameter[14]  /*  J/cm^3    */
#define k_J    parameter[15]  /*   1/d      */
#define k_JX   parameter[16]  /*   1/d      */
#define v      parameter[17]  /*   cm/d     */
#define g      parameter[18]  /*    -       */
#define p_M    parameter[19]  /* J/d.cm^3   */
#define p_Am   parameter[20]  /* J/d.cm^2   */
#define J_X_Am parameter[21]  /* mol/d.cm^2 */
#define K      parameter[22]  /*   mol/L    */
#define kap    parameter[23]  /*     -      */
#define kap_G  parameter[24]  /*     -      */
#define ome    parameter[25]  /*     -      */
#define E_0    parameter[26]  /*     J      */
#define L_b    parameter[27]  /*    cm      */
#define a_b    parameter[28]  /*     d      */
#define aT_b   parameter[29]  /*     d      */
#define q_b    parameter[30]  /*    1/d^2   */
#define qT_b   parameter[31]  /*    1/d^2   */
#define h_Ab   parameter[32]  /*    1/d     */
#define hT_Ab  parameter[33]  /*    1/d     */

/*
 *==========================================================================
 * USER INITIALIZATION ROUTINE ALLOWS OPERATIONS ON INITIAL POPULATIONS
 *==========================================================================
 */

void UserInit( int argc, char **argv, double *env, population *pop)
{
  return;
}

/*
 *==========================================================================
 * SPECIFICATION OF THE NUMBER AND VALUES OF BOUNDARY POINTS
 *==========================================================================
 */

void SetBpointNo(double *env, population *pop, int *bpoint_no)
{
  bpoint_no[0] = 1; /* all individuals start with the same age */

  return;
}

/*==========================================================================*/

void SetBpoints(double *env, population *pop, population *bpoints)
{
  bpoints[0][0][age]       = 0.0;
  bpoints[0][0][accel]     = qT_b;
  bpoints[0][0][ageHaz]    = hT_Ab;
  bpoints[0][0][length]    = L_b;
  bpoints[0][0][resDens]   = E_m;
  bpoints[0][0][maturity]  = E_Hb;
  bpoints[0][0][reprodBuf] = 0.0;
  bpoints[0][0][weight]    = L_b * L_b * L_b * (1 + ome);

  return;
}

/*==========================================================================*/

void EventLocation(double *env, population *pop, population *ofs, population *bpoints, double *events)
{ 
  register int i;
  
  events[0] = 1.0; events[1] = 1.0; events[2] = 1.0;
  for (i=0; i<cohort_no[0]; i++)
  {
    events[0] = fabs(pop[0][i][age]-aT_b)<fabs(events[0]) ? pop[0][i][age] - aT_b : events[0];
    events[1] = fabs(pop[0][i][maturity]-E_Hx)<fabs(events[1]) ? pop[0][i][maturity] - E_Hx : events[1];
    events[2] = fabs(pop[0][i][maturity]-E_Hp)<fabs(events[2]) ? pop[0][i][maturity] - E_Hp : events[2];
  }
}

/*==========================================================================*/

 int ForceCohortEnd(double *env, population *pop, population *ofs, population *bpoints)
 { 
   return NO_COHORT_END;
 }

 /*==========================================================================
 * SPECIFICATION OF DERIVATIVES
 *==========================================================================
 */

void Gradient(double *env, population *pop, population *ofs, double *envgrad, population *popgrad, population *ofsgrad, population *bpoints)
{
  double sumL2, TC, kT_J, kT_JX, vT, pT_Am, p_A, p_J, p_C, p_R, h_thin, hT_D, hT_J, hT_a, JT_X_Am, r, f, e, hazard, L, L2, L3, kapG;
  register int i;

  /* temp correction */
  TC = spline_TC(time); 
  kT_J = k_J * TC; kT_JX = k_JX * TC; vT = v * TC; pT_Am = TC * p_Am; JT_X_Am = TC * J_X_Am; aT_b = a_b/ TC;
  hT_X = h_X * TC; hT_J = TC * h_J; hT_a = h_a * TC * TC; hT_Ab = h_Ab * TC; qT_b = q_b * TC * TC; 
  
  /* scaled functional response, food = scaled food density */
  f = food/ (food + 1);  

  /* The derivatives for the boundary cohort */
  ofsgrad[0][0][number]    = - h_B0b * ofs[0][0][number];        /*   */
  ofsgrad[0][0][age]       = 1.0;                                /* 0 */
  ofsgrad[0][0][accel]     = 0.0;                                /* 1 */
  ofsgrad[0][0][ageHaz]    = 0.0;                                /* 2 */
  ofsgrad[0][0][length]    = 0.0;                                /* 3 */
  ofsgrad[0][0][resDens]   = 0.0;                                /* 4 */
  ofsgrad[0][0][maturity]  = 0.0;                                /* 5 */
  ofsgrad[0][0][reprodBuf] = 0.0;                                /* 6 */
  ofsgrad[0][0][weight]    = 0.0;                                /* 7 */
          
  /* The derivatives for all internal cohorts */
  for(i=0; i<cohort_no[0]; i++) 
    { 
      /* help quantities */
      e = pop[0][i][resDens]/ E_m;                                /* -, scaled reserve density e = [E]/[E_m] */
      L = pop[0][i][length]; L2 = L * L; L3 = L * L2;             /* cm, struc length */
      kapG = e>=L/L_m ? 1. : kap_G;                               /* kap_G if shrinking, else 1 */
      r = vT * (e/ L - 1./ L_m)/ (e + kapG * g);                  /* 1/d, spec growth rate of structure */
      p_J = kT_J * pop[0][i][maturity];                           /* J/d, maturity maintenance */
      p_C = L3 * e * E_m * (vT/ L - r);                           /* J/d, reserve mobilisation rate */
      p_R = (1.-kap)*p_C>p_J ? (1. - kap) * p_C - p_J : 0;        /* J/d, flux to maturation or reprod */
      p_A = pT_Am * f * L2;                                       /* J/d, assimilation flux (overwritten for embryo's) */
      h_thin = thin==0. ? 0. : r * 2./3.;                         /* 1/d, thinning hazard */
      if  (pop[0][i][maturity]<E_Hx) hazard = pop[0][i][ageHaz] + h_Bbx + h_thin;
      else hazard = pop[0][i][maturity]<E_Hp ? pop[0][i][ageHaz] + h_Bxp + h_thin : pop[0][i][ageHaz] + h_Bpi + h_thin;
 
      popgrad[0][i][number]    = - hazard * pop[0][i][number];                                                                 /*   */
      popgrad[0][i][age]       = 1.0;                                                                                          /* 0 */
      popgrad[0][i][accel]     = (pop[0][i][accel] * s_G * L3/ L_m/ L_m/ L_m + hT_a) * e * (vT/ L - r) - r * pop[0][i][accel]; /* 1 */
      popgrad[0][i][ageHaz]    = pop[0][i][accel] - r * pop[0][i][ageHaz];                                                     /* 2 */
      popgrad[0][i][length]    = L * r/ 3.;                                                                                    /* 3 */
      popgrad[0][i][resDens]   = p_A/ L3 - vT * e * E_m/ L; /* J/d.cm^3, change in reserve density [E] */                      /* 4 */
      popgrad[0][i][maturity]  = pop[0][i][maturity] < E_Hp ? p_R : 0.;                                                        /* 5 */
      popgrad[0][i][reprodBuf] = pop[0][i][maturity] >= E_Hp ? p_R : 0.;                                                       /* 6 */
      popgrad[0][i][weight]    = 3. * L2 * popgrad[0][i][length] * (1. + ome * e) + L3 * ome * popgrad[0][i][resDens]/ E_m;    /* 7 */
      
      /* overwrite changes for embryo's since i-states other than age are already set at birth values */
      if (pop[0][i][age] < aT_b)
        {
          popgrad[0][i][number]    = - h_B0b * pop[0][i][number]; /* background hazard only */
          popgrad[0][i][accel]     = 0.;
          popgrad[0][i][ageHaz]    = 0.;
          popgrad[0][i][length]    = 0.;
          popgrad[0][i][resDens]   = 0.;
          popgrad[0][i][maturity]  = 0.;
          popgrad[0][i][reprodBuf] = 0.;
          popgrad[0][i][weight]    = 0.;
        }
    }
  
  /* The derivatives of environmental vars: time & scaled food density */
  envgrad[0] = 1.0; /* 1/d, change in time */
  for(i=0, sumL2 = 0.; i<cohort_no[0]; i++) sumL2 += pop[0][i][age]>aT_b ? pop[0][i][number] * pow(pop[0][i][length], 2.0) : 0; 
  envgrad[1] = spline_JX(time)/ V_X/ K - hT_X * food - JT_X_Am * f * sumL2/ V_X/ K; /* 1/d, change in scaled food density */
    
  return;
}

/*
 *==========================================================================
 * SPECIFICATION OF BETWEEN COHORT CYCLE DYNAMICS
 *==========================================================================
 */

void InstantDynamics(double *env, population *pop, population *ofs)
{
  double eggs;
  register int i;

  for (i=0, eggs=0.0; i<cohort_no[0]; i++)
    if (pop[0][i][reprodBuf] > E_0)
      {
        eggs += pop[0][i][number] * pop[0][i][reprodBuf]/ E_0; /* add all eggs */
        pop[0][i][reprodBuf] = 0.0; /* reset reproduction buffer */
      }
  
  /* specify i-states at birth, because changes are set to 0, except for age */
  ofs[0][0][number]    = eggs; /* put eggs into ofs cohort */
  ofs[0][0][age]       = 0.0;  
  ofs[0][0][accel]     = qT_b;
  ofs[0][0][ageHaz]    = hT_Ab;
  ofs[0][0][length]    = L_b;
  ofs[0][0][resDens]   = E_m;
  ofs[0][0][maturity]  = E_Hb;
  ofs[0][0][reprodBuf] = 0.0;
  ofs[0][0][weight]    = L_b * L_b * L_b * (1 + ome);
  
  return;
}

/*
 *==========================================================================
 * SPECIFICATION OF OUTPUT VARIABLES
 *==========================================================================
 */

void DefineOutput(double *env, population *pop, double *output)
{

  double totN, totL, totL2, totL3, totW;
  register int i;

  for(i=0, totN=0.0, totL=0.0, totL2=0.0, totL3=0.0, totW=0.0; i<cohort_no[0]; i++)
    {
      totN  += pop[0][i][number];
      totL  += pop[0][i][number] * pop[0][i][length];
      totL2 += pop[0][i][number] * pow(pop[0][i][length], 2);
      totL3 += pop[0][i][number] * pow(pop[0][i][length], 3);
      totW  += pop[0][i][number] * pop[0][i][weight];
    }

  output[0] = food;
  output[1] = totN;
  output[2] = totL;
  output[3] = totL2;
  output[4] = totL3;
  output[5] = totW;

  return;
}
/*==========================================================================*/
