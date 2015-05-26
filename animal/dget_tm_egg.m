function dx = dget_tm_egg(l, x)
  % created 2000/09/21 by Bas Kooijman; modified 2009/09/29
  % routine called by get_tm
  % l: scalar with scaled length l = L/L_m
  % x: 5-vector with state variables, see below
  % dx: d/dt x
  
  global g lT ha sG

  % unpack state variables
  uE = x(1); % scaled reserve
  q  = x(2); % acelleration 
  h  = x(3); % hazard
  S  = x(4); % survival probability
  % cS = x(5); % cumulative survival probability

  % derivatives with respect to time
  r = (g * uE/ l^4 - 1 - lT/ l)/ (uE/ l^3 + g); % spec growth rate in scaled time
  dl = l * r/ 3;
  duE = - uE * l^2 * (g + (1 + lT/ l) * l)/ (uE + l^3);
  dq = (q * sG + ha/ l^3) * g * uE * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - S * h;
  dcS = S;

  % pack derivatives with respect to length
  dx = [duE; dq; dh; dS; dcS]/ dl;