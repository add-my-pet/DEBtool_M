function dX = dgr0rep(t, X)
  %  created 2002/02/18 by Bas Kooijman; modified 2007/07/12; 2007/09/15
  %
  %  routine called by gr0rep
  %  maintenance effects on reproduction: target is y_EV
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (5*nc,1) vector with state variables (see below)
  %
  %% Output
  %  dX: derivatives of state variables

  global C nc c0t cGt kap kapR g kJ kM v Hb Hp Lb0

  %% unpack state vector
  N = X(1:nc);         % cumulative number of offspring
  H = X(nc+(1:nc));    % scaled maturity H = M_H/ {J_EAm}
  L = X(2*nc+(1:nc));  % length
  U = X(3*nc+(1:nc));  % scaled reserve U = M_E/ {J_EAm}
  ct = X(4*nc+(1:nc)); % scaled internal concentration-time
  
  s = max(0,(ct - c0t)/ cGt);  % stress factor
  %% we here apply the factor (1 + s) to y_EV, or (1 + s)^-1 to y_VE so
  %% since g = v [M_V]/ (\kap {J_EAm} y_VE) we have
  gs = g * (1 + s);           % stressed value for energy investment ratio
  %% since k_M = j_EM y_VE
  kMs = kM ./ (1 + s);        % stressed value for maint rate coefficient

  E = U * v ./ L .^ 3;        % scaled reserve density e = m_E/m_Em (dim-less)
  %% again we scale with respect to m_Em = {J_EAm}/ (v [M_V]) of the blanc

  Lm = v ./ (kM * g);       % maximum length; not affected by y_EV
  eg = E .* gs ./ (E + gs);   % in DEB notation: e g/ (e + g)
  SC = L .^ 2 .* eg .* (1 + L ./ (gs .* Lm)); % SC = J_EC/{J_EAm}

  rBs = kMs .* gs ./ (3 * (E + gs)); % von Bert growth rate
  dL = rBs .* (E .* Lm - L);      % change in length
  dU = L .^ 2 - SC;               % change in time-surface U = M_E/{J_EAm}
  dct = (Lm .* C - 3 * dL .* ct) ./ L; % change in scaled int. conc-time

  U0 = 0 * N; % initiate scaled reserve of fresh egg
  for i = 1:nc
    p_U0 = [Hb/ (1 - kap); gs(i); kJ; kMs(i); v];
    [U0(i), Lb0(i)] = initial_scaled_reserve(1,p_U0,Lb0(i));
  end
  R = ((1 - kap) * SC - kJ * Hp) * kapR ./ U0; % reprod rate in %/d
  R = (H > Hp) .* max(0,R); % make sure that R is non-negative
  dH = (1 - kap) * SC - kJ * H; % change in scaled maturity H = M_H/ {J_EAm}
  dX = [R; dH; dL; dU; dct]; % catenate derivatives in output
