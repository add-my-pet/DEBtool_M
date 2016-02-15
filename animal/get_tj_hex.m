%% get_tj_hex
% Gets scaled age at emergence for hex model for holo-metabolic insects

%%
function [tj, te, tb, lj, le, lb, rj, vRj, uEe, info] = get_tj_hex(p, f)
  % created at 2016/02/15 by Bas Kooijman, 
  
  %% Syntax
  % [tj, te, tb, lj, le, lb, rj, vRj, uEe, info] = <../get_tj_hex.m *get_tj_hex*> (p, f)
  
  %% Description
  % Obtains scaled ages at emergence, puberty, birth and the scaled lengths at these ages for hex model;
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages. 
  % Metabolic acceleration occurs between birth and metamorphosis, see also get_ts. 
  % Notice j-p-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 7 with parameters: g, k, v_H^b, v_H^e, s_j, kap, kapV  
  % * f: optional scalar with functional response (default f = 1)
  %  
  % Output
  %
  % * tj: scaled with age at pupation \tau_j = a_j k_M
  % * te: scaled with age at emergence \tau_e = a_e k_M
  % * tb: scaled with age at birth \tau_b = a_b k_M
  % * lj: scaled length at pupation = end of acceleration
  % * le: scaled length at emergence
  % * lb: scaled length at birth = start of acceleration
  % * li: ultimate scaled length
  % * rj: scaled exponential growth rate between b and p
  % * vRj: scaled reproduction buffer density at pupation
  % * uEe: scaled reserve at emergence: u_E^e = U_E^e g^2 kM^3/ v^2; E^e = E^e/ {p_Am}
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  See <get_tj_hep.html get_tj_hep*> in case of ephemeropterans;
  
  %% Example of use
  %  get_tj_hex([.5, .1, .01, .05, .95, 0.8, 0.9])
  
  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHb = p(3); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}: birth (embryo-larva transition)
  vHe = p(4); % v_H^e = U_H^e g^2 kM^3/ (1 - kap) v^2; U_H^e = E_H^e/ {p_Am}: emergence (pupa-imago transition)
  sj  = p(5); % [E_R^j]/ [E_R^ref] scaled reprod buffer density at pupation
  %  [E_R^ref] = (1 - kap) [E_m] g (k_E + k_M)/ (k_E - g k_M) is max reprod buffer density
  kap = p(6); % -, allocation fraction to soma of pupa
  kapV = p(7);% -, conversion effeciency from larval reserve to larval structure, back to imago reserve
  
  if ~exist('f', 'var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end
  
  % from birth to pupation
  [tb, lb, info] = get_tb([ g k vHb], f); % scaled age and length at birth
  rj = (f/ lb - 1)/ (f/ g + 1);           % scaled specific growth rate of larva
  vRj = sj * (1 - lb/ g)/ (1 - lb);       % scaled reprod buffer density at pupation
  tj = fzero(@fnget_tj_hex, 1, [], f, g, lb, k, vHb, vRj, rj); % scaled time from birth at pupation
  lj = lb * exp(tj * rj);                 % scaled length at pubation
  tj = tb + tj;                           % -, scaled age at pupation
  
  % from pupation to emergence
  [vH tluE] = ode45(@dget_tj_hex, [1e-10; vHe], [0; 0; lj^3 * (kap * kapV + f/ g)], [], g, k);
  te = tj + tluE(end,1); % -, scaled age at emergence 
  le = tluE(end,2);      % -, scaled length at emergence
  uEe = tluE(end,3);     % -, scaled reserve at emergence

  
end

%% subfunctions

function F = fnget_tj_hex(tj, f, g, lb, k, vHb, vRj, rj)
  ert = exp(- tj * rj);
  F = vRj - f/ g * (g + lb)/ (f - lb) * (1 - ert) + tj * k * vHb * ert/ lb^3;
end

function dluE = dget_tj_hex(vH, tluE, g, k)
  l = tluE(2); l2 = l * l; l3 = l * l2; l4 = l * l3; uE = tluE(3);

  dl = (g * uE - l4)/ (uE + l3)/ 3;
  duE = - uE * l2 * (g + l)/ (uE + l3);
  dvH = - duE - k * vH;

  dluE = [1; dl; duE]/ dvH; % pack output
end