%% get_lp1_foetus
% Obtains scaled length at puberty for foetal development

%%
function [lp, lb, info] = get_lp1_foetus (p, f, lb0)
  %  created at 2011/04/11 by Bas Kooijman, modified 2014/03/08, 2015/01/18
  
  %% Syntax
  % [lp, lb, info] = <../get_lp1_foetus.m *get_lp1_foetus*> (p, f, lb0)
  
  %% Description
  % Obtains scaled length at puberty at constant food density in the case of foetal development.
  % Food density is assumed to be constant.
  %
  % Input
  %
  % * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
  % * f: optional scalar with scaled functional responses (default 1)
  % * lb0: optional scalar with scaled length at birth
  %  
  % Output
  %
  % * lp: scalar with scaled length at puberty
  % * lb: scalar with scaled length at birth
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % Function <get_lp1.html *get_lp1*> does the same, but then for egg development. 

  %% Example of use
  % get_lp1_foetus([.5, .1, .1, .01, .2])

  % unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  vHp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}

  if ~exist('f', 'var')
    f = 1; 
  elseif  isempty(f)
    f = 1; 
  end
  
  if exist('lb0','var') == 0
      lb0 = [];
  end
  if isempty(lb0)
      [lb info] = get_lb_foetus([g; k; vHb], f);
  else
      info = 1;
      lb = lb0;
  end
      
  if k == 1
    lp = vHp^(1/3);
  else
    if f * lb^2 * (g + lb) < vHb * k * (g + f) 
      lp = [];
      info = 0;
      fprintf('Warning in get_lp_foetus: maturity goes not increase at birth \n');
    else
      [vH lbp] = ode45(@dget_l_ISO, [vH; vHp],l, [], k, lT, g, f, 1); 
      lp = lbp(end);
    end
  end
end
