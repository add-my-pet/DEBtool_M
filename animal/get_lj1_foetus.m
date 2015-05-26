%% get_lj1_foetus
% Gets scaled length at metamorphosis for foetal development

%%
function [lj, lp, lb, info] = get_lj1_foetus(p, f)
  % created at 2012/06/26 by Bas Kooijman
  % modified 2014/03/08, 2015/02/17 Bas Kooijman & Goncalo Marques
  
  %% Syntax
  % [lj, lp, lb, info] = <../get_lj1_foetus.m *get_lj1_foetus*> (p, f)
  
  %% Description
  % Gets scaled length at metamorphosis for foetal development.
  %
  % Input
  %
  % * p: 6-vector with parameters: g, k, l_T, v_H^b, v_H^j, v_H^p
  % * f: optional scalar with scaled functional responses (default 1)
  %
  % Output
  %
  % * lj: scalar with scaled length at metamorphosis
  % * lp: scalar with scaled length at puberty
  % * lb: scalar with scaled length at birth
  % * info: indicator equals 1 if successful
  
  %% Remarks
  % l = L/ L_m with L_m = kap {p_Am}/ [p_M] where {p_Am} is of embryo.
  % {p_Am} and v increase between maturities v_H^b and v_H^j till
  %   {p_Am} l_j/ l_b  and v l_j/ l_b at metamorphosis.
  % After metamorphosis l increases from l_j till l_i = f l_j/ l_b - l_T;
  % l can thus be larger than 1.
  % See <get_lj.html *get_lj*> for egg development. 

  %% Example of use
  % get_lj1_foetus([.5, .1, .1, .01, .2, .3])

  %  unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  vHj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^j = M_H^j/ {J_EAm}
  vHp = p(6); % v_H^p = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^j = M_H^j/ {J_EAm}

  if ~exist('f', 'var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end

  if vHb == vHj % no acceleration
    [lp, lb, info] = get_lp1_foetus (p, f);
    lj = lb;
    return
  end

  % get lb
  [lb tb info] = get_lb_foetus([g; k; vHb]);
   
  % get lj
  sM = fzero(@fnget_sM, (vHj/ vHb)^(1/3), [], f, lb, g, k, lT, vHb, vHj);
  lj = sM * lb;
  
  % get lp    
  li = sM * (f - lT);   % -, scaled ultimate length
  rB = g / 3 / (f + g); % -, scaled von Bertalanffy growth rate
  ld = li - lj;         % -, scaled length
  % d/d tau vH = b2 l^2 + b3 l^3 - k vH
  b3 = 1 / (1 + g / f); 
  b2 = f * sM - b3 * li;
  % for t is scaled time since metam:
  % vH(t) = - a0 - a1 exp(- rB t) - a2 exp(- 2 rB t) - a3 exp(- 3 rB t) +
  %         + (vHj + a0 + a1 + a2 + a3) exp(-k t)
  a0 = - (b2 + b3 * li) * li^2/ k;
  a1 = - li * ld * (2 * b2 + 3 * b3 * li)/ (rB - k);
  a2 = ld^2 * (b2 + 3 * b3 * li)/ (2 * rB - k);
  a3 = - b3 * ld^3 / (3 * rB - k);

  lp = fzero(@fnget_lp, lj * (vHp/ vHj)^(1/3), [], a0, a1, a2, a3, lj, li, k, rB, vHj, vHp);
  
  if lT > f - lb
    info = 0;
  end
end
