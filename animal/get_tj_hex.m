%% get_tj_hex
% Gets scaled age at emergence for hex model for holo-metabolic insects

%%
function [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho_j, v_Rj, u_Ee, info] = get_tj_hex(p, f)
  % created at 2016/02/15 by Bas Kooijman, modified 2019/08/04
  
  %% Syntax
  % [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho_j, v_Rj, u_Ee, info] = <../get_tj_hex.m *get_tj_hex*> (p, f)
  
  %% Description
  % Obtains scaled ages at emergence, puberty, birth and the scaled lengths at these ages for hex model;
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages. 
  % Metabolic acceleration occurs between birth and metamorphosis, see also get_ts. 
  % Notice j-p-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 7 with parameters: g, k, v_H^b, v_H^e, s_j, kap, kap_V  
  % * f: optional scalar with functional response (default f = 1)
  %  
  % Output
  %
  % * tau_j: scaled age at pupation \tau_j = a_j k_M
  % * tau_e: scaled age at emergence \tau_e = a_e k_M
  % * tau_b: scaled age at birth \tau_b = a_b k_M
  % * l_j: scaled length at pupation = end of acceleration
  % * l_e: scaled length at emergence
  % * l_b: scaled length at birth = start of acceleration
  % * rho_j: scaled exponential growth rate between b and p
  % * v_Rj: scaled reproduction buffer density at pupation: v_R^j = kap [E_R^j]/ ((1 - kap) [E_G]); 
  % * u_Ee: scaled reserve at emergence: u_E^e = U_E^e g^2 kM^3/ v^2; U^e = E^e/ {p_Am}
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  See <get_tj_hep.html get_tj_hep*> in case of ephemeropterans;
  
  %% Example of use
  %  get_tj_hex([.5, .1, .01, .05, .95, 0.8, 0.9])

  % unpack pars
  g     = p(1); % -, energy investment ratio
  k     = p(2); % -, k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  v_Hb  = p(3); % -, v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}: birth (embryo-larva transition)
  v_He  = p(4); % -, v_H^e = U_H^e g^2 kM^3/ (1 - kap) v^2; U_H^e = E_H^e/ {p_Am}: emergence (pupa-imago transition)
  s_j   = p(5); % -, [E_R^j]/ [E_R^ref] scaled reprod buffer density at pupation
  %  [E_R^ref] = (1 - kap) [E_m] g (k_E + k_M)/ (k_E - g k_M) is max reprod buffer density
  kap   = p(6); % -, allocation fraction to soma of pupa
  kap_V = p(7); % -, conversion efficiency from larval reserve to larval structure, back to imago reserve
  
  if ~exist('f', 'var') || isempty(f)
    f = 1;
  end
  
  % from birth to pupation
  [tau_b, l_b, info] = get_tb([g k v_Hb], f); % scaled age and length at birth
%   if info == 0
%      rho_j = []; v_Rj = []; t_j = []; l_j = []; t_e = []; l_e = []; u_Ee = []; info = 0; return;
%   end
  rho_j = (f/ l_b - 1)/ (f/ g + 1);           % scaled specific growth rate of larva
  v_Rj = s_j * (1 + l_b/ g)/ (1 - l_b);       % scaled reprod buffer density at pupation

  tau_j = nmfzero(@fnget_tj_hex, 1, [], f, g, l_b, k, v_Hb, v_Rj, rho_j); % scaled time since birth at pupation
  l_j = l_b * exp(tau_j * rho_j/ 3);          % scaled length at pubation
  tau_j = tau_b + tau_j;                      % -, scaled age at pupation
  sM = l_j/ l_b;                              % -, acceleration factor

  % from pupation to emergence; 
  % instantaneous conversion from larval structure to pupal reserve
  u_Ej = l_j^3 * (kap * kap_V + f/ g);        % -, scaled reserve at pupation

  options = odeset('Events',@emergence, 'NonNegative',[1; 1; 1]);
  [t luEvH tau_e luEvH_e] = ode45(@dget_tj_hex, [0, 300], [0; u_Ej; 0], options, sM, g, k, v_He);
  tau_e = tau_j + tau_e; % -, scaled age at emergence 
  l_e = luEvH(end,1);    % -, scaled length at emergence
  u_Ee = luEvH(end,2);   % -, scaled reserve at emergence

  if isempty(tau_e) || u_Ee < 0
    info = 0;
  end
end

%% subfunctions

function F = fnget_tj_hex(tau_j, f, g, l_b, k, v_Hb, v_Rj, rho_j)
  ert = exp(- tau_j * rho_j);
  F = v_Rj - f/ g * (g + l_b)/ (f - l_b) * (1 - ert) + tau_j * k * v_Hb * ert/ l_b^3;
end

function [value,isterminal,direction] = emergence(t, luEvH, sM, g, k, v_He)
 value = v_He - luEvH(3); 
 isterminal = 1;
 direction = 0;
end

function dluEvH = dget_tj_hex(t, luEvH, sM, g, k, v_He)
  l = luEvH(1); l2 = l * l; l3 = l * l2; l4 = l * l3; u_E = max(1e-6, luEvH(2)); v_H = luEvH(3);

  dl = (g * sM * u_E - l4)/ (u_E + l3)/ 3;
  du_E = - u_E * l2 * (g * sM + l)/ (u_E + l3);
  dv_H = - du_E - k * v_H;

  dluEvH = [dl; du_E; dv_H]; % pack output
end