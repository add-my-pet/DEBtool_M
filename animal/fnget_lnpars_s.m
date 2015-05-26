function [Lb, Lp, Li, rB, Ri] = fnget_lnpars_s(p, fLbw, fLpw, fLiw, frBw, fRiw)
  
  f = fLbw(:,1); % scaled functional responses
  % is supposed to be the same for all 5 data sets
  
  y = iget_pars_s(exp(p), f);
  Lb = y(:,2); Lp = y(:,3); Li = y(:,4); rB = y(:,5); Ri = y(:,6);