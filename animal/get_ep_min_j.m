%% get_ep_min_j
% Gets scaled reserve density at which maturation ceases at puberty in case of acceleration

%%
function [ep, info] = get_ep_min_j(p)
  % created 2015/09/16 by Bas Kooijman, Dina Lika; 
  % modified 2015/10/23 by Goncalo Marques; 
  % modified 2016/04/26 by Bas Kooijman
  
  %% Syntax
  % [ep, info] = <..get_ep_min_j.m *get_ep_min_j*> (p)
  
  %% Description
  % Obtains the scaled reserve at birth for growth and maturation ceases at puberty in case of acceleration. 
  % It can be seen as the lower viable scaled reserve density for reproduction. Cf get_eb_min.
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
  
  % bisection method with lower boundary set by get_lj
  ep_range = [0 1]; ep = 0.5;    % set initial value
  while (ep_range(2) - ep_range(1)) > 1e-5
    F = fnget_ep_min_j(ep, p);   % get loss function
    if isempty(F) || F < 0       % lower boundary
      ep_range(1) = ep;
      ep = (ep + ep_range(2))/2; % set new value
    else                         % upper boundary
      ep_range(2) = ep;       
      ep = (ep + ep_range(1))/2; % set new value
    end
  end
  ep = sum(ep_range)/2;
    
  if F > 0.05
    fprintf(['Warning from get_ep_min_j: loss function is ', num2str(F), '\n'])
    info = 0;
  end
  
end

% subfunction
function F = fnget_ep_min_j(f, p)
  [l_j, l_p, l_b] = get_lj(p, f);
  F = f * (f - p(3))^2 * (l_j/ l_b)^3 - p(2) * p(6);
end