%% get_lp1
% Gest scaled length at puberty

%%
function [lp, lb, info] = get_lp1 (p, f, l0)
  % created at 2008/06/04 by Bas Kooijman, 
  % modified 2014/03/03 Starrlight Augustine, 2015/02/17 Bas Kooijman & Goncalo Marques, 2015/02/26 Goncalo Marques
  
  %% Syntax
  % [lp, lb, info] = <../get_lp1.m *get_lp1*> (p, f, l0)
  
  %% Description
  % Obtains scaled length at puberty at constant food density. 
  % If initial scaled length (third input) is not specified, it is computed (using automatic initial estimate); 
  % If it is specified, however, is it just copied to the (second) output. 
  % Food density is assumed to be constant.
  %
  % Input
  %
  % * p: 5-vector with parameters: g, k, l_T, v_H^0, v_H^p 
  %      or 6-vector with parameters: g, k, l_T, v_H^0, v_H^p, sM
  % * f: optional scalar with scaled functional responses (default 1)
  % * l0: optional scalar with scaled initial length (birth, metamosphosis or other)
  %
  %      or optional 2-vector with scaled length, l, and scaled maturity, vH
  %      for a juvenile that is now exposed to f, but previously at another f
  %      l0 should be specified for foetal development
  %  
  % Output
  %
  % * lp: scalar with scaled length at puberty
  % * lb: scalar with scaled length at the begining 
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % Element p(4) contains scaled murity at birth if l0 is absent or a scalar, or scaled maturity at zero if l0 is of length 2.
  % Similar to <get_lp.html *get_lp*>, which uses integration, rather than root finding
  % Function <get_lp1_foetus.html *get_lp1_foetus*> does the same, but then for foetal development. 

  %% Example of use
  % get_lp1([.5, .1, .1, .01, .2])

  if exist('fzero', 'file') ~= 2    % if there is no fzero use dynamic equations to determine lp
    [lp, lb, info] = get_lp(p, f, l0);
    return;
  end
  
  % unpack pars
  g   = p(1); % -, energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]
  vH0 = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  vHp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = M_H^p/ {J_EAm} = E_H^p/ {p_Am}
  if length(p) == 6
    sM = p(6);
  else
    sM = 1;
  end
  
  if ~exist('f', 'var')  || isempty(f)
    f = 1; 
  end

  if ~exist('l0', 'var') || isempty(l0)  % if l0 does not exist assume l at birth for an egg
      [lb, info] = get_lb([g; k; vH0], f);
  elseif length(l0) < 2
      info = 1;
      lb = l0;
  else % for a juvenile of length l and maturity vH
      l = l0(1); vH0 = l0(2); % juvenile now exposed to f
      [lb, info] = get_lb([g; k; vH0], f);
  end
  
  rB = g / 3 / (f + g); % -, scaled von Bertalanffy growth rate
  li = sM * (f - lT);   % -, scaled ultimate length
  ld = li - lb;         % -, scaled length
  % d/d tau vH = b2 l^2 + b3 l^3 - k vH
  b3 = 1 / (1 + g / f); 
  b2 = f * sM - b3 * li;
  % vH(t) = - a0 - a1 exp(- rB t) - a2 exp(- 2 rB t) - a3 exp(- 3 rB t) +
  %         + (vHb + a0 + a1 + a2 + a3) exp(-kt)
  a0 = - (b2 + b3 * li) * li^2/ k;
  a1 = - li * ld * (2 * b2 + 3 * b3 * li)/ (rB - k);
  a2 = ld^2 * (b2 + 3 * b3 * li)/ (2 * rB - k);
  a3 = - b3 * ld^3 / (3 * rB - k);

  if vHp > -a0      % vH can only reach -a0
    lp = [];
    info = 0;
    fprintf('Warning in get_lp: maturity at puberty cannot be reached \n');
  elseif vH0 > vHp  % intial maturity is already higher than maturity at puberty
    lp = l;
    info = 0;
    fprintf('Warning in get_lp: initial maturity exceeds puberty threshold \n')
  elseif k == 1
    lp = vHp^(1/3);
  else
    lp = fzero(@fnget_lp, [lb, li], [], a0, a1, a2, a3, lb, li, k, rB, vH0, vHp);
  end
  