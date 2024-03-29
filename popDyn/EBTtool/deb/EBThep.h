/***
  NAME
    deb\EBThep.h

  PURPOSE
    header file used by the Escalator Boxcar Train program for DEB models

  HISTORY
    SK - 2020/04/13: Created by DEBtool_M/animal/get_EBT
***/

#define POPULATION_NR   1
#define I_STATE_DIM     9 /* a, q, h_a, L, E, E_R, E_H, W, s_M */
#define I_CONST_DIM     0
#define ENVIRON_DIM     2 /* time, scaled food density */
#define OUTPUT_VAR_NR   6 /* (time,) scaled food density, nr ind, tot struc length, surface, vol, weight */
#define PARAMETER_NR    36
#define TIME_METHOD     DOPRI5 /* we need events */
#define EVENT_NR        3 /* birth, weaning, puberty */
#define DYNAMIC_COHORTS 0
