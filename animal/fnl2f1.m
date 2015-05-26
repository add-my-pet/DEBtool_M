function F = fnl2f1(f)
  %  called by function l2f1
  %  F = fnl2f1(f)
  %  f: scalar with scaled functional response
  %  F: scalar with function value that has to be set equal to zero
  global g k vHb lT l t

  %f = min(1,max(1e-8,f));
  rB      = 1/ 3/ (1 + f/ g); %-, scaled von Bert. growth rate
  [tb lb] = get_tb([g;k;vHb],f); % scaled age and scaled length at birth
  lt = f - lT - (f - lT - lb) * exp (- max(0,t - tb) * rB);
  F  = l - lt; %