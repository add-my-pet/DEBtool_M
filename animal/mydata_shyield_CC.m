% illustrates use of shyield_CC: yield of dissipating CO2 on mobilisation

%% see Table 8.1 of DEB3 for par-setting

z = 1; % zoom factor rel to reference L_m = 1 cm
mu_E = 550; % kJ mol^{-1} = J mmol^{-1}
M_V = 4; % mmol cm^{-3}

F_m = 6.5; % l cm^{-2} d^{-1}, {F_m}
kap_X = 0.8;
  y_EX = kap_X; % mol mol^{-1}
p_Am = 22.5 * z; % J cm^{-2} d^{-1}, {p_Am}
  J_EAm = p_Am/ mu_E; % mmol\,cm^{-2} d^{-1}, {J_EAm}
v = 0.02; % cm d^{-1}
kap = 0.8;
kap_R = 0.95;
p_M = 18; % J cm^{-3} d^{-1}, [p_M]
  J_EM = p_M/ mu_E; % mmol cm^{-3} d^{-1}, [J_EM]
p_T =  0; % J cm^{-2} d^{-1}, {p_T}
  J_ET = p_T/ mu_E; % mol cm^{-2} d^{-1}, {J_ET}
k_J = 0.002; % d^{-1} < k_M
E_G = 2800; % J cm^{-3}, [E_G]
  y_VE = 1/ (E_G/ M_V/ mu_E); % mol mol^{-1}
E_Hb = 275 * z^3; % mJ, E_H^b
  M_Hb = E_Hb/ mu_E; % nmol
E_Hp = .3 * 166 * z^3; % J, E_H^p 
  M_Hp = E_Hp/ mu_E; % mmol

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
k_M = p_M/ E_G; k = k_J/ k_M; % d^-1
E_m = p_Am/ v;     % J cm^-3
g = E_G/ kap/ E_m; % -
L_m = v/ k_M/ g;   % cm
L_T = p_T/ p_M;    % cm

U_Hb = 1E-6 * M_Hb/ J_EAm; % cm^2 d
U_Hp = M_Hp/ J_EAm;        % cm^2 d

par = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp; y_VE];
shyield_CC(par)