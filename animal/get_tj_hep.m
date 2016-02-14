%% get_tj_hep
% Gets scaled age at emergence for hep model

%%
function [tj, tp, tb, lj, lp, lb, li, rj, rB, N, info] = get_tj_hep(p, f)
  % created at 2016/02/12 by Bas Kooijman, 
  
  %% Syntax
  % [tj, tp, tb, lj, lp, lb, li, rj, rB, N, info] = <../get_tj_hep.m *get_tj_hep*> (p, f)
  
  %% Description
  % Obtains scaled ages at emerence, puberty, birth and the scaled lengths at these ages for hep model;
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages. 
  % Metabolic acceleration occurs between birth and metamorphosis, see also get_ts. 
  % Notice j-p-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 7 with parameters: g, k, v_H^b, v_H^p, v_R^j, kap, kap_R  
  % * f: optional scalar with functional response (default f = 1)
  %  
  % Output
  %
  % * tj: scaled with age at emergence \tau_j = a_j k_M
  % * tp: scaled with age at puberty \tau_p = a_p k_M
  % * tb: scaled with age at birth \tau_b = a_b k_M
  % * lj: scaled length at emergence
  % * lp: scaled length at puberty = end of acceleration
  % * lb: scaled length at birth = start of acceleration
  % * li: ultimate scaled length
  % * rj: scaled exponential growth rate between b and p
  % * rB: scaled von Bertalanffy growth rate between p  between j
  % * N: number of eggs at emergence
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  See <get_tj_hex.html get_tj_hex*> in case of hemi/hole metabolic  insects;
  %  Contrary to the abj-model, j (emergence) is here after p (puberty)
  
  %% Example of use
  %  get_tj_hep([.5, .1, .01, .05, .2, 0.8, .95])
  
  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHb = p(3); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm} start acceleration
  vHp = p(4); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm} end acceleration
  vRj = p(5); % (kap/(1 - kap)) [E_R^j]/ [E_G] scaled reprod buffer density at emergence 
  kap = p(6); % -, allocation fraction to soma
  kapR = p(7); % -, reprod efficiency
    
  if ~exist('f', 'var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end

  pars_tj = [g k 0 vHb vHp]; % vHp functions as vHj in get_tj
  [tp, tpp, tb, lp, lpp, lb, li, rj, rB, info] = get_tj(pars_tj, f);
  sM = lp/ lb; % -, acceleration factor

  [vR tl] = ode45(@dget_tj, [0; vRj], [0; lp], [], f, sM, rB, li, g, k, vHp, kapR);
  tj = tp + tl(end,1); % -, scaled age at emergence 
  lj = tl(end,2);      % -, scaled length at emergence
      
  N = (1 - kap) * vRj * lj^3/ get_ue0([g k vHb], f, lb); % # of eggs at j
  
end

%% subfunction
function dtl = dget_tj(vR, tl, f, sM, rB, li, g, k, vHp, kapR)
  l = tl(2); % -, scaled length

  dl = rB * (li - l);
  dvR = kapR * ((f * g * sM/ l + f)/ (g + f) - k * vHp/ l^3) - rB * vR * (f * sM/ l - 1);

  dtl = [1; dl]/ dvR; % pack output
end