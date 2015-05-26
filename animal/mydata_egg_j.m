%% Demonstrates the use of egg_j
%  for the ontongeny of the state of embryo's till birth

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

  %% choose scaled functional response f = 1 and f = 0.6
  [aEL E0 lb] = get_ael(par, [1; .6]);

  aHEL = egg_j(par, [0; E0(1); 1e-10], linspace(0,aEL(1,1),100)'); 
  aHEL1 = egg_j(par, [0; E0(2); 1e-10], linspace(0,aEL(2,1),100)'); 

subplot(1,3,1)
  plot (aHEL(:,1), aHEL(:,2), 'r', aHEL1(:,1), aHEL1(:,2), 'b') 
  xlabel('age, d')
  ylabel('maturity, mol')
  legend('f = 1', 'f = 0.6',4)
subplot(1,3,2)
  plot (aHEL(:,1), aHEL(:,3), 'r', aHEL1(:,1), aHEL1(:,3), 'b')
  xlabel('age, d')
  ylabel('reserve, mol')
  legend('f = 1', 'f = 0.6',3)
subplot(1,3,3)
  plot (aHEL(:,1), aHEL(:,4), 'r', aHEL1(:,1), aHEL1(:,4), 'b')
  xlabel('age, d')
  ylabel('length, cm')
  legend('f = 1', 'f = 0.6',4)
