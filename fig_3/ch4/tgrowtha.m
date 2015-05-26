function [L1, L2, L3, L4] = tgrowtha(p, tL1, tL2, tL3, tL4)
  %% called from fig_7_5
  
  global TA T0 g kM kf kT
  %% unpack parameters
  TA = p(1); T0 = p(2); Lm = p(3); g = p(4); kM = p(5);
  L10 = p(6); L20 = p(7); L30 = p(8); L40 = p(9); % initial lengths
  kf = [kT(:,1), p(10:14)]; % knots for func response

  [t, L1] = ode45('growtha', tL1(:,1), [L10/ Lm; 0; 0]); L1 = Lm * L1(:,1);
  [t, L2] = ode45('growtha', tL2(:,1), [L20/ Lm; 0; 0]); L2 = Lm * L2(:,1);
  [t, L3] = ode45('growtha', tL3(:,1), [L30/ Lm; 0; 0]); L3 = Lm * L3(:,1);
  [t, L4] = ode45('growtha', tL3(:,1), [L40/ Lm; 0; 0]); L4 = Lm * L4(:,1);

