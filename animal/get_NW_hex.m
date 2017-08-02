%% get_NW_hex
% Gets number of eggs at emergence for hex model from wet weight of imago

%%
function [N, f, le, info] = get_NW_hex(Ww, pars_tj, pars_aux)
  % created at 2017/07/31 by Bas Kooijman, 
  
  %% Syntax
  % [N, f, l_e, info] = <../get_NW_hex.m *get_NW_hex*> (Ww, pars_tj, pars_aux)
  
  %% Description
  % Obtains number of eggs at emergence from wet weight of imago for hex model
  % Food density is assumed to be constant.
  %
  % Input
  %
  % * Ww: n-vector with scaled wet weights of imago in grams
  % * pars_tj: 7-vector with parameters: g k v_Hb v_He s_j kap kap_V, see get_tj_hex 
  % * pars_aux: 6-vector with parameters: kap_R, E_m, L_m, w_E, mu_E, d_E
  %  
  % Output
  %
  % * N: n-vector with number of eggs at emergence
  % * f: n-vector with functional response 
  % * le: n-vector with scaled structural length at emergence
  % * info: n-vector with indicators equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  first finds f from Ww, then N and le from f.
  
  %% Example of use
  %  get_NW_hex([.5, .1, .01, .05, .2, 0.8, .95])
   
   kap = pars_tj(6); kap_R = pars_aux(1); % unpack parameters
   n = length(Ww); N = zeros(n,1); le = zeros(n,1); f = zeros(n,1); info = zeros(n,1); % initiate output
 
   for i = 1:n    
     f(i) = fzero(@fnfW, 1, [], pars_tj, pars_aux, Ww(i)); % -, scaled functional response
     [tj, te, tb, lj, le(i), lb, rj, vRj, uEe, info(i)] = get_tj_hex(pars_tj, f(i));
     N(i) = kap_R * (1 - kap) * vRj * lj^3/ get_ue0(pars_tj, f(i)); % total # of eggs
   end
 
end

%% subfunction

function F = fnfW(f, pars_tj, pars_aux, Ww) 
  % called from get_NW_hex via fzero: F = 0 for f such that Ww_e = Ww 
  [t_j, t_e, t_b, l_j, l_e, l_b, rho_j, v_Rj, u_Ee] = get_tj_hex(pars_tj, f);
  g = pars_tj(1); kap = pars_tj(6);   % pars_tj: g k v_Hb v_He s_j kap kap_V kap_R
  E_m = pars_aux(2); L_m = pars_aux(3); w_E = pars_aux(4); mu_E = pars_aux(5); d_E = pars_aux(6);
  
  %Ww_0 = g * E_m * L_m^3 * get_ue0(pars_tj, f) * w_E/ mu_E/ d_E;         % g, initial wet weight
  Ww_Rj = v_Rj * (1 - kap) * g * E_m * (L_m * l_j)^3 * w_E/ mu_E/ d_E;    % g, wet weight reprod buffer at pupation
  Ww_e = (L_m * l_e)^3 + Ww_Rj + u_Ee * g * E_m * L_m^3 * w_E/ mu_E/ d_E; % g, wet weight including reprod buffer

  F = Ww_e - Ww; % loss function
end