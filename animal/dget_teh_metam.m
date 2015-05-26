function dtEH = dget_teh_metam(l, tEH, k, g, kap, f, uHb, uHj, uHp, lT, lb, lj)
  % l: scalar with scaled length  l = L g k_M/ v
  % tEH: 3-vector with (tau, uE, uH) of embryo and juvenile
  %   tau = a k_M; scaled age
  %   uE = (g^2 k_M^3/ v^2) M_E/ {J_EAm}; scaled reserve
  %   uH = (g^2 k_M^3/ v^2) M_H/ {J_EAm}; scaled maturity
  % dtEH: 3-vector with (dt/duH, duE/duH, dl/duH)
  % called by maturity_metam
  
  t = tEH(1); % scaled age
  uE = max(1e-10,tEH(2)); % scaled reserve
  uH = tEH(3); % scaled maturity
  l2 = l * l; l3 = l2 * l;
 
  if uH < uHb % isomorphic embryo
    r = (g * uE/ l - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE =  - uE * (g/ l - r);
    duH = (1 - kap) * uE * (g/ l - r) - k * uH;
  elseif uH < uHj % V1-morphic early juvenile
    rj = (g * uE/ lb - l3 * lT/ lb - l3)/ (uE + l3); % scaled exponential growth rate between b and j
    dl = l * rj/ 3;
    duE = f * l^3/ lb - uE * (g/ lb - rj);
    duH = (1 - kap) * uE * (g/ lb - rj) - k * uH;
  elseif uH < uHp % isomorphic late juvenile
    sM = lj/ lb;
    r = (g * uE * sM/ l - l2 * lT * sM - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE = f * l2 * sM - uE * (g * sM/ l - r);
    duH = (1 - kap) * uE * (g * sM/ l - r) - k * uH;
  else % isomorphic adult
    sM = lj/ lb;
    r = (g * uE * sM/ l - l2 * lT * sM - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE = f * l2 * sM - uE * (g * sM/ l - r);
    duH = 0; % no maturation in adults
  end

  % then obtain dt/dl, duE/dl, duH/dl, 
  dtEH = [1/dl; duE/dl; duH/dl];
