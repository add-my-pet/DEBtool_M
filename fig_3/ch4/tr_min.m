function tr = tr_min (p, LN)
  p = p(:,1); %% unpack parameters
  kap = p(1); % -, fraction allocated to somatic maint + growth
  g   = p(2); % -, energy investment ratio
  kJ  = p(3); % 1/d, maturity maintenance rate coefficient
  kM  = p(4); % 1/d, somatic maintenance rate coefficient
  v   = p(5); % mm/d, energy conductance
  Hb  = p(6); % d mm^2, scaled maturity at birth: M_H^b/{J_EAm}
  Hp  = p(7); % d mm^2, scaled maturity at puberty: M_H^p/{J_EAm}

  Lm = v/ (g * kM);
  L = LN(:,1); N = LN(:,2);
  p_isr = p(1:6); p_isr(1) = p(6)/(1-p(1));
  U0 = initial_scaled_reserve(1, p_isr);
  Rm = ((1 - kap) * (g * L/ Lm) .* L.^2 / (1 + g) - kJ * Hp)/ U0;
  tr = max(N ./ Rm);