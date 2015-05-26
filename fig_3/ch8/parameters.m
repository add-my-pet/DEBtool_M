%% Table 8.1: parameters
%% typical parameter values of the standard DEB model at 20 C
%% Lm = 1 cm

% setpath % path to DEBtool

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
  
p_Xm = p_Am/ kap_X;   % J cm^-2 d^-1
J_XAm = J_EAm/ y_EX;  % mmol cm^-2 d^-1
K = J_EAm/ y_EX/ F_m; % mmol l^-1 = mM

k_M = p_M/ E_G; k = k_J/ k_M; % d^-1
E_m = p_Am/ v;     % J cm^-3
g = E_G/ kap/ E_m; % -
L_m = v/ k_M/ g;   % cm
L_T = p_T/ p_M;    % cm
l_T = L_T/ L_m;    % -

U_Hb = 1E-6 * M_Hb/ J_EAm; % cm^2 d
V_Hb = U_Hb/ (1 - kap);    % cm^2 d
v_Hb = V_Hb * g^2 * k_M^3/ v^2; % -
U_Hp = M_Hp/ J_EAm;        % cm^2 d
V_Hp = U_Hp/ (1 - kap);    % cm^2 d
v_Hp = V_Hp * g^2 * k_M^3/ v^2; % -

p_b = [V_Hb; g; k_J; k_M; v];
U_E0 = initial_scaled_reserve(1, p_b); % cm^2 d

[t_p t_b l_p l_b info] = get_tp([g; k; l_T; v_Hb; v_Hp],1);
a_b = t_b/ k_M;  % d
a_p = t_p/ k_M;  % d
L_b = L_m * l_b; % cm
L_p = L_m * l_p; % cm
U_Eb = E_m * L_b^3/ p_Am;

p_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp];
R_m = reprod_rate(L_m, 1, p_R); % d^-1

eb_min = get_eb_min([g; k; v_Hb]);
ep_min = get_ep_min([g; k; l_T; v_Hb; v_Hp]);

txt = {'max feeding rate, mmol cm^-2 d^-1';
       'half-saturation coeff, mM';
       'frac. reserve left at birth';
       'age at birth, d';
       'age at puberty, d';
       'length at birth, cm';
       'length at puberty, cm';
       'max length, cm';
       'max reproduction rate, d^-1';
       'func response for growth ceasing at birth';
       'func response for maturation ceasing at birth';
       'func response for growth ceasing at puberty';
       'func response for maturation ceasing at puberty'};

res = [J_XAm; % max feeding rate
       K; % half-saturation coeff
       U_Eb/ U_E0; % fraction of reserve left at birth
       a_b; % age at birth
       a_p; % age at puberty
       L_b; % length at birth
       L_p; % length at puberty
       L_m; % max length
       R_m; % max reprod rate
       eb_min(1); % func response for growth ceases at birth
       eb_min(2); % func response for maturation ceases at birth
       ep_min(1); % func response for growth ceases at puberty
       ep_min(2)]; % func response for maturation ceases at puberty

printpar(txt,res)








