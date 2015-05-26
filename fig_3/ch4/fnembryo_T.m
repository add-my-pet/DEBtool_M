function f = fnembryo_T(Tb)
  global TA Te Ti T
  f = T * exp(TA/ Ti - TA/ Tb) - Tb + Te;

