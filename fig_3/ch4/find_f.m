function [f, info] = find_f(LN,p)
  %% finds scaled func response f for given L, N

  global L N kap g kJ kM v Hb Hp tR
  
  %% unpack parameters
  kap = p(1); % -, fraction allocated to somatic maint + growth
  g   = p(2); % -, energy investment ratio
  kJ  = p(3); % 1/d, maturity maintenance rate coefficient
  kM  = p(4); % 1/d, somatic maintenance rate coefficient
  v   = p(5); % mm/d, energy conductance
  Hb  = p(6); % d mm^2, scaled maturity at birth: M_H^b/{J_EAm}
  Hp  = p(7); % d mm^2, scaled maturity at puberty: M_H^p/{J_EAm}
  tR  = p(8); % d, intermoult period times kapR

  %% unpack variables
  L = LN(1); N = LN(2);

  Lm = v/ (g * kM);
  U0 = initial_scaled_reserve(1, [Hb/(1-kap); g; kJ; kM; v]);
  A = (N * U0/ tR + kJ * Hp)/ ((1 - kap) * L^2 * (1 + L/ Lm));
  f0 = A * g/ (g - A);
  f1 = g * kJ * Hp/ ((1 - kap) * L^2 * g * (1 + L * kM/ v) - kJ * Hp);

  if g < A | f0 < f1
    printf('inconsistent parameter values\n');
  end
  
  [f, val, info] = fsolve('fnfind_f', max(f0, f1 +.1));
