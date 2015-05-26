function dX = dfeirep(t, X)
  %  created 2007/10/03 by Bas Kooijman
  %
  %  routine called by feirep
  %  feeding effects on reproduction: target is {J_XAm} or y_EX
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (4*nc,1) vector with state variables (see below)
  %
  %% Ouput
  %  dX: derivatives of state variables

  global C nc c0 cA kap kapR g kJ kM v Hb Hp U0

  %% unpack state vector
  N = X(1:nc);        % cumulative number of offspring
  H = X(nc+(1:nc));   % scaled maturity H = M_H/ {J_EAm}
  L = X(2*nc+(1:nc)); % length
  U = X(3*nc+(1:nc)); % scaled reserve U = M_E/ {J_EAm}
  
  s = min(.99999,max(0,(C - c0)/ cA)); % stress function
  %% we here apply the factor (1 - s) to f

  E = U * v ./ L .^ 3;        % scaled reserve density e = m_E/m_Em (dim-less)

  Lm = v/ (kM * g);           % maximum length
  eg = E .* g ./ (E + g);   % in DEB notation: e g/ (e + g)
  SC = L .^ 2 .* eg .* (1 + L ./ (g .* Lm)); % SC = J_EC/{J_EAm}

  rB = kM * g ./ (3 * (E + g)); % von Bert growth rate
  dL = rB .* (E .* Lm - L);    % change in length
  dU = (1 - s) .* L.^2 - SC;     % change in time-surface U = M_E/{J_EAm}

  R = ((1 - kap) * SC - kJ * Hp) * kapR ./ U0; % reprod rate in %/d
  R = (H > Hp) .* max(0,R); % make sure that R is non-negative
  dH = (1 - kap) * SC - kJ * H; % change in scaled maturity H = M_H/ {J_EAm}
  dX = [R; dH; dL; dU]; % catenate derivatives in output
