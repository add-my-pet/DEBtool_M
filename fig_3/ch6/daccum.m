function dcVt = daccum(t,cVt)
  global Tc ke BCF t0
  cV = cVt(1); t = cVt(2); % unpack variables
  if t < t0 % multiply ke by 1000 to avoid small number problems
    dcVt = [.001 * ke * (BCF * spline(t,Tc) - cV); 1];
  else % after t0 elimination only
    dcVt = [- .001 * ke * cV; 1];
  end