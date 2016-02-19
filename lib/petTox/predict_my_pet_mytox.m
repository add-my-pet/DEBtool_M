%% predict_my_pet_mytox
% Obtains predictions with toxicant, using parameters and data

%%
function [prdData, info] = predict_my_pet_mytox(par, data, auxData)
  
  %% Syntax
  % [prdData, info] = <../predict_my_pet_mytox.m *predict_my_pet_mytox*>(par, data, auxData)
  
  %% Description
  % Obtains predictions, using parameters and data
  %
  % Input
  %
  % * par: structure with parameters (see below)
  % * data: structure with data (not all elements are used)
  % * auxData : structure with temp data and other potential environmental data
  %  
  % Output
  %
  % * prdData: structure with predicted values for data
  % * info: identified for correct setting of predictions (see remarks)
  
  %% Remarks
  % Template for use in DEBtool/lib/petTox.
  % The code calls <parscomp_st.html *parscomp_st*> in order to compute
  % scaled quantities, compound parameters, molecular weights and compose
  % matrixes of mass to energy couplers and chemical indices.
  % With the use of filters, setting info = 0, prdData = {}, return, has the effect
  % that the parameter-combination is not selected for finding the
  % best-fitting combination; this setting acts as customized filter.
  
  %% Example of a costumized filter
  % See the lines just below unpacking
  
  % unpack par, data, auxData
  cPar = parscomp_st(par); vars_pull(par); 
  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);
    
  % customized filters for allowable parameters of the standard DEB model (std)
  % for other models consult the appropriate filter function.
  filterChecks = k * v_Hp >= f_tN^3 || ~reach_birth(g, k, v_Hb, f_tN);         % constraint required for reaching puberty, birth with f_tN
  
  if filterChecks  
    info = 0;  prdData = {};     return;
  end  
  
  % compute temperature correction factors
  TC_tN = tempcorr(temp.tN0, T_ref, T_A);

% zero-variate data

%   % life cycle
%   pars_tp = [g; k; l_T; v_Hb; v_Hp];               % compose parameter vector
%   [t_p, t_b, l_p, l_b, info] = get_tp(pars_tp, f); % -, scaled times & lengths at f
%   
%   % life span
%   pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
%   t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
%   aT_m = t_m/ k_M/ TC_am;               % d, mean life span at T
%   
%   % pack to output
%   % the names of the fields in the structure must be the same as the data names in the mydata file
%   prdData.am = aT_m;
  
  % uni-variate data
  
  % time-cumulated nb of eggs
  
L0 = L0.tN0 * del_M; % initial structural length   
UH0 = maturity(L0, f, [kap; kap_R; g; k_J; k_M; 0; v; E_Hb/ p_Am; E_Hp/ p_Am]); % initial scaled maturity
UT_H0 = UH0/ TC_tN;
 % initial
pars_UE0 = [V_Hb; g; k_J; k_M; v]; % compose parameter vector
U_E0 = initial_scaled_reserve(f, pars_UE0); % d.cm^2, initial scaled reserve 
UT_E0 = U_E0/ TC_tN;
  
X0 = [0;UT_H0; L0; UT_E0; 0]; % initial conditons

[t, Xt] = ode23(@dharep, tN0(:,1), X0,[],par, cPar, tox.tN0, f_tN, U_E0, TC_tN); % integrate changes in state
EN0 = Xt(:,1); % select cumulated number of offspring

[t, Xt] = ode23(@dharep, tN1(:,1), X0,[],par, cPar, tox.tN1, f_tN, U_E0, TC_tN); % integrate changes in state
EN1 = Xt(:,1); % select cumulated number of offspring

[t, Xt] = ode23(@dharep, tN2(:,1), X0,[],par, cPar, tox.tN2, f_tN, U_E0, TC_tN); % integrate changes in state
EN2 = Xt(:,1); % select cumulated number of offspring

[t, Xt] = ode23(@dharep, tN3(:,1), X0,[],par, cPar, tox.tN3, f_tN, U_E0, TC_tN); % integrate changes in state
EN3 = Xt(:,1); % select cumulated number of offspring

[t, Xt] = ode23(@dharep, tN4(:,1), X0,[],par, cPar, tox.tN4, f_tN, U_E0, TC_tN); % integrate changes in state
EN4 = Xt(:,1); % select cumulated number of offspring

[t, Xt] = ode23(@dharep, tN5(:,1), X0,[],par, cPar, tox.tN5, f_tN, U_E0, TC_tN); % integrate changes in state
EN5 = Xt(:,1); % select cumulated number of offspring


  % pack to output
  % the names of the fields in the structure must be the same as the data names in the mydata file
  prdData.tN0 = EN0;
  prdData.tN1 = EN1;
  prdData.tN2 = EN2;
  prdData.tN3 = EN3;
  prdData.tN4 = EN4;
  prdData.tN5 = EN5;

  
  
  function dX = dharep(t, X, p, c, C, f, U0, TC)
  %  created 2002/01/20 by Bas Kooijman, modified 2007/07/12
  %
  %  routine called by harep
  %  hazard effects on offpsring of ectotherm: target is hazard rate
  %
  %% Input
  %  t: exposure time (not used)
  %  X: (5 * nc,1) vector with state variables (see below)
  %
  %% Ouput
  %  dX: derivatives of state variables

%   global C nc c0 cH ke kap kapR g kJ kM v Hb Hp U0 f

  %% unpack state vector
%   N = X(1);        % cumulative number of offspring
  H = X(2);   % scaled maturity H = M_H/ {J_EAm}
  L = X(3); % length
  U = X(4); % scaled reserve U = M_E/ {J_EAm}
  conc = X(5); % scaled internal concentration
  
  s = max(0,(conc - p.c0)/ p.cA);    % stress factor

  kT_M = c.k_M * TC;  kT_e = p.k_e * TC; kT_J = p.k_J * TC;
  UT_0 = U0/ TC;
  
  E = U * p.v ./ L .^ 3;        % scaled reserve density e = m_E/m_Em (dim-less)
  %% again we scale with respect to m_Em = {J_EAm}/ (v [M_V]) of the blanc

  eg = E .* c.g ./ (E + c.g);     % in DEB notation: e g/ (e + g)
  SC = L .^ 2 .* eg .* (1 + L ./ (c.g .* c.L_m)); % SC = J_EC/{J_EAm}

  rB = kT_M * c.g ./ (3 * (E + c.g)); % von Bert growth rate
  dL = rB .* (E .* c.L_m - L);   % change in length
  dU = f * L .^ 2 - SC;           % change in time-surface U = M_E/{J_EAm}
  dconc = (kT_e * c.L_m .* (C - conc) - 3 * dL .* conc) ./ L; % change in scaled int. conc

  R = exp(-s) .* ((1 - p.kap) * SC - kT_J * p.E_Hp) * p.kap_R/ UT_0; % reprod rate in %/d
  R = (H > Hp) .* max(0,R); % make sure that R is non-negative
  dH = (1 - p.kap) * SC - kT_J * H; % change in scaled maturity H = M_H/ {J_EAm}
  dX = [R; dH; dL; dU; dconc]; % catenate derivatives in output
  
  
  
  