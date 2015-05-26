function dx = dget_tul(vH, tul)
  % dx = dget_tul(uH, tul)
  % tul: 3-vector with (tau, u_E, l) of embryo
  %  tau = a k_M; u_E = (g^2 k_M^3/ v^2) M_E/ {J_EAm}; l = L g k_M/ v
  % uH: scalar with u_H = (g^2 k_M^3/ v^2) M_H/ {J_EAm} (cum invest in mat.)
  % dx: 3-vector with (dt/duH, duE/duH, dl/duH)
  
  global k g

  %t = tul(1); % scaled age
  uE = max(1e-10,tul(2)); % scaled reserve
  l = tul(3); % scaled structural length
  
  % first generate duH/dt, duE/dt, dl/dt
  duE = - uE * l ^2 * (g + l)/ (uE + l^3);
  dvH =  max(1e-10, - duE - k * vH);
  dl = (1/3) * (g * uE - l^4)/ (uE + l^3);

  % then obtain dt/duH, duE/duH, dl/duH, 
  dx = [1/dvH; duE/dvH; dl/dvH];
