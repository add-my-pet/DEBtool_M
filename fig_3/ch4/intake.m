function tfS = intake(p, tLdL)
  %% tfS = intake(p, tLdL)
  %% p: parameter vector
  %% tLdL: (n,3)-matrix with time, wet weight^1/3, d/dt wet weight^1/3
  %% tfS:  (n,2)-matrix with time, fV^(2/3) = J_X/J_Xm

  %% unpack parameters
  dV = p(1); % g/cm^3; specific density of wet weigth [Ww]
  dE = p(2); % g/cm^3; specific density of reserve wE[MEm]
  g  = p(3); % -; investment ratio
  v  = p(4); % cm/d; energy conductance
  lh = p(5); % -; scaled heating length
  Lm = p(6); % cm; max volumetric length Vm^1/3
  et = p(7); % -; initial scaled reserve density

  [nt k] = size(tLdL); dt = tLdL(2,1) - tLdL(1,1); tfS = tLdL(:,[1 2]);
  for i = 1:nt % cf Eq (7.4) and (7.5) {227}
    %% W = (d_V + d_E * e) * V; V = L^3
    L = tLdL(i,2)/ (dV + dE * et)^(1/3); % structural length 
    dlnW = 3 * tLdL(i,3)/ tLdL(i,2); % rel change in wet weight
    %% d/dt V = v (V^2/3 (e - lh) - V/Lm)/ (e + g): Eq (3.18) {94}
    dlnV = v * ((et - lh)/ L - 1/ Lm)/ (et + g); % rel change in struc vol
    %% d/dt W = dV * d/dt V + dE * V * d/dt e
    de = (dlnW - dlnV) * (dV + dE * et)/ dE; % change in e(t)
    tfS(i,2) = L^2 * (et + L * de/ v); % J_X/{J_Xm} = f V^2/3
    et = et + dt * de; % integration of e(t)
  end
