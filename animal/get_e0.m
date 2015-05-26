function F = get_e0(E0)
  % F = get_e0(E0)
  % E0: scalar with M_E^0
  % F: scalar that is set to zero
  % used to find M_E^0 such that m_E(a_b) = f m_Em
  % called by get_ael
  
  global JEAm v f MHb

  aEL0 = [0; E0; 1e-10]; H = [0; MHb];
  [H, A] = ode45('dget_ael', H, aEL0);
  MEb = A(end,2); Lb = A(end,3);
  F = MEb - f * Lb^3 * JEAm/ v;
