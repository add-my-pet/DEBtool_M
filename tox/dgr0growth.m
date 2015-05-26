function dX = dgr0growth(t, X)
  %  created 2002/02/18 by Bas Kooijman, modified 2006/10/07; 2007/07/11
  %
  %  routine called by gr0growth
  %  growth effects on growth of ectotherm: target is y_VE
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (3 * nc,1) vector with state variables (see below)
  %
  %% Output
  %  dX: derivatives of state variables

  global C nc c0t cGt g kM v
  
  %% unpack state vector
  L = X(1:nc);               % length
  U = X(nc + (1:nc));        % time-surface U = M_E/{J_EAm}
  ct = X(2 * nc + (1:nc));   % scaled internal concentration-time
 
  s = max(0,(ct - c0t)/ cGt);  % stress factor
  %% we here apply the factor (1 + s) to y_EV, or (1 + s)^-1 to y_VE so
  %% since g = v [M_V]/(\kap {J_EAm} y_VE) we have
  gs = g * (1 + s);          % stressed value for energy conductance
  %% since k_M = j_EM y_VE
  kMs = kM./ (1 + s);        % stressed value for energy conductance
  
  E = U * v ./ L .^ 3;      % scaled reserve density e = m_E/m_Em (dim-less)
  %% again we scale with respect to m_Em = {J_EAm}/ (v [M_V]) of the blanc

  Lm = v./ (kM .* g);         % maximum length; does not depend on y_EV
  es = U  * v ./ L.^3;         % scaled reserve density
  eg = E .* gs ./ (E + gs);    % in DEB notation: e g/ (e + g)
  SC = L .^ 2 .* eg .* (1 + L./ (gs .* Lm)); % SC = J_EC/{J_AEm}

  rBs = kMs .* gs ./ (3 * (E + gs)); % von Bert growth rate
  dL = rBs .* (E * Lm - L);      % change in length
  dU = L .^ 2 - SC;               % change in time-surface U = M_E/{J_EAm}
  dct = (Lm .* C - 3 * dL .* ct)./ L; % change in scaled internal conc-time

  dX = [dL; dU; dct]; % catenate derivatives in output
