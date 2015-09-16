%% get_lj1
% Gets scaled length at metamorphosis

%%
function [lj, lp, lb, info] = get_lj1(p, f, lb0)
  % created at 2010/02/10 by Bas Kooijman, 
  % modified 2014/03/03 Starrlight Augustine, 2015/02/17 Bas Kooijman & Goncalo Marques
  
  %% Syntax
  % [lj, lp, lb, info] = <../get_lj1.m *get_lj1*>(p, f, lb0)
  
  %% Description
  % Type M-acceleration: Isomorph, but V1-morph between vHb and vHj
  % This routine obtaines scaled length at metamorphosis lj given scaled muturity at metamorphosis vHj. 
  % The theory behind get_lj, is discussed in the comments to DEB3. 
  % If scaled length at birth (third input) is not specified, it is computed (using automatic initial estimate); 
  %  if it is specified. however, is it just copied to the (third) output. 
  % The code assumes vHb < vHj < vHp (see first input). 
  %
  % Input
  %
  % * p: 6-vector with parameters: g, k, l_T, v_H^b, v_H^j, v_H^p
  %
  %      if p is a 5-vector, output lp is empty
  %
  % * f: optional scalar with scaled functional responses (default 1)
  % * lb0: optional scalar with scaled length at birth
  %
  % Output
  %
  % * lj: scalar with scaled length at metamorphosis
  % * lp: scalar with scaled length at puberty
  % * lb: scalar with scaled length at birth
  % * info: indicator equals 1 if successful
  
  %% Remarks
  % Similar to <get_lj.html *get_lj*>, which uses integration rather than root finding
  % Scaled length l = L/ L_m with L_m = kap {p_Am}/ [p_M] where {p_Am} is of embryo, 
  %  because the amount of acceleration is food-dependent so the value after metamorphosis is not a parameter.
  % {p_Am} and v increase between maturities v_H^b and v_H^j till
  %    {p_Am} l_j/ l_b  and v l_j/ l_b at metamorphosis.
  % After metamorphosis l increases from l_j till l_i = f l_j/ l_b - l_T.
  % Scaled length l can thus be larger than 1.
  % See <get_lj_foetus.html *get_lj_foetus*> for foetal development. 
  
  %% Example of use
  % get_lj1([.5, .1, .1, .01, .2, .3])
  
  if exist('fzero', 'file') ~= 2    % if there is no fzero use dynamic equations to determine lj
    [lj, lp, lb, info] = get_lj(p, f, lb0);
    return;
  end

  n_p = length(p);

  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  vHj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_H^j = M_H^j/ {J_EAm} = E_H^j/ {p_Am}
 
  if ~exist('f', 'var')  || isempty(f)
    f = 1;
  end
  
  % get lb
  if ~exist('lb0', 'var') || isempty(lb0)
    [lb info] = get_lb([g; k; vHb], f, []);
  else
    info = 1;
    lb = lb0;
  end

  if lT > f - lb % no growth is possible at birth
    lj = []; lp = []; 
    info = 0;
    return
  end

  if vHb == vHj  % no acceleration
    lj = lb;
    if n_p == 5  % no puberty specified
      [lb, info] = get_lb(p([1 2 4]), f, lb0);
      lp = []; 
    else         % puberty specified
      [lp, lb, info] = get_lp(p([1 2 3 4 6]), f, lb0);
    end
  
  else           % with acceleration

    % get lj
    sM = fzero(@fnget_sM, (vHj/ vHb)^(1/3), [], f, lb, g, k, lT, vHb, vHj);
    lj = sM * lb;
  
    % get lp  
    if n_p > 5
      [lp, lj, info] = get_lp1 ([p([1 2 3 5 6]), sM], f, lj);
    else
      lp = [];
    end
  end
end
