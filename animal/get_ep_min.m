%% get_ep_min
% Gets scaled reserve density at which maturation ceases at puberty

%%
function ep = get_ep_min(p)
  %% created 2009/01/15 by Bas Kooijman; modified 2009/10/27
  
  %% Syntax
  % ep = <../get_ep_min.m *get_ep_min*> (p)
  
  %% Description
  % Obtains the scaled reserve at birth for growth and maturation ceases at puberty. 
  % It can be seen as the lower viable scaled reserve density for reproduction. 
  %
  % Input
  %
  % * p: 3-vector with parameters: k lT v_H^p (cf <get_lp.html *get_lp*>)
  %  
  % Output
  %
  % * ep: scalar with e_p such that growth and maturation cease at puberty
  
  %% Remarks
  % The theory behind get_ep_min is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.pdf the comments for DEB3, section 2.6.3>.
  % See <get_ep_min_metam.html *get_ep_min_metam*> for acceletaton
  % See <get_eb_min.html *get_eb_min*> for minimum e at birth.

  %% Example of use
  % get_ep_min([1 0 .1])
    
  k = p(1); lT = p(2); vHp = p(3);
  
  if lT == 0
    ep = (k * vHp)^(1/3);
    return
  end
  
  ep = roots3([1; -2 * lT; lT^2; - k * vHp], 2); ep = ep(ep>0);
  if length(ep) ~= 1  
     fprintf(['Warning in get_ep_min: ', num2str(length(ep)), ' solutions\n']);
  end
