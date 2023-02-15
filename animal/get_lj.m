%% get_lj
% Gets scaled length at metamorphosis

%%
function [lj, lp, lb, info] = get_lj(p, f, lb0)
  %  created at 2010/02/10 by Bas Kooijman, 
  %  modified 2014/03/03 Starrlight Augustine, 2015/01/18, 2023/02/15 Bas Kooijman;
  
  %% Syntax
  % [lj, lp, lb, info] = <../get_lj.m *get_lj*>(p, f, lb0)
  
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
  %     if p is a 5-vector, output lp is empty
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
  % Similar to <get_lj1.html get_lj1>, which uses root finding, rather than integration
  % Scaled length l = L/ L_m with L_m = kap {p_Am}/ [p_M] where {p_Am} is of embryo, 
  %  because the amount of acceleration is food-dependent so the value after metamorphosis is not a parameter.
  % {p_Am} and v increase between maturities v_H^b and v_H^j till
  %    {p_Am} l_j/ l_b  and v l_j/ l_b at metamorphosis.
  % After metamorphosis l increases from l_j till l_i = f l_j/ l_b - l_T.
  % Scaled length l can thus be larger than 1.
  % See <get_lj_foetus.html *get_lj_foetus*> for foetal development. 
  
  %% Example of use
  % get_lj([.5, .1, .1, .01, .2, .3])
  
  n_p = length(p);

  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm} = E_H^b/ {p_Am}
  vHj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_H^j = M_H^j/ {J_EAm} = E_H^j/ {p_Am}
  if n_p > 5
    vHp = p(6); % v_H^p = U_H^j g^2 kM^3/ (1 - kap) v^2; U_B^j = M_H^j/ {J_EAm}
  end

  if ~exist('f', 'var')
    f = 1;
  elseif  isempty(f)
    f = 1;
  end
  
  % get lb
  if ~exist('lb0', 'var')
    lb0 = [];
  end
  if isempty(lb0)
    [lb, info] = get_lb([g; k; vHb], f, lb0);
  else
    info = 1;
    lb = lb0;
  end

  if lT > f - lb % no growth is possible at birth
    lj = []; lp = []; 
    info = 0;
    return
  end

  % no acceleration
  if vHb == vHj 
    if n_p == 5 % no puberty specified
      [lb, info] = get_lb(p([1 2 4]), f, lb0);
      lj = lb; lp = []; 
      return
    else % puberty specified
      [lp, lb, info] = get_tp(p([1 2 3 4 6]), f, lb0);
      lj = lb; 
      return
    end
  end

  % get lj
  options = odeset('Events',@end_of_accel, 'AbsTol',1e-9, 'RelTol',1e-9); 
  [t, vHl] = ode45(@dget_l_V1_t, [0; 1e6], [vHb; lb], options, k, lT, g, f, lb, vHj); 
  lj = vHl(end,2); sM = lj/ lb;
  
  % get lp
  if n_p > 5
    %options = odeset('Events',@puberty, 'AbsTol',1e-9, 'RelTol',1e-9); 
    %[t, vHl] = ode45(@dget_l_ISO_t, [0; 1e6], [vHj; lj], options, k, lT, g, f, sM, vHp); lp = vHl(end,2);
    % options = odeset('AbsTol',1e-8, 'RelTol',1e-8); 
    [vH, l] = ode45(@dget_l_ISO, [vHj; vHp], lj, [], k, lT, g, f, sM); lp = l(end);
  else
    lp = [];
  end
end

% end_of_accel
function [value,isterminal,direction] = end_of_accel(t, vHl, k, lT, g, f, lb, vHj)
  value = vHl(1) - vHj;  % trigger 
  isterminal = 1;    % terminate after event
  direction  = [];   % get all the zeros
end

% puberty
function [value,isterminal,direction] = puberty(t, vHl, k, lT, g, f, sM, vHp)
  value = vHl(1) - vHp;  % trigger 
  isterminal = 1;    % terminate after event
  direction  = [];   % get all the zeros
end

