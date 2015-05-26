function dx = dget_tm_adult(l, x)
  % created 2000/09/21 by Bas Kooijman; modified 2009/09/29
  % routine called by get_tm
  % l: scalar with scaled length l = L/L_m
  % x: 4-vector with state variables, see below
  % dx: d/dt x
  
  global g lT ha sG f

  % unpack state variables
  q  = x(1); % acelleration 
  h  = x(2); % hazard
  S  = x(3); % survival probability
  % cS = x(4); % cumulative survival probability
  % uE = f * l^3/ g; % scaled reserve
 
  % derivatives with respect to time
  r = (f - lT - l)/ l/ (f/ g + g); % spec growth rate in scaled time
  dl = l * r/ 3;
  dq = (q * l^3 * sG + ha) * f * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - S * h;
  dcS = S;
 
  % pack derivatives with respect to length
  dx = [dq; dh; dS; dcS]/ dl;