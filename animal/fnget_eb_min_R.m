function f_R = fnget_eb_min_R(uE0,x)
  
  global par_eb_min ulv_stop
 
  vHb = par_eb_min(3);
  
  opts = odeset('events', @eb_min_stop);
  [t ulv t_stop ulv_stop] = ode23(@dget_ulv, [0; 1e3], [uE0; 1e-10; 0], opts);

  f_R = ulv_stop(3) - vHb;
  uEb = ulv_stop(1); lb = ulv_stop(2); 
