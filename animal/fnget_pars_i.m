function [Lb, Li, rB] = fnget_pars_i(p, fLbw, fLiw, frBw)

  f = fLbw(:,1); % scaled functional responses
  % is supposed to be the same for all 3 data sets
  
  y = iget_pars_i(p, f);
  Lb = y(:,2); Li = y(:,3); rB = y(:,4);
