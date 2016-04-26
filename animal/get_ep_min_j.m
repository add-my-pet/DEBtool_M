%% get_ep_min_j
% Gets scaled reserve density at which maturation ceases at puberty in case of acceleration

%%
function [ep, info] = get_ep_min_j(p)
  % created 2015/09/16 by Bas Kooijman, Dina Lika; modified 2015/10/23 by Goncalo Marques
  
  %% Syntax
  % [ep, info] = <..get_ep_min_j.m *get_ep_min_j*> (p)
  
  %% Description
  % Obtains the scaled reserve at birth for growth and maturation ceases at puberty in case of acceleration. 
  % It can be seen as the lower viable scaled reserve density for reproduction. Cf get_eb_min.
  % In the case the eb minimum already causes reproduction to exist, it returns ep = eb and info = 2. 
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
  % See <get_ep_min.html *get_ep_min*> for without acceleration
  % See <get_eb_min.html *get_eb_min*> for minimum e at birth.
  % Solves f for which k v_Hp = f (f - lT) s_M^3 with s_M = l_j/ l_b

  %% Example of use
  % get_ep_min_j([.1 1 0 .001 0.01 .1])
    
  info = 1;
  % find initial value
  [l_j, l_p, l_b] = get_lj(p, 1); s_M = l_j/ l_b;
  c = p(6)/ s_M^3; ep_0 = (sqrt(p(3)^2 + 4 * c) - p(3))/ 2;  
  
  % bisection method with boundary set by get_lj
  ep_range = [0 1]; i = 1; n = 50;
  while (ep_range(2) - ep_range(1)) > 1e-5 && i < n
    F = fnget_ep_min_j(ep_0, p);
    if isempty(F) || F < 0
      ep_range(1) = ep_0;
      ep_0 = (ep_0 + ep_range(2))/2;
    else
      ep_range(2) = ep_0;
      ep_0 = (ep_0 + ep_range(1))/2;
    end
    i = i + 1;
  end
  ep = sum(ep_range)/2;
    
  if F > 1e-2
    fprintf(['Warning from get_ep_min_j: loss function is ', num2str(F), '\n'])
  end
  if i >= n
    info = 0;
  end
  
end

% subfunction
function F = fnget_ep_min_j(f, p)
  [l_j, l_p, l_b] = get_lj(p, f);
  F = f * (f - p(3))^2 * (l_j/ l_b)^3 - p(2) * p(6);
end