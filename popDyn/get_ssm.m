%% get_ssm
% get trajectories of semi structured model for a generalized reactor

%%
function tNL23W = get_ssm(model, par, tT, tJX, x_0, V_X, t_max)
% created 2020/05/08 by Bas Kooijman
  
%% Syntax
% tNL23W = <../get_ssm.m *get_ssm*> (model, par, tT, tJX, x_0, V_X, t_max)
  
%% Description
% integrates numbers, length, weights in semi structured model, called by ssm, 
%
% Input:
%
% * model: character-string with name of model
% * par: structure with parameter values
% * tT: (nT,2)-array with time and temperature in Kelvin; time between 0 (= start) and t_max
% * tJX: (nX,2)-array with time and food supply; time between 0 (= start) and t_max
% * x_0: scalar with scaled initial food density 
% * V_X: scalar with volume of reactor
% * t_max: max time to be simulated
%
% Output:
%
% * txNL23W: (n,7)-array with times, scaled food density and densities of number of individuals, total length, surface area, volume, weight

%% Remarks
% The model is described in section 9.2.2.5 of the comments on DEB3.
  
  % unpack par and compute compound pars
  vars_pull(par); vars_pull(parscomp_st(par));  
  
  % temperature correction
  par_T = T_A;
  if exist('T_L','var') && exist('T_AL','var')
    par_T = [T_A; T_L; T_AL];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    par_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  % unscale knots for temperature, and convert to temp correction factors
  if length(tT) == 1
     TC = tempcorr(tT, T_ref, par_T); tTC = TC; % Temperature Correction factor
  else
     tTC = [tT(:,1) * t_R, tempcorr(tT(:,2), T_ref, par_T)]; TC = tTC(1,2); % Temperature Correction factor
  end
  % unscale knots for food density in supply flux
  if length(tJX) == 1
     tkX = tJX/ V_X/ K; % scaled food input
  else
     tkX = [tJX(:,1), tJX(:,2)/ V_X/ K]; %
  end

  switch model
    case {'stf','stx'}
      u_E0 = get_u_E0([g, k, v_Hb], 1);
    otherwise
      u_E0 = get_u_E0_foetus([g, k, v_Hb], 1);
  end
  switch model
    case {'std','stx','stf','ssj','sbp'}
      pars_tp = [g k 0 v_Hb v_Hp]; 
    case 'abj'
      pars_tp = [g k 0 v_Hb v_Hj v_Hp]; 
  end 
  k_R = kap_R * (1 - kap) * k_M/ u_E0;
  
  options = odeset('AbsTol',1e-8, 'RelTol',1e-8);
  xNLW_0 = [x_0; 1; 0; 0; L_b/2, 0, 0, L_b^3 * ( 1 + ome), 0, 0]; % x N_0b N_bp N_pi L_0b, L_bp, L_pi, W_0b, W_bp, W_pi
  [t, xNLW] = ode45(@dssm, [0; t_max], xNLW_0, options, model, tTC, tkX, J_XAm/ K, pars_tp, h_B, h_D, h_a, s_G, k_R, k_M, g, k*v_HP, L_m, ome);
  tNL23W = [t, xNLW(:,1), sum(xNLW(:,2:4),2), sum(xNLW(:,5:7),2), sum(xNLW(8:11),2)];    
end

function dxNLW = dssm(t, xNLW, model, tTC, tkX, F_Xm, pars_tp, h_B, h_D, h_a, s_G, k_R, k_M, g, kv_Hp, L_m, ome)
  x = xNLW(1); f = x/ (1 + x); N_0b = xNLW(2); N_bp = xNLW(3); N_pi = xNLW(4);       
        
  if length(tJX) == 1
    k_X = tkX;
  else
    k_X = spline1(t, tkX); % food supply flux: J_XI/ V_X/ K
  end
  if length(tTC) == 1
    TC = tTC;
  else
    TC = spline1(t, tTC); % temperature correction factor
  end
  
  kT_M = k_M * TC; h3_W = TC^3 * h_a * k_M * g/ 6; h_W = h3_W^(1/3); h_G = kT_M * g * s_G * f^3; h_Gb = h_G * a_b; h_Gp = h_G * a_p;
  S_b = exp(6 * h3_W/ h_G^3 * (1 - exp(h_Gb) + h_Gb * (1  + h_Gb/ 2)- h_B * a_b));
  S_p = exp(6 * h3_W/ h_G^3 * (1 - exp(h_Gp) + h_Gp * (1  + h_Gp/ 2)- h_B * a_p));
  h_0b = (1 - S_b)/ a_b; h_bp = (S_b - S_p)/ (a_p - a_b); h_pi = S_p/ (gamma(4/3)/ h_W - a_p);
  
  switch model
    case 'std'
      [tau_p, tau_b, l_p, l_b] = get_tp(pars_tp, f); l_i = f;
    case 'abj'
      [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i] = get_tp_j(pars_tp, f); 
  end
  kT_M = k_M * TC; a_b = tau_b/ kT_M; a_p = tau_p/ kT_M; L_b = L_m * l_b; L_p = L_m * l_p; L_i = l_i * L_m;
  l_pi = (l_p + l_i)/ 2; R = TC * k_R * (f * l_pi^2/ (f + g) * (g + l_pi) - kv_Hp);
  
  char_eq = @(rho, rho_p) 1 + exp(- rho * rho_p) - exp(rho); % see DEB3 eq (9.22): exp(-r*a_p) = exp(r/R) - 1 
  r_NB = R * fzero(@(rho) char_eq(rho, R_i * a_p), [1e-9 1]); % r_N + h_B
  erNBb = exp(- r_NB * a_b); k_b = r_NB * erNBb/ (1 - erNBb);
  erNBp = exp(- r_NB * a_p); k_p = r_NB * erNBp/ (erNBa - erNBp);
  
  dN_0b = R * N_pi - h_0b * N_0b - k_b * N_0b;
  dN_bp = k_b * N_0b - h_bp - k_p * N_bp;
  dN_pi = k_p * N_bp - h_pi * N_pi;
  
  dL_0b = dN_0b * L_b/ 2;
  dL_bp = dN_bp * (L_p + L_b)/ 2;
  dL_pi = dN_pi * (L_p + L_i)/ 2;

  dW_0b = dN_0b * (L_b/ 2)^3 * (1 + f * ome);
  dW_bp = dN_bp * ((L_p + L_b)/ 2)^3 * (1 + f * ome);
  dW_pi = dN_pi * ((L_p + L_i)/ 2)^3 * (1 + f * ome);

  dx = k_X - h_D * x - f * TC * F_Xm  * (NL2_bp + NL2_pi);
  
  dxNLW = [dx; dN_0b; dN_bp; dN_pi; dL_0b; dL_bp; dL_pi; dW_0b; dW_bp; dW_pi];
end

