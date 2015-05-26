function dX = dmairep(t, X)
  %  created 2002/02/18 by Bas Kooijman; modified 2007/07/12
  %
  %  routine called by mairep
  %  maintenance effects on reproduction: target is [J_EM], [J_EJ]
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (4*nc,1) vector with state variables (see below)
  %
  %% Output
  %  dX: derivatives of state variables

  global C nc c0 cM kap kapR g kJ kM v Hb Hp U0

  %% unpack state vector
  N = X(1:nc);        % cumulative number of offspring
  H = X(nc+(1:nc));   % scaled maturity H = M_H/ {J_EAm}
  L = X(2*nc+(1:nc)); % length
  U = X(3*nc+(1:nc)); % scaled reserve U = M_E/ {J_EAm}
  
  s = max(0,(C - c0)/ cM); % stress function
  %% we here apply the factor (1 + s) to k_M and kJ
  kMs = kM * (1 + s); kJs = kJ * (1 + s);

  E = U * v ./ L .^ 3;        % scaled reserve density e = m_E/m_Em (dim-less)
  %% again we scale with respect to m_Em = {J_EAm}/ (v [M_V]) of the blanc

  Lm = v/ (kM * g);           % maximum length in blank
  Lms = v ./ (kMs * g);       % maximum length in stressed situation
  eg = E .* g ./ (E + g);   % in DEB notation: e g/ (e + g)
  SC = L .^ 2 .* eg .* (1 + L ./ (g .* Lms)); % SC = J_EC/{J_EAm}

  rBs = kMs * g ./ (3 * (E + g)); % von Bert growth rate
  dL = rBs .* (E .* Lms - L);   % change in length
  dU = L .^ 2 - SC;             % change in time-surface U = M_E/{J_EAm}

  R = ((1 - kap) * SC - kJs * Hp) * kapR ./ U0; % reprod rate in %/d
  R = (H > Hp) .* max(0,R); % make sure that R is non-negative
  dH = (1 - kap) * SC - kJs .* H; % change in scaled maturity H = M_H/ {J_EAm}
  dX = [R; dH; dL; dU]; % catenate derivatives in output
