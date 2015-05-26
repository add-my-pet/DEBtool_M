%% created 2002/04/09 by Bas Kooijman, modified 2014/03/12
% script for 'pars_animal', called from 'animal'; See: Kooijman 2010
% run pars_animal (or pars_my_pet) before running this script
% calculates compound parameters that are used by other routines
% no reproduction buffer handling rules are specified
%    this buffer is excluded from the calculations below

%% conversion coefficients

% molecular weights
w_O = n_O' * [12; 1; 16; 14];    % g/mol, mol-weights for org. compounds
w_V = w_O(2); 

% specific densities
d_V = d_O(2);                    % g/cm^3, specific density of structure
M_V = d_V/ w_V;                  % mol/cm^3, [M_V] volume-specific mass of structure
% notice that "volume" in [M_V] relates to wet volume, while "mass" relates to dry mass
% so for volume to mol: M_V = [M_V] * V;
% or for volume to weight: W_V = w_V * M_V = d_V * V
E_V = d_V * mu_V/ w_V;           % J/cm^3, [E_V] volume-specific energy of structure

% yield coefficients
y_E_X = kap_X * mu_X/ mu_E;      % mol/mol, yield of reserve on food
y_X_E = 1/ y_E_X;                % mol/mol, yield of food on reserve
y_V_E = mu_E * M_V/ E_G;         % mol/mol, yield of structure on reserve
y_E_V = 1/ y_V_E;                % mol/mol, yield of reserve on structure
y_P_X = kap_X_P * mu_X/ mu_P;    % mol/mol, yield of faeces on food 
y_X_P = 1/ y_P_X;                % mol/mol, yield of food on faeces
y_P_E = y_P_X/ y_E_X;            % mol/mol, yield of faeces on reserve

% mass-power couplers
eta_XA = y_X_E/mu_E;             % mol/J, food-assim energy coupler
eta_PA = y_P_E/mu_E;             % mol/J, faeces-assim energy coupler
eta_VG = y_V_E/mu_E;             % mol/J, struct-growth energy coupler
eta_O = [-eta_XA  0        0;    % mol/J, mass-energy coupler
	      0       0   eta_VG;    %         used in: J_O = eta_O * p
	 1/mu_E  -1/mu_E -1/mu_E;
	      eta_PA  0        0];
      
%% compound parameters before metamorphosis, if present

L_m_ref = 1;                   % cm, reference length
p_Am = z * p_M * L_m_ref/ kap; % J/d.cm^2, {p_Am} spec assimilation flux
p_Xm = p_Am/ kap_X;            % J/d.cm^2, max spec feeding power

k_M = p_M/ E_G;                % 1/d, somatic maintenance rate coefficient
k = k_J/ k_M;                  % -, maintenance ratio

E_m = p_Am/ v;                 % J/cm^3, reserve capacity [E_m]
m_Em = y_E_V * E_m/ E_G;       % mol/mol, reserve capacity 
g = E_G/ kap/ E_m;             % -, energy investment ratio
kap_G = mu_V * M_V/ E_G;       % -, growth efficieny
%  energy fixed in structure relative to energy invested in structure

L_m = kap * p_Am/ p_M;         % cm, maximum length 
L_T = p_T/ p_M;                % cm, heating length (also applies to osmotic work)
l_T = L_T/ L_m;                % -, scaled heating length

%% correct primary rates for temperature difference relative to reference
TC = tempcorr(T,T_ref,pars_T);   % -, Temperature Correction factor

FT_m = TC * F_m;                 % L/d.cm^2, {F_m} max spec searching rate
pT_Xm = TC * p_Xm;               % J/d.cm^2, temp corrected spec feeding rate
pT_Am = TC * p_Am;               % J/d.cm^2, temp corrected spec assimilation rate
vT = TC * v;                     % cm/d, temp corrected energy conductance 
kT_M = TC * k_M;                 % 1/d, temp corrected somatic maintenance rate coefficient
pT_M = TC * p_M;                 % J/d.cm^3, temp corrected vol-specific som maint costs
pT_T = TC * p_T;                 % J/d.cm^2, temp corrected sur-specific som maint costs
kT_J = TC * k_J;                 % 1/d, temp corrected mat maint rate coefficient
hT_a = TC * TC * h_a;            % 1/d^2, temp corrected aging acceleration

%% life stage parameters
% metamorphosis occurs in bivalves, many fish and some crustations, see KooyPecq2011
%   embryos, late juveniles and adults: isomorphs
%   early juveniles are V1-morphs; {p_Am} and v increase propto L
% theory presented in subsection 7.8.2 of Kooy2010

if exist('E_Hj','var') == 0 % maturity at metamorphosis
  E_Hj = [];        % actually means: no metamorphosis, no V1-stage, no acceleration
end
if isempty(E_Hj)
  E_Hj = E_Hb;      % actually means: no metamorphosis, no V1-stage, no acceleration
end

% M_H is the cumulated mass of reserve invested in maturation
% maturity at birth
M_Hb = E_Hb/ mu_E;               % mol, maturity at birth  
U_Hb = E_Hb/ pT_Am;              % cm^2 d, scaled maturity at birth
u_Hb = U_Hb * g^2 * kT_M^3/ vT^2;% -, scaled maturity at birth
V_Hb = U_Hb/ (1 - kap);          % cm^2 d, scaled maturity at birth
v_Hb = V_Hb * g^2 * kT_M^3/ vT^2;% -, scaled maturity at birth
% maturity at metamorphosis
M_Hj = E_Hj/ mu_E;               % mol, maturity at metamorphosis  
U_Hj = E_Hj/ pT_Am;              % cm^2 d, scaled maturity at metamorphosis
u_Hj = U_Hj * g^2 * kT_M^3/ vT^2;% -, scaled maturity at metamorphosis
V_Hj = U_Hj/ (1 - kap);          % cm^2 d, scaled maturity at metamorphosis
v_Hj = V_Hj * g^2 * kT_M^3/ vT^2;% -, scaled maturity at metamorphosis
% maturity at puberty
M_Hp = E_Hp/ mu_E;               % mol, maturity at puberty
U_Hp = E_Hp/ pT_Am;              % cm^2 d, scaled maturity at puberty 
u_Hp = U_Hp * g^2 * kT_M^3/ vT^2;% -, scaled maturity at puberty
V_Hp = U_Hp/ (1 - kap);          % cm^2 d, scaled maturity at puberty
v_Hp = V_Hp * g^2 * kT_M^3/ vT^2;% -, scaled maturity at puberty

%% compound parameters II

if E_Hj == E_Hb % no metamorphosis, f = 1
  pars_tp = [g; k; l_T; v_Hb; v_Hp]; % parameters for get_tp
  [t_p t_b l_p l_b info] = get_tp(pars_tp, 1); % -, scaled age at puberty
  if info ~= 1              
    fprintf('warning in get_tp: invalid parameter value combination for t_p \n')
  end
  l_j = l_b;                         % scaled length at metamorphosis
  t_j = t_b;                         % scaled age at metamorphosis
  l_i = 1 - l_T;                     % scaled ultimate length 
  s_M = 1; % -, acceleration factor
else % metamorphosis, f = 1
  % notice that L_m relates to the embryo-values
  pars_tj = [g; k; l_T; v_Hb; v_Hj; v_Hp]; % parameters for get_tj
  [t_j t_p t_b l_j l_p l_b l_i r_j r_B info] = get_tj(pars_tj, 1); 
  if info ~= 1
    fprintf('warning in get_tj: invalid parameter value combination for t_j \n')
  end  
  s_M = l_j/ l_j; % -, acceleration factor at f = 1; will be overwritten by statistics
end
s_H = log10(E_Hp/ E_Hb);             % -, altriciality index s_H^pb

% dry weight at f = 1
L_i = s_M * L_m; % cm, ultimate length at f = 1, will be overwitten by statistics
W_m = L_i^3 * d_O(2)* (1 + m_Em * w_O(3)/ w_O(2)); % g, maximum dry weight

del_V = 1/(1 + f * m_Em * w_O(3)/ w_O(2)); % -, fraction of max weight that is structure
M_Vm = L_i^3 * d_O(2)/ w_O(2);       % mol, max struc mass
M_Em = m_Em * M_Vm;                  % mol, max reserve mass

t_E = L_m/ vT;                       % d, maximum reserve residence time
t_starve = E_m/ pT_M;                % d, max survival time when starved

%% fluxes and half sat coeff, post metamorphosis

JT_E_Am = pT_Am/ mu_E * s_M;     % mol/d.cm^2, {J_EAm}, max surface-spec assimilation flux
JT_X_Am = y_X_E * JT_E_Am;       % mol/d.cm^2, {J_XAm}, max surface-spec feeding flux
jT_E_Am = JT_E_Am * L_m^2/ M_Vm; % mol/d.mol, j_EAm,  mass-spec max assim flux
jT_X_Am = y_X_E * jT_E_Am;       % mol/d.mol, j_XAm, mass-spec max feeding flux 
K = JT_X_Am/ FT_m;               % M, half-saturation coefficient

JT_E_M = pT_M/ mu_E;             % mol/d.cm^3, [J_EM]
JT_E_T = pT_T/ mu_E;             % mol/d.cm^2, {J_ET}
jT_E_M = kT_M * y_E_V;           % mol/d.mol, spec somatic  maint costs
jT_E_J = kT_J * y_E_V;           % mol/d.mol, spec maturity maint costs

pp_M = kT_M * y_E_V * mu_E * d_O(2)/ w_O(2); % J/d.cm^3 spec somatic maint costs
pp_T = L_T * pp_M;                           % J/d.cm^2 spec heating costs
