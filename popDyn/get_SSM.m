%% get_SSM
% get trajectories of Semi Structured Model for a generalized reactor

%%
function tNL23W = get_SSM(model, par, tT, tJX, x_0, V_X, t_max)
% created 2020/05/08 by Bas Kooijman
  
%% Syntax
% tNL23W = <../get_SSM.m *get_ssm*> (model, par, tT, tJX, x_0, V_X, t_max)
  
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
      [u_E0, l_b] = get_ue0_foetus([g, k, v_Hb], 1);
    otherwise
      [u_E0, l_b] = get_ue0([g, k, v_Hb], 1);
  end
  switch model
    case {'std','stx','stf','ssj','sbp'}
      pars_tp = [g k 0 v_Hb v_Hp]; 
      fa_b = zeros(11,2); fa_p = zeros(11,2); fL_b = zeros(11,2);  fL_p = zeros(11,2); fL_i = zeros(11,2); 
      fa_b(1,2) = 1e6; fa_p(1,2) = 1e6; fL_b(1,2) = 1e-3; fL_p(1,2) = 1e-3; fL_i(1,2) = 1e-3;
      for i=1:10
        f = i/10;
        [tau_p, tau_b, l_p, l_b, info] = get_tp(pars_tp, f); l_i = f;
        fa_b(i+1,:) = [f, tau_b/ k_M]; fa_p(i+1,:) = [f, tau_p/ k_M]; 
        fL_b(i+1,:) = [f, L_m * l_b]; fL_p(i+1,:) = [f, L_m * l_p]; fL_i(i+1,:) = [f, L_m * l_i];
        if info == 0
          fL_p(i+1,2) = fL_i(i+1,2);
        end
      end
    case 'abj'
      pars_tp = [g k 0 v_Hb v_Hj v_Hp]; 
  end 
  k_R = kap_R * (1 - kap) * k_M/ u_E0; L_b = L_m * l_b;
  
  options = odeset('AbsTol',1e-8, 'RelTol',1e-8); 
  % xNL23W_0:  x N_0b N_bp N_pi NL_0b, NL_bp, NL_pi, NL2_0b, NL2_bp, NL2_pi, NL3_0b, NL3_bp, NL3_pi, NW_0b, NW_bp, NW_pi
  t = (0:.005:1)' * t_max; xNL23W_0 = [x_0; 1; 0; 0; L_b/2; 0; 0; L_b^2/2; 0; 0; L_b^3/2; 0; 0; L_b^3/ 2 * (1 + ome); 0; 0]; 
  [t, xNL23W] = ode45(@dssm, t, xNL23W_0, [], model, tTC, tkX, fa_b, fa_p, fL_b, fL_p, fL_i, p_Am/ K/ kap_X/ mu_X, h_B, h_X, h_a, s_G, k_R, k_M, g, k*v_Hp, L_m, ome);
  tNL23W = [t, xNL23W(:,1), sum(xNL23W(:, 2: 4),2), sum(xNL23W(:, 5: 7),2), sum(xNL23W(:, 8:10),2), sum(xNL23W(:,11:13),2), sum(xNL23W(:,14:16),2)];

end

function dxNLW = dssm(t, xNLW, model, tTC, tkX, fa_b, fa_p, fL_b, fL_p, fL_i, F_Xm, h_B, h_X, h_a, s_G, k_R, k_M, g, kv_Hp, L_m, ome)
  persistent rho_NB

  x = xNLW(1); f = x/ (1 + x); N_0b = max(0, xNLW(2)); N_bp = max(0, xNLW(3)); N_pi = max(0, xNLW(4));       
        
  if length(tkX) == 1
    k_X = tkX;
  else
    k_X = spline1(t, tkX); % food supply flux: J_XI/ V_X/ K
  end
  if length(tTC) == 1
    TC = tTC;
  else
    TC = spline1(t, tTC); % temperature correction factor
  end
    
  a_b = spline1(f, fa_b); a_p = spline1(f, fa_p); L_b = spline1(f, fL_b); L_p = spline1(f, fL_p); L_i = spline1(f, fL_i); 
  kT_M = k_M * TC; a_b = a_b/ TC; a_p = a_p/ kT_M; l_pi = (L_p + L_i)/ 2/ L_m; 
  R = max(0, TC * k_R * (f * l_pi^2 * (g + l_pi)/ (g + f) - kv_Hp));
 
  h3_W = TC^3 * h_a * k_M * g/ 6; h_W = h3_W^(1/3); h_G = kT_M * g * s_G * f^3; h_Gb = h_G * a_b; h_Gp = h_G * a_p; a_m = gamma(4/3)/ h_W;
  S_b = exp(6 * h3_W/ h_G^3 * (1 - exp(h_Gb) + h_Gb * (1  + h_Gb/ 2) - h_B * a_b));
  S_p = exp(6 * h3_W/ h_G^3 * (1 - exp(h_Gp) + h_Gp * (1  + h_Gp/ 2) - h_B * a_p));
  h_0b = (1 - S_b)/ a_b; h_bp = (S_b - S_p)/ (a_p - a_b); h_pi = S_p/ (a_m - a_p);

  if isempty(rho_NB) || isnan(rho_NB)
    rho_NB = 1;
  end
  rho_NB = char_eq(rho_NB, R * a_p);  
  r_NB = R * rho_NB; % r_N + h_B
  erNBb = exp(- r_NB * a_b); k_b = r_NB * erNBb/ (1 - erNBb);
  erNBp = exp(- r_NB * a_p); k_p = r_NB * erNBp/ (erNBb - erNBp);
  
  dN_0b = R * N_pi   - h_0b * N_0b - k_b * N_0b;
  dN_bp = k_b * N_0b - h_bp * N_bp - k_p * N_bp;
  dN_pi = k_p * N_bp - h_pi * N_pi;
  
  L_0b = L_b/ 2; 
  L_bp = 0.5 * L_b + 0.5 * L_p; 
  L_pi = 0.3 * L_p + 0.7 * L_i; 
  dNL_0b  = dN_0b * L_0b;   dNL_bp  = dN_bp * L_bp;   dNL_pi  = dN_pi * L_pi;
  dNL2_0b = dNL_0b * L_0b;  dNL2_bp = dNL_bp * L_bp;  dNL2_pi = dNL_pi * L_pi;
  dNL3_0b = dNL2_0b * L_0b; dNL3_bp = dNL2_bp * L_bp; dNL3_pi = dNL2_pi * L_pi;
  dNW_0b  = dNL3_0b * (1 + f * ome); dNW_bp = dNL3_bp * (1 + f * ome); dNW_pi = dNL3_pi * (1 + f * ome);

  dx = k_X - h_X * x - f * TC * F_Xm  * (N_bp * L_bp^2 + N_pi * L_pi^2);
 
  dxNLW = [dx; dN_0b; dN_bp; dN_pi; dNL_0b; dNL_bp; dNL_pi; dNL2_0b; dNL2_bp; dNL2_pi; dNL3_0b; dNL3_bp; dNL3_pi; dNW_0b; dNW_bp; dNW_pi];
end

function rho = char_eq (rho, rho_p)
  f = 1; i = 0;
  while f^2 > 1e-10 & i < 11
    err = exp(- rho * rho_p); er = exp(rho); 
    f = 1 + err - er; i = i + 1;
    rho = rho + f/ (rho_p * err + er);
  end
end
