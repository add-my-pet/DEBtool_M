%% parscomp_st
% computes compound parameters from primary parameters

%%
function cPar = parscomp_st(p)
  % created 2013/07/08 by Bas Kooijman; modified 2015/01/17 Goncalo Marques
  % modified 2015/04/25 Starrlight, Bas Kooijman (kap_X_P replaced by kap_P)
  % modified 2015/08/03 by Starrlight, 2017/11/16, 2018/08/22 by Bas Kooijman, 
  % mod 2019/08/30 by Nina Marn (note on {p_Am})
  
  %% Syntax
  % cPar = <../parscomp_st.m *parscomp_st*> (par, chem)
  
  %% Description
  % Computes compound parameters from primary parameters that are frequently used
  %
  % Input
  %
  % * par : structure with parameters
  %  
  % Output
  %
  % * cPar : structure with scaled quantities and compound parameters
  
  %% Remarks
  % The quantities that are computed concern, where relevant:
  %
  % * p_Am: J/d.cm^2, {p_Am}, spec assimilation flux
  % * n_O, 4-4 matrix of chemical indices for water-free organics
  % * n_M,  4-4 matrix of chemical indices for minerals
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
  % * ome: -, \omega, contribution of ash free dry mass of reserve to total ash free dry biomass
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
  % * s_H: -, maturity ratio E_Hb/ E_Hp

if isfield(p,'p_Am') == 0
  p_Am = p.z * p.p_M/ p.kap;   % J/d.cm^2, {p_Am} spec assimilation flux; the expression for p_Am is multiplied also by L_m^ref = 1 cm, for units to match. 
else
  p_Am = p.p_Am;
end

%         X       V       E       P
n_O = [p.n_CX, p.n_CV, p.n_CE, p.n_CP;  % C/C, equals 1 by definition
       p.n_HX, p.n_HV, p.n_HE, p.n_HP;  % H/C  these values show that we consider dry-mass
       p.n_OX, p.n_OV, p.n_OE, p.n_OP;  % O/C
       p.n_NX, p.n_NV, p.n_NE, p.n_NP]; % N/C
        
%          C       H       O       N
n_M = [ p.n_CC, p.n_CH, p.n_CO, p.n_CN;  % CO2
        p.n_HC, p.n_HH, p.n_HO, p.n_HN;  % H2O  
        p.n_OC, p.n_OH, p.n_OO, p.n_ON;  % O2
        p.n_NC, p.n_NH, p.n_NO, p.n_NN]; % NH3
          
% -------------------------------------------------------------------------
% Molecular weights:
w_O = n_O' * [12; 1; 16; 14]; % g/mol, mol-weights for (unhydrated)  org. compounds
w_X = w_O(1);
w_V = w_O(2);
w_E = w_O(3);
w_P = w_O(4);

% -------------------------------------------------------------------------
% Conversions and compound parameters cPar
M_V     = p.d_V/ w_V;            % mol/cm^3, [M_V], volume-specific mass of structure
y_V_E   = p.mu_E * M_V/ p.E_G;     % mol/mol, yield of structure on reserve
y_E_V   = 1/ y_V_E;            % mol/mol, yield of reserve on structure
k_M     = p.p_M/ p.E_G;            % 1/d, somatic maintenance rate coefficient
k       = p.k_J/ k_M;            % -, maintenance ratio
E_m     = p_Am/ p.v;             % J/cm^3, [E_m], reserve capacity 
m_Em    = y_E_V * E_m / p.E_G;   % mol/mol, reserve capacity
g       = p.E_G/ p.kap/ E_m ;      % -, energy investment ratio
L_m     = p.v/ k_M/ g;           % cm, maximum length
L_T     = p.p_T/ p.p_M ;           % cm, heating length (also applies to osmotic work)
l_T     = L_T/ L_m;            % - , scaled heating length
ome     = m_Em * w_E * p.d_V/ p.d_E/ w_V; % -, \omega, contribution of ash free dry mass of reserve to total ash free dry biomass
w       = ome;                   % -, just for consistency with the past
J_E_Am  = p_Am/ p.mu_E;          % mol/d.cm^2, {J_EAm}, max surface-spec assimilation flux

if isfield(p, 'E_Hp')
  s_H     = p.E_Hb/ p.E_Hp;        % -, maturity ratio
else
  s_H = 1;
end

if isfield(p,'kap_X')
  y_E_X  = p.kap_X * p.mu_X/ p.mu_E;  % mol/mol, yield of reserve on food
  y_X_E  = 1/ y_E_X;            % mol/mol, yield of food on reserve
  p_Xm   = p_Am/ p.kap_X;         % J/d.cm^2, max spec feeding power
  J_X_Am = y_X_E * J_E_Am;      % mol/d.cm^2, {J_XAm}, max surface-spec feeding flux
end

if isfield(p,'kap_P')
  y_P_X  = p.kap_P * p.mu_X/ p.mu_P;  % mol/mol, yield of faeces on food 
  y_X_P  = 1/ y_P_X;            % mol/mol, yield of food on faeces
end

if isfield(p,'kap_X') && isfield(p,'kap_P')
  y_P_E  = y_P_X/ y_E_X;          % mol/mol, yield of faeces on reserve
  %  Mass-power couplers
  eta_XA = y_X_E/ p.mu_E;          % mol/J, food-assim energy coupler
  eta_PA = y_P_E/ p.mu_E;          % mol/J, faeces-assim energy coupler
  eta_VG = y_V_E/ p.mu_E;          % mol/J, struct-growth energy coupler
  eta_O  = [  -eta_XA   0         0;         % mol/J, mass-energy coupler
	                0   0         eta_VG;    % used in: J_O = eta_O * p
	           1/p.mu_E   -1/p.mu_E   -1/p.mu_E;
	           eta_PA   0         0]; 
end

J_E_M   = p.p_M/ p.mu_E;          % mol/d.cm^3, [J_EM], volume-spec somatic  maint costs
J_E_T   = p.p_T/ p.mu_E;          % mol/d.cm^2, {J_ET}, surface-spec somatic  maint costs
j_E_M   = k_M * y_E_V;            % mol/d.mol, mass-spec somatic  maint costs
j_E_J   = p.k_J * y_E_V;          % mol/d.mol, mass-spec maturity maint costs
kap_G   = p.mu_V * M_V/ p.E_G;    % -, growth efficiency
E_V     = p.d_V * p.mu_V/ w_V;    % J/cm^3, [E_V] volume-specific energy of structure

if isfield(p,'F_m')
  K = J_X_Am/ p.F_m;        % c-mol X/l, half-saturation coefficient
end

if isfield(p,'E_Rj')
  v_Rj = p.kap/ (1 - p.kap) * p.E_Rj/ p.E_G;
end

% -------------------------------------------------------------------------
% pack output:
cPar = struct('p_Am', p_Am, 'w_X', w_X, 'w_V', w_V, 'w_E', w_E, 'w_P', w_P, 'M_V', M_V, 'y_V_E', y_V_E, 'y_E_V', y_E_V, ...
              'k_M', k_M, 'k', k, 'E_m', E_m, 'm_Em', m_Em, 'g', g, 'L_m', L_m, 'L_T', L_T, 'l_T', l_T, 'ome', ome, 'w', w, 's_H', s_H, ...
              'J_E_Am', J_E_Am, 'J_E_M', J_E_M, 'J_E_T', J_E_T, 'j_E_M', j_E_M, 'j_E_J', j_E_J, 'kap_G', kap_G, 'E_V', E_V, 'n_O', n_O, 'n_M', n_M);

% -------------------------------------------------------------------------
% add the Scaled maturity maturity levels:
parNames = fields(p);
matLev = parNames(strncmp(parNames, 'E_H', 3));
matInd = strrep(matLev, 'E_H', '');  % maturity levels' indices
          
for i = 1:length(matInd)
  stri = matInd{i};
  cPar.(['M_H', stri]) = p.(['E_H', stri])/ p.mu_E;                 % mmol, maturity at level i
  cPar.(['U_H', stri]) = p.(['E_H', stri])/ p_Am;                   % cm^2 d, scaled maturity at level i
  cPar.(['V_H', stri]) = cPar.(['U_H', stri])/ (1 - p.kap);         % cm^2 d, scaled maturity at level i
  cPar.(['v_H', stri]) = cPar.(['V_H', stri]) * g^2 * k_M^3/ p.v^2; % -, scaled maturity density at level i
  cPar.(['u_H', stri]) = cPar.(['U_H', stri]) * g^2 * k_M^3/ p.v^2; % -, scaled maturity density at level i 
end          
          
if isfield(p,'kap_P')
  cPar.y_P_X = y_P_X;
  cPar.y_X_P = y_X_P;  
end

if isfield(p,'kap_X')
  cPar.y_E_X = y_E_X;
  cPar.y_X_E = y_X_E;  
  cPar.p_Xm = p_Xm;
  cPar.J_X_Am = J_X_Am;  
end

if isfield(p,'kap_X') && isfield(p,'kap_P')
  cPar.y_P_E = y_P_E;
  cPar.eta_XA = eta_XA;  
  cPar.eta_PA = eta_PA;
  cPar.eta_VG = eta_VG;  
  cPar.eta_O = eta_O;  
end

if isfield(p,'F_m') 
  cPar.K = K;
end

if isfield(p,'E_Rj')
  cPar.v_Rj = v_Rj;
end
