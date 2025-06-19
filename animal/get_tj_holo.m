%% get_tj_holo
% Gets scaled age at pupation for hex model for holo-metabolic insects

%%
function [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho, u_Ej, v_Hj, info] = get_tj_holo(p, f)
  % created at 2025/06/11 by Bas Kooijman 
  
  %% Syntax
  % [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho, u_Ej, v_Hj, info] = <../get_tj_holo.m *get_tj_holo*> (p, f)
  
  %% Description
  % Obtains scaled ages at pupation, emergence, birth and the scaled lengths at these ages for hex model;
  % Food density is assumed to be constant.
  % Pupation trigger: reserve density at pupation equals reserve density at emergence; pupa resets maturity and structure
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
  % * rho: scaled exponential growth rate between b and j
  % * v_Hj: scaled maturity at pupation
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  Def ome_j = kap_V/ kap * [M_V] * mu_V/ [E_G], where kap_V is conversion eff from larval structure to pupal reserve
  %  Energy conductance v increases during acceleration and remains constant at v*s_M after j
  %  Structure and maturity are reset at pupation. So v_He does not to be larger than v_Hj
  %  See <get_tj_hep.html get_tj_hep*> in case of ephemeropterans;
  
  %% Example of use
  %  get_tj_holo([.5, .1, .01, .05, 0.8],1)

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
  tau_j=[]; tau_e=[]; l_j=[]; rho = []; v_Hj = []; 
  
  % birth
  [tau_b, l_b, info] = get_tb([g, k, v_Hb], f); % -, scaled age and length at birth
  if ~info; tau_b = []; l_b = []; return; end
  rho = (f/ l_b - 1)/ (f/ g + 1); % -, scaled specific growth rate of larva from b to j

  % shooting with bisection
  v_Hj0 = v_Hb; v_Hj1 = 1000*v_Hb; f_e = 2; % boundaries for v_Hj
  while abs(f-f_e)>1e-6 % f_e = e_e: scaled reserve density at emergence 
    v_Hj = (v_Hj0 + v_Hj1)/2; % guess for v_Hj
    [v_H, tl] = ode45(@get_tl,[v_Hb; v_Hj], [0; l_b], [], f,l_b,g,k,rho); % from b to j
    tau_bj = tl(end,1); l_j = tl(end,2); s_M = l_j/ l_b; u_Ej = l_j^3 * (f/g + ome_j); % scaled initial reserve density for pupa
    [v_H, tuEl] = ode45(@get_tuEl,[0; v_He], [0; u_Ej; 1e-3], [], g,k,s_M); % from j to e
    tau_je = tuEl(end,1); u_Ee = tuEl(end,2); l_e = tuEl(end,3); f_e = g * s_M * u_Ee/ l_e^3;
    if f_e < f
      v_Hj0 = v_Hj;
    else
      v_Hj1 = v_Hj;
    end
  end
  tau_j = tau_b + tau_bj; % -, scaled age at pupation
  tau_e = tau_j + tau_je; % -, scaled age at emergence

end

function dtl = get_tl(v_H, tl, f,l_b,g,k,rho) % from b to j
   l = tl(2); % unpack vars
   dl = l * rho/3; % change in l in scaled time
   dv_H = f * l^3 *(1/l_b - rho/g) - k * v_H; % change in v_H in scaled time comment p 188
   dtl = [1; dl]/dv_H; % change in l in v_H
end

function dtuEl = get_tuEl(v_H, tuEl, g,k,s_M) % from j to e
   u_E = tuEl(2); l = tuEl(3); % unpack vars
   du_E = - u_E * l^2 * (g * s_M + l)/ (u_E + l^3); % change in u_E in scaled time
   dl = (u_E * g * s_M - l^4)/(u_E + l^3)/ 3; % change in l in scaled time
   dv_H = u_E * l^2 * (g * s_M + l)/ (u_E + l^3) - k * v_H;  % change in scaled maturity
   dtuEl = [1; du_E; dl]/dv_H; % change of tau, u_E and l in v_H
end
