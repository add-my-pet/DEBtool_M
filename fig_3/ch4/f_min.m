function f0 = f_min (p, L)
  %% f0: f for reprod R = 0 given length L
  p = p(:,1); %% unpack parameters
  kap = p(1); % -, fraction allocated to somatic maint + growth
  g   = p(2); % -, energy investment ratio
  kJ  = p(3); % 1/d, maturity maintenance rate coefficient
  kM  = p(4); % 1/d, somatic maintenance rate coefficient
  v   = p(5); % mm/d, energy conductance
  Hb  = p(6); % d mm^2, scaled maturity at birth: M_H^b/{J_EAm}
  Hp  = p(7); % d mm^2, scaled maturity at puberty: M_H^p/{J_EAm}

  L = max(L(:,1));
  f0 = 1./( (1- kap) * (L.^2 + L.^3 * kM/ v)/ (kJ * Hp) - 1/ g);
