function F = fnegg1(abE0)
  % modified 2009/09/29
  
  global f EJb EG Em pM pJ kap

  % unpack state variables
  ab = abE0(1); E0 = abE0(2);
  
  [a, EViV] = ode45('degg',  [0; ab], [E0; 1e-8; 0]);
  Eb = EViV(end,1); Vb = EViV(end,2); iVb = EViV(end,3);       
  k = 1/ kap - 1;
  F = [EJb - k * EG * Vb - ( k * pM - pJ) * iVb;
       Eb - f * Em * Vb];
      