%% parameters for 'enzyme'
%% they are expressed on molar basis; this is convenient for balances,
%% not all parameters are required for any particular application

  global T T_1 Tpars TC
  global b_A b_B k_A k_B k_C J_Cm;

%% temperature parameters (in Kelvin)
%%   these pars are not relevant if T = T_1
T    =   293; % K, actual body temperature
T_1  =   293; % K, temp for which rate pars are given 
T_A  = 12000; % K, Arrhenius temp
T_L  =   277; % K, lower boundary tolerance range
T_H  =   318; % K, upper boundary tolerance range
T_AL = 20000; % K, Arrhenius temp for lower boundary
T_AH =190000; % K, Arrhenius temp for upper boundary
Tpars=[ T_A T_L T_H T_AL T_AH];
  
b_A = .1; % 1/(M.s) spec binding rate of substrate A
b_B = .1; % 1/(M.s) spec binding rate of substrate B
k_A = .1; % 1/s     turnover rate of enzyme-substr A complex
k_B = .1; % 1/s     turnover rate of enzyme-substr B complex
k_C = .1; % 1/s     turnover rate of enzyme-prduct C complex
J_Cm = 1; % M/s     max production rate

