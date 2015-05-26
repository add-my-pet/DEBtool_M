function dX = dmaigrowth(t, X)
  %  created 2002/02/18 by Bas Kooijman, modified 2006/10/07; 2007/07/11
  %
  %  routine called by maigrowth
  %  maintenance effects on growth of ectotherm: target is [J_EM]
  %
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (2 * nc,1) vector with state variables (see below)
  %
  %% Output
  %  dX: derivatives of state variables

  global C nc c0 cM v kM g

  %% unpack state vector      
  L = X(1:nc);               % length
  U = X(nc + (1:nc));        % scaled reserve U = M_E/ {J_EAm}
  
  s = max(0,(C - c0)/ cM);   % stress function
  %% we here apply the factor (1 + s) to k_M so
  kMs = kM * (1 + s);

  E = U * v ./ L .^ 3;      % scaled reserve density e = m_E/m_Em (dim-less)
  %% again we scale with respect to m_Em = {J_EAm}/ (v [M_V]) of the blanc

  Lms = v ./ (kMs * g);       % maximum length in stressed situation
  eg = E .* g ./ (E + g);     % in DEB notation: e g/ (e + g)
  SC = L .^ 2 .* eg .* (1 + L ./ (g .* Lms)); % SC = J_EC/{J_EAm}

  rBs = kMs * g ./ (3 * (E + g)); % von Bert growth rate
  dL = rBs .* (E .* Lms - L);     % change in length
  dU = L .^ 2 - SC;             % change in time-surface U = M_E/{J_EAm}

  dX = [dL; dU]; % catenate derivatives in output
