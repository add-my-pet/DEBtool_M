%% get_ep_min_j
% Gets scaled reserve density at with maturation ceases at puberty in case of acceleration

%%
function [ep info] = get_ep_min_j(p)
  % created 2015/09/16 by Bas Kooijman
  
  %% Syntax
  % [ep info] = <..get_ep_min_j.m *get_ep_min_j*> (p)
  
  %% Description
  % Obtains the scaled reserve at birth for growth and maturation ceases at puberty in case of acceleration. 
  % It can be seen as the lower viable scaled reserve density for reproduction. Cf get_eb_min.
  % See get_ep_min for no acceletaton
  %
  % Input
  %
  % * p: 6-vector with parameters: g k lT v_H^b v_H^j v_H^p (cf <get_lj.html *get_lj*>)
  %  
  % Output
  %
  % * ep: scalar with e_p such that growth and maturation cease at puberty
  % * info: scalar 1 for success, 0 otherwise
  
  %% Remarks
  % The theory behind get_ep_min is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010b.html the comments for DEB3>.
  % See <get_ep_min.html *get_ep_min*> for without acceletaton
  % See <get_eb_min.html *get_eb_min*> for minimum e at birth.

  %% Example of use
  % get_ep_min_j([.1 1 0 .001 0.01 .1])
  
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  vHj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^j = M_H^j/ {J_EAm}
  vHp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}

  [l_j, l_p, l_b] = get_lj(p, 1); s_M = l_j/ l_b; ep_0 = lT + l_p/ s_M;
  [ep, fval, info] = fzero(@fnget_ep_min_j, ep_0, [], g, k, lT, vHb, vHj, vHp);
  
end

function F = fnget_ep_min_j(f, g, k, lT, vHb, vHj, vHp)
  [l_j, l_p, l_b] = get_lj([g, k, lT, vHb, vHj, vHp], f);
  F = l_p - (f - lT) * l_j/ l_b;
end
