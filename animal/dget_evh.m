function dEVH = dget_evh(a, EVH, f, Lm, LT, mEm, g, v, JEAm, yVE, JEM, JET, kJ, kap, MHb, MHp, MV)
  % ode specification for get_evh

  % unpack state variables
  M_E = EVH(1); M_V = EVH(2); M_H = EVH(3); % mol

  L = (M_V/ MV)^(1/3);  % cm, structural length
  ee = (M_E/ M_V)/ mEm; % -, scaled reserve density
  r = v * (ee/ L - (1 + LT/L)/ Lm)/ (ee + g); % 1/d, spec growth rate

  J_EA = JEAm * (M_H > MHb) * f * L^2; % mol/d assimilation
  J_EC = M_E * (v/ L - r);             % mol/d, reserve mobilisation rate
  J_EJ = kJ * min(MHp, M_H);           % mol/d, maturity maintenance
  J_EM = JEM * L^3;                    % mol/d, volume-linked somatic maintenance
  J_ET = JET * L^2;                    % mol/d, surface-linked somatic maintenance

  dM_E = J_EA - J_EC;                             % mol/d
  dM_V = yVE * (kap * J_EC - J_EM - J_ET);        % mol/d
  dM_H = ((1 - kap) * J_EC - J_EJ) * (M_H < MHp); % mol/d

  % pack output
  dEVH = [dM_E; dM_V; dM_H];
