function dz = dget_lb1(x, z)
  % modified 2009/09/29
  % dz = dget_lb2(x, z)
  % z: 4-vector with (v,dv,rv,w) of embryo
  % dz: 4-vector with d/dx (v,dv,rv,w)
  
  global k g Lb xb xb3
 
  v  = z(1); % v(x)
  lv = z(2); % v'(x)/v(x); v'(x) = d/d l_b v(x)
  %rv = z(3); % r(x)/ v(x)
  %w  = z(4); % (r'(x)/r(x) - v'(x)/v(x)) r(x)/v(x)
  
  x3 = x^(1/ 3);
  l = x3/ (xb3/ Lb - beta0(xb, x)/ 3/ g); % l(x)
  dl = (l/ Lb)^2 * xb3/ x3; % l'(x)
  
  dv = - v * (k - x)/ (1 - x) * l/ g/ x; % d/dx v(x)

  dlv = - lv * (k - x)/ (1 - x) * dl/ g/ x; % d/dx v'(x)/v(x)

  r = l + g;
  drv = r/ v; % r(x)/ v(x)

  lr = dl/ r; % r'(x)/ r(x)
  dw = (lr - lv) * drv;
  
  dz = [dv; dlv; drv; dw];
