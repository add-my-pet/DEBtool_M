function df = dha0rep(X, t)
  %  created 2002/02/18 by Bas Kooijman, modified 2007/08/08
  %
  %  routine called by ha0rep
  %  hazard effects on reproduction of ectotherm: target is hazard of offspring
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (5 * nc,1) vector with state variables (see below)
  %
  %% Output
  %  dX: derivatives of state variables

  global C nc c0 cH ke kap kapR g kJ kM v Hb Hp

  %% unpack state vector
  N = X(1:nc);        % cumulative number of offspring
  H = X(nc+1:nc);     % scaled maturity H = M_H/ {J_EAm}
  L = X(2*nc+(1:nc)); % length
  U = X(3*nc+(1:nc)); % scaled reserve U = M_E/ {J_EAm}
  c = X(4*nc+(1:nc)); % scaled internal concentration
  
  s = max(0,(c - c0)/ cH);  % stress function

  E = U * v ./ L .^ 3;        % scaled reserve density e = m_E/m_Em (dim-less)
  %% again we scale with respect to m_Em = {J_EAm}/ (v [M_V]) of the blanc

  Lm = v./ (kM * g);         % maximum length
  eg = E .* g ./ (E + g);      % in DEB notation: e g/ (e + g)
  SC = L .^ 2 .* eg .* (1 + L ./ (g .* Lm)); % SC = J_EC/{J_EAm}

  rB = kM * g/ (3 * (E + g)); % von Bert growth rate
  dL = rB * (E * Lm - L);     % change in length
  dU = L.^2 - SC;             % change in time-surface U = M_E/{J_EAm}
  dc = (ke * Lm .* (C - c) - 3 * dL .* c) ./ L; % change in scaled int. conc

  par = [kap; kapR; g; kJ; kM; v; Hb; Hp];
  [p, U] = iget_pars_r(par, 1);
  U0 = U(1);

  R = exp(-s) * ((1 - kap) * SC - kJs * Up) * kapR/ U0; % reprod rate in %/d
  R = (H > Hp) .* max(0,R); % make sure that R is non-negative
  dH = (1 - kap) * SC - kJ * H; % change in scaled maturity H = M_H/ {J_EAm}
  dX = [R; dH; dL; dU; dc]; % catenate derivatives in output
