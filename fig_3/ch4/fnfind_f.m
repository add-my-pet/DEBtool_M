function zero = fnfind_f(f)
  %% finds scaled func response f for given L, N
  %% L: length
  %% N: number of eggs
  %% tR: kapR * intermoult period
  %% called from find_f
  
  global L N kap g kJ kM v Hb Hp tR
  
  Lm = v/ (kM * g); % maximum length
  f0 = g * kJ * Hp/ ((1 - kap) * L^2 * g * (1 + L * kM/ v) - kJ * Hp);

  U0 = initial_scaled_reserve(min(1,max(f0,f)), [Hb/(1-kap); g; kJ; kM; v]);
  %% scaled catabolic flux: J_EC/{J_EAm}
  SC = L^2 * (g * f/ (g + f)) * (1 + L/ (g * Lm));
  zero = N - tR * ((1 - kap) * SC - kJ * Hp)/ U0;
