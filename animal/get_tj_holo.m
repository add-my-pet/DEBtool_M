%% get_tj_holo
% Gets scaled age at pupation for hex model for holo-metabolic insects

%%
function [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho, v_Hj, u_Ej, info] = get_tj_holo(p, f)
  % created at 2025/06/11 by Bas Kooijman, modified 2025/07/04 
  
  %% Syntax
  % [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho, v_Hj, u_Ej, info] = <../get_tj_holo.m *get_tj_holo*> (p, f)
  
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
  % * l_j: scaled length just before pupation = end of acceleration
  % * l_e: scaled length at emergence = end of growth
  % * l_b: scaled length at birth = start of acceleration
  % * rho: scaled exponential growth rate between b and j
  % * v_Hj: scaled maturity just before pupation
  % * u_Ej: scaled reserve just after pupation
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
  ome_j = p(5); % -, reserve/structure conversion at pupation: kap_V kap mu_V [M_V]/[E_G] 
  
  if ~exist('f', 'var') || isempty(f)
    f = 1;
  end
  
  % initiate output and set max step number
  tau_j=[]; tau_e=[]; l_j=[]; rho = []; v_Hj = []; n = 500;
  
  % birth
  [tau_b, l_b, info] = get_tb([g, k, v_Hb], f); % -, scaled age and length at birth
  if ~info; tau_b = []; l_b = []; return; end
  rho = (f/ l_b - 1)/ (f/ g + 1); % -, scaled specific growth rate of larva from b to j

  % shooting with bisection
  l_j0 = l_b; l_j1 = 100 * l_b; u_Ej = 1; u_Ej_e = 2; i = 1; % boundaries for l_j
  while abs(u_Ej-u_Ej_e)>1e-6 && i<n % f_e = e_e: scaled reserve density at emergence 
    l_j = (l_j0 + l_j1)/2; i = i + 1; % guess for l_j
    s_M = l_j/ l_b; 
    u_Ej = l_j^3 * (f/g/s_M + ome_j); % scaled initial reserve density for pupa
    [u_Ej_e, l_e] = get_ue0([g*s_M, k, v_He],f);
    if u_Ej < u_Ej_e
      l_j0 = l_j;
    else
      l_j1 = l_j;
    end
  end
  v_Hj = f * l_b^3 * (1/l_b-rho/g)/(k+rho)*(s_M^3-s_M^(-3*k/rho))+v_Hb*s_M^(-3*k/rho); % see comments for 7.8.2
  tau_bj = log(s_M)*3/rho;
  tau_j = tau_b + tau_bj; % -, scaled age at pupation
  tau_je = get_tb([g*s_M, k, v_He],f);
%     % integrate over pupa for testing
%     [~, vHuEl] = ode45(@get_vHuEl,[0;tau_je],[0;u_Ej;0],[],g*s_M,k);
%     data = [v_He vHuEl(end,1); f vHuEl(end,2)*g*s_M/l_e^3; l_e vHuEl(end,3)];
%     prt_tab({{'v_He';'e_e';'l_e'},data},{'emergence','set','integration'},'check')
  tau_e = tau_j + tau_je; % -, scaled age at emergence
  
  if i >= n
   info=0; tau_j=[]; tau_e=[]; l_j=[]; rho=[]; v_Hj=[]; 
   fprintf(['Warning from get_tj_holo: no convergence in ', num2str(n), ' steps\n']);
  end
  
end

% function dvHuEl = get_vHuEl(tau,vHuEl,gsM,k)
%   v_H=vHuEl(1); u_E=vHuEl(2); l=vHuEl(3); l2=l*l; l3=l2*l; l4=l3*l;
%   dvHuEl = [u_E*l2*(gsM+l)/(u_E+l3)-k*v_H; -u_E*l2*(gsM+l)/(u_E+l3); (u_E*gsM-l4)/(u_E+l3)/3];
% end

