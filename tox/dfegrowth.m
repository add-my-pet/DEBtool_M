function dX = dfegrowth(t, X)
  %  created 2007/10/03 by Bas Kooijman
  %
  %  routine called by fegrowth
  %  feeding effects on growth of ectotherm: target is {J_XAm} or y_EX
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (3 * nc,1) vector with state variables (see below)
  %
  %% Outout
  %  dX: derivatives of state variables
  
  global C nc c0 cA ke g kM v
  
  %% unpack state vector
  L = X(1:nc);              % length
  U = X(nc + (1:nc));       % scaled reserve U = M_E/ {J_EAm}
  c = X(2 * nc + (1:nc));   % scaled internal concentration

  s = min(.99999,max(0,(c - c0)/ cA));  % stress factor
  %% we here apply the factor (1 - s) to f

  E = U * v ./ L .^ 3;      % scaled reserve density e = m_E/m_Em (dim-less)

  Lm = v ./ (kM * g);       % maximum length
  eg = E .* g ./ (E + g);   % in DEB notation: e g/ (e + g)
  SC = L .^ 2 .* eg .* (1 + L ./ (g .* Lm)); % SC = J_EC/ {J_EAm}

  rB = kM * g ./ (3 * (E + g)); % von Bert growth rate
  dL = rB .* (E .* Lm - L);   % change in length
  dU = (1 - s) .* L.^2 - SC;  % change in time-surface U = M_E/{J_EAm}
  dc = (ke * Lm .* (C - c) - 3 * dL .* c) ./ L; % change in scaled int. conc

  dX = [dL; dU; dc]; % catenate derivatives in output
