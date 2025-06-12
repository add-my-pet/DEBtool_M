%% get_tj_holo
% Gets scaled age at emergence for hex model for holo-metabolic insects

%%
function [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho_j, u_Ej, v_Hj, info] = get_tj_holo(p, f)
  % created at 2025/06/11 by Bas Kooijman 
  
  %% Syntax
  % [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho_j, u_Ej, v_Hj, info] = <../get_tj_holo.m *get_tj_holo*> (p, f)
  
  %% Description
  % Obtains scaled ages at emergence, puberty, birth and the scaled lengths at these ages for hex model;
  % Food density is assumed to be constant.
  % Pupation trigger: reserve density at pupation equals reserve density at emergence; pupa resets maturity
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages. 
  % Metabolic acceleration occurs between birth and pupation, see also get_ts. 
  % Notice j-e-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 5 with parameters: g, k, v_H^b, v_H^e, ome_j
  % * f: optional scalar with functional response (default f = 1)
  %  
  % Output
  %
  % * tau_j: scaled age at pupation \tau_j = a_j k_M
  % * tau_e: scaled age at emergence \tau_e = a_e k_M
  % * tau_b: scaled age at birth \tau_b = a_b k_M
  % * l_j: scaled length at pupation = end of acceleration
  % * l_e: scaled length at emergence = end of growth
  % * l_b: scaled length at birth = start of acceleration
  % * rho_j: scaled exponential growth rate between b and j
  % * v_Hj: scaled maturity at pupation
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  See <get_tj_hep.html get_tj_hep*> in case of ephemeropterans;
  %  Def ome_j = kap_V/ kap * [M_V] * mu_V/ [E_G], where kap_V is conversion eff from larval structure to pupal reserve
  
  %% Example of use
  %  get_tj_holo([.5, .1, .01, .05, 0.8])

  % unpack pars
  g     = p(1); % -, energy investment ratio
  k     = p(2); % -, k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  v_Hb  = p(3); % -, v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}: birth (embryo-larva transition)
  v_He  = p(4); % -, v_H^e = U_H^e g^2 kM^3/ (1 - kap) v^2; U_H^e = E_H^e/ {p_Am}: emergence (pupa-imago transition)
  ome_j = p(5); % -, reserve/structure conversion at pupation: kap_V/kap mu_V/mu_GV 
  
  if ~exist('f', 'var') || isempty(f)
    f = 1;
  end
  
  % initiate output
  tau_j=[]; tau_e=[]; l_j=[]; rho_j=[]; v_Hj = []; 
  
  % birth
  [tau_b, l_b, info] = get_tb([g, k, v_Hb], f); % -, scaled age and length at birth
  if ~info; tau_b = []; l_b = []; return; end
  rho_j = (f/ l_b - 1)/ (f/ g + 1); % -, scaled specific growth rate of larva

  % from pupation to emergence
  [u_Ej, l_e, info] = get_ue0([g, k, v_He], f); % -, scaled reserve just after pupation
  if ~info; l_e = []; return; end
  tau_je = get_tb([g, k, v_He], f, l_e); % -, scaled time since pupation at emergence
  
  info = 1;
  % pupation
  tau_bj = log(u_Ej/ l_b^3/ (ome_j + f/ g))/ rho_j; % -, scaled time since birth at pupation
  l_j = l_b * exp(tau_bj * rho_j/ 3); % -, scaled length at pubation
  tau_j = tau_b + tau_bj; % -, scaled age at pupation
  tau_e = tau_j + tau_je; % -, scaled age at emergence
  
  % maturity at pupation, see comments on DEB3 for 8.7.2 with v_Hj=E_Hj/((1-kap)g[E_m]L_m^3); v/L_b=k_M g/l_b
  v_Hj = f*l_b^2*(1-rho_j*l_b/g)*(exp(rho_j*tau_bj)-exp(-k*tau_bj))/(rho_j+k)+v_Hb*exp(-k*tau_bj);
  
end
