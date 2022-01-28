%% get_tj_hep
% Gets scaled age at emergence for hep model

%%
function [tj, tp, tb, lj, lp, lb, li, rj, rB, info] = get_tj_hep(p, f)
  % created at 2016/02/12, 2022/01/27 by Bas Kooijman
  
  %% Syntax
  % [tj, tp, tb, lj, lp, lb, li, rj, rB, info] = <../get_tj_hep.m *get_tj_hep*> (p, f)
  
  %% Description
  % Obtains scaled ages at emerence, puberty, birth and the scaled lengths at these ages for hep model of e.g. ephemeropterans;
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages. 
  % Metabolic acceleration occurs between b and p; isomorphy between p and j ( = emergence, e.g. transition from nymph to sub-imago). 
  % Notice j-p-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 5 with parameters: g, k, v_H^b, v_H^p, v_R^j 
  % * f: optional scalar with functional response (default f = 1)
  %  
  % Output
  %
  % * tj: scaled age at emergence \tau_j = a_j k_M
  % * tp: scaled age at puberty \tau_p = a_p k_M
  % * tb: scaled age at birth \tau_b = a_b k_M
  % * lj: scaled length at emergence
  % * lp: scaled length at puberty = end of acceleration
  % * lb: scaled length at birth = start of acceleration
  % * li: ultimate scaled length
  % * rj: scaled exponential growth rate between b and p
  % * rB: scaled von Bertalanffy growth rate between p  between j
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  Contrary to the abj-model, j (emergence) is here after p (puberty)
  %  See <get_tj_hex.html get_tj_hex*> in case of holo metabolic insects;
  
  %% Example of use
  %  get_tj_hep([.5, .1, .01, .05, .2])
  
  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHb = p(3); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am} start acceleration
  vHp = p(4); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am} end acceleration
  vRj = p(5); % (kap/(1 - kap)) [E_R^j]/ [E_G] scaled reprod buffer density at emergence 
    
  if ~exist('f', 'var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end

  pars_tj = [g k 0 vHb vHp]; % vHp functions as vHj in get_tj
  [tp, tpp, tb, lp, lpp, lb, li, rj, rB, info] = get_tj(pars_tj, f);
  if info == 0 || isempty(lp)
    tj = []; lj = [];  info = 0; return
  end
  sM = lp/ lb; % -, acceleration factor

  [vR tl] = ode45(@dget_tj_hep, [0; vRj], [0; lp], [], f, sM, rB, li, g, k, vHp);
  tj = tp + tl(end,1); % -, scaled age at emergence 
  lj = tl(end,2);      % -, scaled length at emergence
        
end

%% subfunction
function dtl = dget_tj_hep(vR, tl, f, sM, rB, li, g, k, vHp)
  l = tl(2); % -, scaled length

  dl = rB * max(0, li - l);
  dvR = (f * g * sM/ l + f)/ (g + f) - k * vHp/ l^3 - 3 * rB * vR * (f * sM/ l - 1);

  dtl = [1; dl]/ dvR; % pack output
end