%% get_ep_min_metam
% Gets scaled reserve density at with maturation ceases at puberty in case of acceleration

%%
function [ep info] = get_ep_min_metam(p)
  % created 2011/05/03 by Bas Kooijman, modified 2011/07/27
  
  %% Syntax
  % [ep info] = <..get_ep_min_metam.m *get_ep_min_metam*> (p)
  
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
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.html the comments for DEB3>.
  % See <get_ep_min.html *get_ep_min*> for without acceletaton
  % See <get_eb_min.html *get_eb_min*> for minimum e at birth.

  %% Example of use
  % get_ep_min_metam([.1 1 0 .001 0.01 .1])
  
  %  unpack parameters
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  vHj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^j = M_H^j/ {J_EAm}
  vHp = p(6); % v_H^p = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^j = M_H^j/ {J_EAm}

  ep_0 = 1; info = 1; % lower boundary for ep
  while info == 1 && ep_0 >= 0
    ep_0 = ep_0 - 0.1;
    [lj, lp, lb, info] = get_lj1([g k lT vHb vHj], ep_0);
  end
  
  ep_1 = 1; % upper boundary for ep
  norm = 1; i = 0; % initialise norm and step number
  
  while i < 200 && abs(norm) > 1e-3 % bisection method
    i = i + 1;
    ep = (ep_0 + ep_1)/ 2;
    [lj, lp, lb, info] = get_lj([g k lT vHb vHj], ep);
    if info == 0
      ep = get_lb([g k vHb], 1);
      fprintf('get_ep_min_metam warning: no convergence for f\n')
      break
    end
    norm = k * vHp - (ep * lj/ lb - lT)^2 * ep * lj/lb;
    if norm > 0
      ep_0 = ep;
    else
      ep_1 = ep;
    end
  end
    
  if i == 200
    info = 0;
    fprintf('get_ep_min_metam warning: no convergence for f in 200 steps\n')
  else
    info = 1;
    %fprintf(['get_ep_min_metam warning: successful convergence for f in ', num2str(i), ' steps\n'])
  end
