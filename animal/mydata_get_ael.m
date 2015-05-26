%% Demonstrates the use of get_ael
%  for the initial state of embryo's and at birth

%% set parameters
  JEAm = 5;    % {J_EAm}
  kap  = .7;   % \kappa
  v    = 0.2;  % v
  JEM  = 1e-3; % [J_EM]
  yVE  = .8;   % y_VE
  MHb  = .4;   % M_H^b
  MV   = 10;   % [M_V]
  kJ   = 10 * yVE * JEM * (1 - kap)/ (kap * MV); % k_J
  par = [JEAm kap v JEM kJ yVE MHb MV]';

  %% set scaled functional response
  f = linspace(.55,1,100)';
  %% get states
  [aELf E0f lbf] = get_ael(par,f);
  %% prepare for plotting
  fE = [f, aELf(:,2)]; fL = [f, aELf(:,3)]; fl = [f, lbf];
  fE0 = [f, E0f];

subplot(1,3,2)
  plot(fE(:,1), fE(:,2), 'r')
  xlabel('scaled func reponse, f')
  ylabel('reserve at birth, mol')
subplot(1,3,3)
  plot (fL(:,1), fL(:,2), 'r')
  xlabel('scaled func reponse, f')
  ylabel('length at birth, cm')
subplot(1,3,1)
  xlabel('scaled func reponse, f')
  plot (fE0(:,1), fE0(:,2), 'r')
  ylabel('initial reserve, mol')
