%% egg_j
% Gets embryo maturity, reserb and length as function of age 
%  in case of type M acceleration

%%
function aHEL = egg_j(par, HEL0, a)
  % created 2006/08/28 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % aHEL = <../egg_j.m *egg_j*>(par, HEL0, a)
  
  %% Description
  % Gets embryo maturity, reserb and length as function of age
  %
  % Input
  %
  % * par: 8-vector with parameters:
  %    {J_EAm}, kap, v, [J_EM], k_J, y_VE, M_Hb, [M_V]
  % * HEL0: 3-vector with M_H^0, M_E^0, L_0
  % * a: n-vector with ages
  %
  % Output
  %
  % * aHEL: (n,4)-matrix with a, M_H, M_E, L
  
  %% Example of use
  % See <../mydata_egg_j.m *mydata_egg_j*>
  
  global JEAm kap v kJ g Lm

  JEAm = par(1); % {J_EAm}
  kap  = par(2); % \kappa
  v    = par(3); % v
  JEM  = par(4); % [J_EM]
  kJ   = par(5); % k_J
  yVE  = par(6); % y_VE
  %MHb  = par(7); % M_H^b
  MV   = par(8); % [M_V]

  g = v * MV/ (kap * JEAm * yVE); % energy investment ratio
  Lm = kap * JEAm/ JEM; % maximum length

  [a, HEL] = ode45('degg_j',a, HEL0);
  aHEL = [a, HEL];
