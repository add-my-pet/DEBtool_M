%% filter_hex
% filters for allowable parameters of holometabolous insect DEB model

%%
function [filter flag] = filter_hex(par, chem)
% created 2015/06/04 by Goncalo Marques; modified 2015/06/19 by Goncalo Marques

%% Syntax
% [filter flag] = <../filter_hex.m *filter_hex*> (par, chem)

%% Description
% Checks if parameter values are in the allowable part of the parameter
%    space of standard DEB model without acceleration
% Meant to be run in the estimation procedure
%
% Input
%
% * par: structure with parameters (see below)
% * chem: structure with biochemical parameters
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
%     4: birth cannot be reached

%% Remarks
%  The theory behind boundaries is discussed in 
%    <http://www.bio.vu.nl/thb/research/bib/LikaAugu2013.html LikaAugu2013>.

  filter = 0; flag = 0; % default setting of filter and flag
  
  % unpack par, chem
  v2struct(par); v2struct(chem);

  parvec = [z; v; kap; p_M; E_G; k_J; E_Hb; s_j; E_He; kap_R; h_a; s_G];
  
  if sum(parvec <= 0) > 0 % all pars must be positive
    flag = 1;
    return;
  elseif p_T < 0
    flag = 1;
    return;
  end

  if f > 1
    flag = 2;
    return;
  end

  parvec = [kap; kap_R];
  
  if sum(parvec >= 1) > 0 
    flag = 2;
    return;
  end

  % compute and unpack cpar (compound parameters)
  cpar = parscomp_st(par, chem);
  v2struct(cpar);

  if kap_G >= 1 % growth efficiency
    flag = 3;    
    return;
  end

  if ~reach_birth(g, k, v_Hb, f) % constraint required for reaching birth
    flag = 6;    
    return;
  end

  filter = 1;
