%% get_lj_foetus
% Gets scaled length at metamorphosis for foetal development

%%
function [lj, lp, lb, info] = get_lj_foetus(p, f)
  % created at 2012/06/26 by Bas Kooijman, modified 2014/03/08, 2015/01/18
  
  %% Syntax
  % [lj, lp, lb, info] = <../get_lj_foetus.m *get_lj_foetus*> (p, f)
  
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
  % Similar to <get_lj1_foetus.html *get_lj1_foetus*>, which uses root finding
  % l = L/ L_m with L_m = kap {p_Am}/ [p_M] where {p_Am} is of embryo.
  % {p_Am} and v increase between maturities v_H^b and v_H^j till
  %   {p_Am} l_j/ l_b  and v l_j/ l_b at metamorphosis.
  % After metamorphosis l increases from l_j till l_i = f l_j/ l_b - l_T;
  % l can thus be larger than 1.
  % See <get_lj.html *get_lj*> for egg development. 

  %% Example of use
  % get_lj_foetus([.5, .1, .1, .01, .2, .3])

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
    [lp, lb, info] = get_lp_foetus (p, f);
    lj = lb;
    return
  end

  % get lb
  [lb tb info] = get_lb_foetus([g; k; vHb]);
   
  % get lj
  [vH lj] = ode45(@dget_l_V1, [vHb; vHj], lb, [], k, lT, g, f, lb); 
  lj = lj(end); sM = lj/ lb;
   
  % get lp
  [vH lp] = ode45(@dget_l_ISO, [vHj; vHp], lj, [], k, lT, g, f, sM); 
  lp = lp(end);
  
  if lT > f - lb
    info = 0;
  end
end
