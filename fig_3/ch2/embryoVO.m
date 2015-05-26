function [WV O2] = embryoVO(p, aWV, aO2)
  %% time in the first columns must strictly decrease with row number
  %% embryo weight and respiration data
  global g
  tb = p(1); eb = p(2); lb = p(3); Wl3 = p(4);
  kM = p(5); g = p(6); M = p(7); G = p(8);

  yl0 = [eb * lb^3; lb]; % initial condition at time tb
  %% we insert an extra time zero, and remove this point from result
  [t, ylV] = ode23('fndembryo', [-1e-4; kM * (tb - aWV(:,1))], yl0);
  ylV(1,:) = []; WV = Wl3 * ylV(:,2) .^ 3;
  [t, ylO] = ode23('fndembryo', [-1e-4; kM * (tb - aO2(:,1))], yl0);
  ylO(1,:) = [];
  %% change in volume
  dl3 = g * ylO(:,2) .^ 2 .*  (ylO(:,1) - ylO(:,2).^4) ./ ...
      (ylO(:,1) + g * ylO(:,2) .^ 3);
  O2 = G * dl3 + M * ylO(:,2) .^ 3;
