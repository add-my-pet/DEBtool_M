%% get_ls
% Obtains scaled length at start and end of acceleration at constant food density. 

%%
function [ls, lj, lp, lb, info] = get_ls(p, f, lb0)
  % created at 2011/07/21 by Bas Kooijman, 
  % modified 2014/03/03 Starrlight Augustine, 2015/01/18 Bas Kooijman
  
  %% Syntax
  % [ls, lj, lp, lb, info] = <../get_ls *get_ls*>(p, f, lb0)
  
  %% Description
  % Obtains scaled length at start and end of acceleration at constant food density. 
  % Isomorph, but V1-morph between vHs and vHj, with vHb> vHs> vHj > vHp.
  % If scaled length at birth (third input) is not specified, it is computed (using automatic initial estimate); 
  % if it is specified. however, is it just copied to the (third) output.
  %
  % Input
  %
  % * p: 7-vector with parameters: g, k, l_T, v_H^b, v_H^s, v_H^j, v_H^p
  % * f: optional scalar with scaled functional responses (default 1)
  % * lb0: optional scalar with scaled length at birth
  %  
  % Output
  %
  % * ls: scalar with scaled length at start of V1-stage
  % * lj: scalar with scaled length at end of V1-stage
  % * lp: scalar with scaled length at puberty (start reprod of iso-stage)
  % * lb: scalar with scaled length at birth (start feeding of iso-stage)
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % The start of the V1-morphic stage is marked by an event called s, and the end by an event called j. 
  % This routine obtaines scaled length at s, ls, and j, lj given scaled muturity at s, cHs, and j, vHj. 
  % The theory behind get_ls, is discussed in the <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.pdf comments to DEB3>. 
  % Scaled length l = L/ L_m with L_m = kap {p_Am}/ [p_M] where {p_Am} is of embryo
  % {p_Am} and v increase between maturities v_H^s and v_H^j till
  % {p_Am} sM and v sM with sM = l_j/ l_s after metamorphosis after metamorphosis l increases from l_j till l_i = f l_j/ l_s - l_T
  % l can thus be larger than 1.
  
  %% Example of use
  % get_ls([.5, .1, .1, .01, .2, .25, .3])
  
  % unpack pars
  g   = p(1); % g = [E_G] * v/ kap/ {p_Am}, energy investment ratio
  k   = p(2); % k = k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % lT = {p_T}/[p_M], scaled heating length 
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}, scaled maturity at birth
  vHs = p(5); % v_H^s = U_H^s g^2 kM^3/ (1 - kap) v^2; U_H^s = M_H^s/ {J_EAm} = E_H^s/ {p_Am}, scaled maturity at start acceleration
  vHj = p(6); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^j = M_H^j/ {J_EAm} = E_H^j/ {p_Am}, scaled maturity at end acceleration
  vHp = p(7); % v_H^p = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}, scaled maturity at puberty

  if ~exist('f','var')
    f = 1; 
  elseif  isempty(f)
    f = 1; 
  end
  
  % get lb
  if ~exist('lb0', 'var') || isempty(lb0)
    lb0 = [];
    [lb info] = get_lb([g; k; vHb], f, lb0);
  else
    info = 1;
    lb = lb0;
  end

  if lT > f - lb
    ls = []; lj = [];  lp = [];
    info = 0;
    return
  end

  % get ls
  [vH ls] = ode45(@dget_l_ISO, [vHb; vHs], lb, [], k, lT, g, f, 1); 
  ls = ls(end); 

  % get lj
  [vH lj] = ode45(@dget_l_V1, [vHs; vHj], ls, [], k, lT, g, f, ls); 
  lj = lj(end); sM = lj/ ls;
  
  % get lp
  [vH lp] = ode45(@dget_l_ISO, [vHj; vHp], lj, [], k, lT, g, f, sM); 
  lp = lp(end);
