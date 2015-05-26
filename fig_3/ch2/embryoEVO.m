function [WE WV O2] = embryoEVO(p, aWE, aWV, aO2)
  %% time in the first columns must strictly decrease with row number
  %% yolk, embryo weight and respiration data
  global g
  tb = p(1); eb = p(2); lb = p(3); Wel3 = p(4); Wl3 = p(5);
  kM = p(6); g = p(7); M = p(8); G = p(9);

  yl0 = [eb * lb^3; lb]; % initial condition at time tb
  %% we insert an extra time zero, and remove this point from result
  [t ylE] = ode23('fndembryo', [-1e-4; kM * (tb - aWE(:,1))], yl0);
  ylE(1,:) = []; WE = Wel3 * ylE(:,1);
  [t ylV] = ode23('fndembryo', [-1e-4; kM * (tb - aWV(:,1))], yl0);
  ylV(1,:) = []; WV = Wl3 * ylV(:,2) .^ 3;
  [t ylO] = ode23('fndembryo', kM * (tb - aO2(:,1)), yl0);
  %% change in volume
  dl3 = g * ylO(:,2) .^ 2 .*  (ylO(:,1) - ylO(:,2).^4) ./ ...
      (ylO(:,1) + g * ylO(:,2) .^ 3);
  O2 = G * dl3 + M * ylO(:,2) .^ 3;
