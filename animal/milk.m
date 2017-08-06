%% milk
% Gets  the cumulative amount of assimilation energy from birth till weaning (of baby mammals)

%%
function U_L = milk(f, p)
  % created 2011/12/01 by Bas Kooijman
  
  %% Syntax
  % U_L = <../milk.m *milk*>(f, p)
  
  %% Description
  % Computes the cumulative amount of assimilation energy from birth till weaning (of baby mammals)
  %
  % Input
  %
  % * f: scalar with scaled functional response
  % * 5-vector with parameters: L_b L_x L_i t_x kap_L
  %
  % Output
  %
  % * U_L: scalar with scaled amount of milk per baby, from birth till weaning
  %
  %        U_L = E_L/ {p_Am}: U_L = f int_0^(a_x - a_b) L^2(t) dt
  %
  % Remarks
  % the amount of (scaled) energy that is required to produce this milk is U_E/ kap_RL
  
  %% Example of use
  % milk(1, [1; 2; 10; 3; .9])
  
  % unpack parameters
  L_b = p(1); L_x = p(2); L_i = p(3); % cm, lengths at birth, weaning, ultimate
  t_x = p(4);    % d, time since birth at weaning
  kap_L = p(5);  % -, conversion efficiency from milk to (baby) reserve

  r_B = log((L_i - L_b)/(L_i - L_x))/ t_x; % 1/d, von Bert growth rate
  % int_L2 = \int_0^{t_x} L^2(t) dt, where t_x = a_x - a_b
  int_L2 =  L_i^2 * t_x - (L_i + (L_x + L_b)/2) * (L_x - L_b)/ r_B; % d.cm^2
  U_L = f * int_L2/ kap_L; % d.cm^2 