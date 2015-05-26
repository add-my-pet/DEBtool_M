function dXt = dchem (t, Xt)
%% created at 2000/10/20 by Bas Kooijman
%% calculates changes in a generalized reactor

  global h h_X h_V h_P hT_a X_r kT_E kT_M g m_Em;
  global zeta K jT_X_Am;
  
  %% unpack Xt
  X   = Xt(1);  X_V = Xt(2);  e_  = Xt(3);
  X_DV = Xt(4); X_DE = Xt(5); X_P = Xt(6);

  f = X/(X + K);                         % -, scaled functional response
  r = (kT_E*e_ - kT_M*g)/(e_ + g);       % 1/d, spec growth rate
  h_d = hT_a*e_*(1 + g)/(e_ + g);        % 1/d, spec death rate

  dX    = X_r*h - X_V*jT_X_Am*f - X*h_X; % M/d, substrate
  dX_V  = X_V*(r - h_V - h_d);           % M/d, structure
  de_   = kT_E*(f - e_);                 % 1/d, scaled reserve density
  dX_DV = h_d*X_V - h_V*X_DV;            % M/d, dead structure
  dX_DE = h_d*e_*m_Em*X_V - h_V*X_DE;    % M/d, dead reserve
  dX_P  = zeta*[kT_E*f; kT_M*g; max(0,r)*g]*X_V - h_P*X_P;
				         % M/d, product

  %% pack dXt
  dXt = [dX; dX_V; de_; dX_DV; dX_DE; dX_P];
