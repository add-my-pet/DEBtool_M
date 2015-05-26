function dX = dhairep(t, X)
  %  created 2002/02/18 by Bas Kooijman; modified 2007/07/12
  %
  %  routine called by hairep
  %  hazard effects on reproduction
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (4 * nc,1) vector with state variables (see below)
  %
  %% Output
  %  dX: derivatives of state variables

  global C nc c0 cH kap kapR g kJ kM v Hb Hp U0

  %% unpack state vector
  N = X(1:nc);        % cumulative number of offspring
  H = X(nc+(1:nc));   % scaled maturity H = M_H/ {J_EAm}
  L = X(2*nc+(1:nc)); % length
  U = X(3*nc+(1:nc)); % scaled reserve U = M_E/ {J_EAm}
  
  s = max(0,(C - c0)/ cH); % stress factor

  E = U * v ./ L .^ 3;        % scaled reserve density e = m_E/m_Em (dim-less)
  %% again we scale with respect to m_Em = {J_EAm}/ (v [M_V]) of the blanc

  Lm = v ./ (kM * g);       % maximum length
  eg = E .* g ./ (E + g); % in DEB notation: e g/ (e + g)
  SC = L .^ 2 .* eg .* (1 + L ./ (g .* Lm)); % SC = J_EC/{J_EAm}

  rB = kM * g ./ (3 * (E + g)); % von Bert growth rate
  dL = rB .* (E .* Lm - L);   % change in length
  dU = L .^ 2 - SC;           % change in time-surface U = M_E/{J_EAm}

  R = exp(-s) .* ((1 - kap) * SC - kJ * Hp) * kapR/ U0; % reprod rate in %/d
  R = (H > Hp) .* max(0,R); % make sure that R is non-negative
  dH = (1 - kap) * SC - kJ .* H; % change in scaled maturity H = M_H/ {J_EAm}
  dX = [R; dH; dL; dU]; % catenate derivatives in output
