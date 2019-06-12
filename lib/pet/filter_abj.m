%% filter_abj
% filters for allowable parameters of standard DEB model with acceleration (abj)

%%
function [filter, flag] = filter_abj(p)
% created 2014/01/22 by Bas Kooijman; modified 2015/03/17, 2015/06/19, 2015/07/29 by Goncalo Marques
% modified 2015/08/03 by starrlight

%% Syntax
% [filter, flag] = <../filter_abj.m *filter_abj*> (p)

%% Description
% Checks if parameter values are in the allowable part of the parameter
%    space of standard DEB model with acceleration (abj)
% Meant to be run in the estimation procedure
%
% Input
%
% * par: structure with parameters (see below)
%  
% Output
%
% * filter: 0 for hold, 1 for pass
% * flag: indicator of reason for not passing the filter
%
%     0: parameters pass the filter
%     1: some parameter is negative
%     2: some kappa is larger than 1
%     3: growth efficiency is larger than 1
%     4: maturity levels do not increase during life cycle
%     5: puberty cannot be reached
%     6: birth cannot be reached

%% Remarks
% The theory behind boundaries is discussed in <http://www.bio.vu.nl/thb/research/bib/LikaAugu2013.html *LikaAugu2013*>.

  filter = 0; flag = 0; % default setting of filter and flag
  
  parvec = [p.z; p.kap_X; p.kap_P; p.v; p.kap; p.p_M; p.E_G; p.k_J; p.E_Hb; p.E_Hj; p.E_Hp; p.kap_R; p.h_a; p.T_A];
  
  if sum(parvec <= 0) > 0 % all pars must be positive
    flag = 1;
    return;
  elseif p.p_T < 0
    flag = 1;
    return;
  end

  if p.E_Hb >= p.E_Hj % maturity at birth, metam
    flag = 4;
    return;
  end

  if p.E_Hj >= p.E_Hp % maturity at metam, puberty
    flag = 4;
    return;
  end

  parvec = [p.kap; p.kap_R; p.kap_X; p.kap_P];
  
  if sum(parvec >= 1) > 0 
    flag = 2;
    return;
  end

  % compute and unpack c (compound parameters)
  c = parscomp_st(p);

  if c.kap_G >= 1 % growth efficiency
    flag = 3;    
    return;
  end

  if ~reach_birth(c.g, c.k, c.v_Hb, p.f) % constraint required for reaching birth
    flag = 6;    
    return;
  end
  
  pars_lb = [c.g; c.k; c.v_Hb];
  [l_b, info] = get_lb(pars_lb);  
  
  pars_tj = [c.g; c.k; c.l_T; c.v_Hb; c.v_Hj; c.v_Hp]; % compose parameter vector for get_tj
  [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rj, rB, info] = get_tj(pars_tj, 1, l_b);
  if info ~= 1
    flag = 5;
    return
  end

  s_M = l_j/ l_b;                          % -, acceleration factor
  if c.k * c.v_Hp >= p.f^3 * s_M^3 % constraint required for reaching puberty
    flag = 5;    
    return;
  end
  
  filter = 1;
