function F = fnegg(ab)
  % modified 2009/09/29
  
  global E0 EG EJb pM pJ kap

  [a, EViV] = ode45('degg', [0; ab], [E0; 1e-8; 0]);
  Eb = EViV(end,1); Vb = EViV(end,2); iVb = EViV(end,3);       
  k = 1/ kap - 1;
  F = EJb - k * EG * Vb - ( k * pM - pJ) * iVb;      