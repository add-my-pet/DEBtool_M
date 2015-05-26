%% get_lp
% Gest scaled length at puberty

%%
function [lp, lb, info] = get_lp (p, f, lb0)
  % created at 2008/06/04 by Bas Kooijman, 
  % modified 2014/03/03 Starrlight Augustine, 2015/01/18
  
  %% Syntax
  % [lp, lb, info] = <../get_lp.m *get_lp*> (p, f, lb0)
  
  %% Description
  % Obtains scaled length at puberty at constant food density. 
  % If scaled length at birth (second input) is not specified, it is computed (using automatic initial estimate); 
  % If it is specified, however, is it just copied to the (second) output. 
  % Food density is assumed to be constant.
  %
  % Input
  %
  % * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
  % * f: optional scalar with scaled functional responses (default 1)
  % * lb0: optional scalar with scaled length at birth
  %
  %      or optional 2-vector with scaled length, l, and scaled maturity, vH
  %      for a juvenile that is now exposed to f, but previously at another f
  %      lb0 should be specified for foetal development
  %  
  % Output
  %
  % * lp: scalar with scaled length at puberty
  % * lb: scalar with scaled length at birth
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % Similar to <get_lp1.html *get_lp1*>, which uses root finding, rather than integration
  % Function <get_lp_foetus.html *get_lp_foetus*> does the same, but then for foetal development. 

  %% Example of use
  % get_lp([.5, .1, .1, .01, .2])
  
  % unpack pars
  g   = p(1); % -, energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  vHp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}

  if ~exist('f', 'var')
    f = 1; 
  elseif  isempty(f)
    f = 1; 
  end
  li = f - lT; % -, scaled ultimate length
  
  if ~exist('lb0', 'var')
      lb0 = [];
      [lb, info] = get_lb([g; k; vHb], f);
  elseif isempty(lb0)
      [lb, info] = get_lb([g; k; vHb], f);
  elseif length(lb0) < 2
      info = 1;
      lb = lb0;
  else % for a juvenile of length l and maturity vH
      l = lb0(1); vH = lb0(2); % juvenile now exposed to f
      [lb, info] = get_lb([g; k; vHb], f);
  end
  
  % d/d tau vH = b2 l^2 + b3 l^3 - k vH
  b3 = 1 / (1 + g / f); 
  b2 = f - b3 * li;
  % vH(t) = - a0 - a1 exp(- rB t) - a2 exp(- 2 rB t) - a3 exp(- 3 rB t) +
  %         + (vHb + a0 + a1 + a2 + a3) exp(-kt)
  a0 = - (b2 + b3 * li) * li^2/ k; % see get_lp1
  if vHp > -a0      % vH can only reach -a0
    lp = [];
    info = 0;
    fprintf('Warning in get_lp: maturity at puberty cannot be reached \n');
    return
  end
  
  if k == 1
    lp = vHp^(1/3);
  elseif length(lb0) < 2
    if f * lb^2 * (g + lb) < vHb * k * (g + f) 
       lp = [];
       info = 0;
       fprintf('Warning in get_lp: maturity does not increase at birth \n');
    else
       [vH lbp] = ode45(@dget_l_ISO, [vHb; vHp],lb, [], k, lT, g, f, 1); 
       lp = min(li - 1e-4, lbp(end));
    end
  else % for a juvenile of length l and maturity vH
    if f * l^2 * (g + l) < vH * k * (g + f) 
       lp = [];
       info = 0;
       fprintf('Warning in get_lp: maturity does not increase initially \n');
    elseif vH + 1e-4 < vHp 
      [vH lbp] = ode45(@dget_l_ISO, [vH; vHp],l, [], k, lT, g, f, 1); 
      lp = lbp(end);
    else
      lp = l;
      info = 0;
      fprintf('Warning in get_lp: initial maturity exceeds puberty threshold \n')
    end
  end
  