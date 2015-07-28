%% parscomp_st
% computes compound parameters from primary parameters

%%
function cp = parscomp_st(par, chem)
  % created 2013/07/08 by Bas Kooijman; modified 2015/01/17 Goncalo Marques
  % modified 2015/04/25 Starrlight, Bas Kooijman (kap_X_P replaced by kap_P)
  
  %% Syntax
  % cp = <../parscomp_st.m *parscomp_st*> (par, chem)
  
  %% Description
  % Computes compound parameters from primary parameters that are frequently used
  %
  % Input
  %
  % * par : structure with values of primary parameters
  % * chem : structure with values of chemical indices
  %  
  % Output
  %
  % * cp : structure with scaled quantities and compound parameters
  
  %% Remarks
  % The quantities that are computed concern, where relevant:
  %
  % * p_Am: J/d.cm^2, {p_Am}, spec assimilation flux
  % * w_O, w_X, w_V, w_E, w_P: g/mol, mol-weights for (unhydrated)  org. compounds
  % * M_V: mol/cm^3, [M_V], volume-specific mass of structure
  % * y_V_E: mol/mol, yield of structure on reserve
  % * y_E_V: mol/mol, yield of reserve on structure
  % * k_M: 1/d, somatic maintenance rate coefficient
  % * k: -, maintenance ratio
  % * E_m: J/cm^3, [E_m], reserve capacity 
  % * m_Em: mol/mol, reserve capacity
  % * g: -, energy investment ratio
  % * L_m: cm, maximum length
  % * L_T: cm, heating length (also applies to osmotic work)
  % * l_T: - , scaled heating length
  % * w: -, \omega, contribution of ash free dry mass of reserve to total ash free dry biomass
  % * J_E_Am: mol/d.cm^2, {J_EAm}, max surface-spec assimilation flux
  % * y_E_X: mol/mol, yield of reserve on food
  % * y_X_E: mol/mol, yield of food on reserve
  % * p_Xm: J/d.cm^2, max spec feeding power
  % * J_X_Am: mol/d.cm^2, {J_XAm}, max surface-spec feeding flux
  % * y_P_X: mol/mol, yield of faeces on food 
  % * y_X_P: mol/mol, yield of food on faeces
  % * y_P_E: mol/mol, yield of faeces on reserve
  % * eta_XA, eta_PA, eta_VG; eta_O: mol/J, mass-power couplers
  % * J_E_M: mol/d.cm^3, [J_EM], vol-spec somatic  maint costs
  % * J_E_T: mol/d.cm^2, {J_ET}, surface-spec somatic  maint costs
  % * j_E_M: mol/d.mol, mass-spec somatic  maint costs
  % * j_E_J: mol/d.mol, mass-spec maturity maint costs
  % * kap_G: -, growth efficiency
  % * E_V: J/cm^3, [E_V], volume-specific energy of structure
  % * K: c-mol X/l, half-saturation coefficient
  % * M_H*, U_H*, V_H*, v_H*, u_H*: scaled maturities computed from all unscaled ones: E_H*

v2struct(par); v2struct(chem); % convert structures to variables

if ~exist('p_Am','var')
  p_Am = z * p_M/ kap;        % J/d.cm^2, {p_Am} spec assimilation flux
end

% -------------------------------------------------------------------------
% Molecular weights:
w_O = n_O' * [12; 1; 16; 14]; % g/mol, mol-weights for (unhydrated)  org. compounds
w_X = w_O(1);
w_V = w_O(2);
w_E = w_O(3);
w_P = w_O(4);

% -------------------------------------------------------------------------
% Conversions and compound parameters cp

M_V     = d_V/ w_V;            % mol/cm^3, [M_V], volume-specific mass of structure
y_V_E   = mu_E * M_V/ E_G;     % mol/mol, yield of structure on reserve
y_E_V   = 1/ y_V_E;            % mol/mol, yield of reserve on structure
k_M     = p_M/ E_G;            % 1/d, somatic maintenance rate coefficient
k       = k_J/ k_M;            % -, maintenance ratio
E_m     = p_Am/ v;             % J/cm^3, [E_m], reserve capacity 
m_Em    = y_E_V * E_m / E_G;   % mol/mol, reserve capacity
g       = E_G/ kap/ E_m ;      % -, energy investment ratio
L_m     = v/ k_M/ g;           % cm, maximum length
L_T     = p_T/ p_M ;           % cm, heating length (also applies to osmotic work)
l_T     = L_T/ L_m;            % - , scaled heating length
w       = m_Em * w_E * d_E/ d_V/ w_V; % -, \omega, contribution of ash free dry mass of reserve to total ash free dry biomass
J_E_Am  = p_Am/ mu_E;          % mol/d.cm^2, {J_EAm}, max surface-spec assimilation flux

if exist('kap_X', 'var') == 1
y_E_X   = kap_X * mu_X/ mu_E;  % mol/mol, yield of reserve on food
y_X_E   = 1/ y_E_X;            % mol/mol, yield of food on reserve
p_Xm    = p_Am/ kap_X;         % J/d.cm^2, max spec feeding power
J_X_Am  = y_X_E * J_E_Am;      % mol/d.cm^2, {J_XAm}, max surface-spec feeding flux
end

if exist('kap_P', 'var') == 1
y_P_X   = kap_P * mu_X/ mu_P;  % mol/mol, yield of faeces on food 
y_X_P   = 1/ y_P_X;            % mol/mol, yield of food on faeces
end

if exist('kap_P', 'var') == 1 && exist('kap_X', 'var') == 1
y_P_E   = y_P_X/ y_E_X;          % mol/mol, yield of faeces on reserve
%  Mass-power couplers
  eta_XA = y_X_E/ mu_E;          % mol/J, food-assim energy coupler
  eta_PA = y_P_E/ mu_E;          % mol/J, faeces-assim energy coupler
  eta_VG = y_V_E/ mu_E;          % mol/J, struct-growth energy coupler
  eta_O = [  -eta_XA   0         0;         % mol/J, mass-energy coupler
	               0   0         eta_VG;    % used in: J_O = eta_O * p
	          1/mu_E   -1/mu_E   -1/mu_E;
	          eta_PA   0         0]; 
end

J_E_M   = p_M/ mu_E;          % mol/d.cm^3, [J_EM], volume-spec somatic  maint costs
J_E_T   = p_T/ mu_E;          % mol/d.cm^2, {J_ET}, surface-spec somatic  maint costs
j_E_M   = k_M * y_E_V;        % mol/d.mol, mass-spec somatic  maint costs
j_E_J   = k_J * y_E_V;        % mol/d.mol, mass-spec maturity maint costs
kap_G   = mu_V * M_V/ E_G;    % -, growth efficiency
E_V     = d_V * mu_V/ w_V;    % J/cm^3, [E_V] volume-specific energy of structure

if exist('F_m', 'var') == 1
K       = J_X_Am/ F_m;        % c-mol X/l, half-saturation coefficient
end

% -------------------------------------------------------------------------
% Scaled maturity

par_names = fields(par);
mat_lev = par_names(strncmp(par_names, 'E_H', 3));
mat_ind = strrep(mat_lev, 'E_H', '');  % maturity levels' indices

for i = 1:length(mat_ind)
  stri = mat_ind{i};
  eval(['M_H', stri, '= E_H', stri, '/ mu_E;']);              % mmol, maturity at level i
  eval(['U_H', stri, '= E_H', stri, '/ p_Am;']);              % cm^2 d, scaled maturity at level i
  eval(['V_H', stri, '= U_H', stri, '/ (1 - kap);']);         % cm^2 d, scaled maturity at level i
  eval(['v_H', stri, '= V_H', stri, '* g^2 * k_M^3/ v^2;']);  % -, scaled maturity density at level i
  eval(['u_H', stri, '= U_H', stri, '* g^2 * k_M^3/ v^2;']);  % -, scaled maturity density at level i
end

% -------------------------------------------------------------------------
% pack output:

cp = v2struct(p_Am, w_X, w_V, w_E, w_P, M_V, y_V_E, y_E_V, ...
    k_M, k, E_m, m_Em, g, L_m, L_T, l_T, w, ...
    J_E_Am, J_E_M, J_E_T, j_E_M, j_E_J, kap_G, E_V);

nameOfStruct2Update = 'cp';

for i = 1:length(mat_ind)
  stri = mat_ind{i};
  eval(['cp = v2struct(M_H', stri, ', U_H', stri, ', V_H', stri, ', v_H', stri, ', u_H', stri, ', nameOfStruct2Update);']);
end

if exist('kap_P', 'var') == 1
    cp = v2struct(y_P_X, y_X_P, nameOfStruct2Update);
end

if exist('kap_X', 'var') == 1
    cp = v2struct(y_E_X, y_X_E, p_Xm, J_X_Am, nameOfStruct2Update);
end

if exist('kap_P', 'var') == 1 && exist('kap_X', 'var') == 1
    cp = v2struct(y_P_E, eta_XA, eta_PA, eta_VG, eta_O, nameOfStruct2Update);
end

if exist('F_m', 'var') == 1
    cp = v2struct(K, nameOfStruct2Update);                          
end
