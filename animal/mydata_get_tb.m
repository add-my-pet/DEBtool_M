%% Demonstrates the use of get_tb

% set parameters
par = [20; .2; .1]; % g, k, v_Hb
eb = 0.5; % scaled reserve density at birth

% get l_b, \tau_b and u_E^0
% tb1 = 0; lb1 = 0; info1 = 0; % initiate to skip get_tb1
[tb1 lb1 uE01 info1] = get_tb1(par, eb);
[tb lb info] = get_tb(par,eb);
uE0 = get_ue0(par, eb);

% compare results
[tb1 lb1 uE01 info1;
 tb  lb  uE0 info]

return

% compar incomplete beta function
% set par
x = .0001;
[beta0(0,x) beta_43_0(x)]