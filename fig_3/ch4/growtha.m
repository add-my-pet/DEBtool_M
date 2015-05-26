function dlt = growtha(t, lt) 
  %% called from fig_7_5
  
  global TA T0 g kM kf kT
  l = lt(1); t = lt(2); % unpack state variables
  %% we append a dummy variable to prevent ode solver
  %%   to make big steps if dl == 0 for too long
  f = spline(t, kf); T = 273 + spline(t, kT);
  %% see eq (7.1) {225}
  if T > T0 & f > l
    k = g * kM * exp(TA/ 288 - TA/ T)/ 3;
    dl = k * (f - l)/ (f + g); dlt = [dl; 1; t/1000];
  else 
    dl = 0; dlt = [dl; 1; t/1000];
  end
 