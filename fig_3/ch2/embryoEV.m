function [WE WV] = embryoEV(p, aWE, aWV)
  %% time in the first columns must strictly decrease with row number
  %% yolk and embryo weight data
  global g
  tb = p(1); eb = p(2); lb = p(3); Wel3 = p(4); Wl3 = p(5);
  kM = p(6); g = p(7);

  yl0 = [eb * lb^3; lb]; % initial condition at time tb
  %% we insert an extra time zero, and remove this point from result
  [t, ylE] = ode23('fndembryo', [-1e-4; kM * (tb - aWE(:,1))], yl0);
  ylE(1,:) = []; WE = Wel3 * ylE(:,1);
  [t, ylV] = ode23('fndembryo', [-1e-4; kM * (tb - aWV(:,1))], yl0);
  ylV(1,:) = []; WV = Wl3 * ylV(:,2) .^ 3;
