function dx = dget_tm(tau, x)
  % created 2000/09/06 by Bas Kooijman, modified 2009/01/24
  % routine called by get_tm
  % tau: scalar with scaled age: a k_M
  % x: 7-vector with state variables, see below
  % dx: d/dt x
  
  global g k l_T vHb vHp hT_a s_G f Sb Sp

  % unpack state variables
  l  = x(1); % scaled length
  uE = x(2); % scaled reserve
  vH = x(3); % scaled maturity
  q  = x(4); % acelleration 
  h  = x(5); % hazard
  S  = x(6); % survival probability
  %cS = x(7); % cumulative survival probability
  
  if vH < vHb
    F = 0; % no feeding for embryo
    Sb = S;
  else
    F = f;
  end
  
  r = (g * uE/ l^4 - 1 - l_T/ l)/ (uE/ l^3 + g); % spec growth rate in scaled time
  dl = l * r/ 3;
  duE = F * l^2 - uE * l^2 * (g + (1 + l_T/ l) * l)/ (uE + l^3);
  if vH < vHp 
    dvH = uE * l^2 * (g + l)/ (uE + l^3) - k * vH;
    Sp = S;
  else       % adult
    dvH = 0;
  end
  dq = (q * s_G + hT_a/ l^3) * g * uE * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - S * h;
  dcS = S;
  
  % pack output
  dx = [dl; duE; dvH; dq; dh; dS; dcS];