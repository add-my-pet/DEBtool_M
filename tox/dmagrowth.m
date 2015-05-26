function dX = dmagrowth(t, X)
  %  created 2002/01/21 by Bas Kooijman, modified 2006/10/07; 2007/07/11
  %
  %  routine called by magrowth
  %  maintenance effects on growth of ectotherm: target is [J_EM]
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (3 * nc,1) vector with state variables (see below)
  %
  %% Output
  %  dX: derivatives of state variables

  global C nc c0 cM ke g kM v

  %% unpack state vector
  L = X(1:nc);              % length
  U = X(nc + (1:nc));       % scaled reserve U = M_E/ {J_EAm}
  c = X(2 * nc + (1:nc));   % scaled internal concentration
  
  s = max(0,(c - c0)/ cM);  % stress factor
  %% we here apply the factor (1 + s) to k_M so
  kMs = kM * (1 + s);

  E = U * v ./ L .^ 3;      % scaled reserve density e = m_E/m_Em (dim-less)
  %% again we scale with respect to m_Em = {J_EAm}/ (v [M_V]) of the blanc

  Lms = v ./ (kMs * g);     % maximum length in stressed situation
  eg = E * g ./ (E + g);     % in DEB notation: e g/ (e + g)
  SC = L .^ 2 * eg .* (1 + L./ (g * Lms));     % SC = J_EC/ {J_AEm}

  rBs = kMs * g ./ (3 * (E + g)); % von Bert growth rate
  dL = rBs .* (E .* Lms - L);     % change in length
  dU = L.^2 - SC;               % change in time-surface U = M_E/{J_EAm}
  dc = (ke * Lms .* (C - c) - 3 * dL .* c) ./ L; % change in scaled int. conc

  dX = [dL; dU; dc]; % catenate derivatives in output
