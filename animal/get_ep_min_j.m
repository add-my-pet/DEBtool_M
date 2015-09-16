%% get_ep_min_j
% Gets scaled reserve density at with maturation ceases at puberty in case of acceleration

%%
function [ep, info] = get_ep_min_j(p)
  % created 2015/09/16 by Bas Kooijman
  
  %% Syntax
  % [ep, info] = <..get_ep_min_j.m *get_ep_min_j*> (p)
  
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
  
  [l_j, l_p, l_b] = get_lj(p, 1); ep_0 = p(3) + l_p * l_b/ l_p;
  %[ep, fval, info] = fzero(@fnget_ep_min_j, ep_0, [], p);
  par = [[ep_0; p'], [1;0;0;0;0;0;0]];
  ep = nrregr('fnget_ep_min_j', par, [0 0 0]); ep = ep(1);
  
end
