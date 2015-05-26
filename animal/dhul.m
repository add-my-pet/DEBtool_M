function dx = dhul(t, hul)
  %  tul: 3-vector with (u_H, u_E, l) of embryo
  %   u_H = (g^2 k_M^3/ v^2) M_H/ {J_EAm} (cum invest in mat.)
  %   u_E = (g^2 k_M^3/ v^2) M_E/ {J_EAm};
  %   l = L g k_M/ v
  %   derivates with respect to tau = a k_M; 
  %  dx: 3-vector with (duH, duE, dl)
  
  global g k kap

  vH = hul(1); % scaled maturity
  uE = hul(2); % scaled reserve
  l  = hul(3); % scaled structural length
  
  duE = - uE * l ^2 * (g + l)/ (uE + l^3);
  dvH =  - duE - k * vH;
  dl = (1/3) * (g * uE - l^4)/ (uE + l^3);

  dx = [dvH; duE; dl];
