%% get_eb_min_G
% scaled reserve for which growth ceases at birth

%%
function [eb lb info] = get_eb_min_G (p, lb0)
  %% created 2013/08/15 by Bas Kooijman
  
  %% Syntax
  % [eb lb info] = <../get_eb_min_G.m *get_eb_min_G*> (p, lb0)
  
  %% Description
  % Obtains the scaled reserve at birth for growth ceasing at birth. 
  % For lower eb than the result, the embryo shrinks before birth. 
  %
  % Input
  %
  % * p: 3-vector with parameters: g, k, v_H^b see get_lb
  % * lb0: optional scalar with initial estimate for lb
  %  
  % Output
  %
  % * eb: scalar with e_b such that growth ceases at birth
  % * lb: scalar with l_b such that growth ceases at birth
  % * info: scalar with 1 for success and 0 otherwise
  
  %% Remarks
  % The theory behind get_eb_min is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.html the comments for DEB3>.
  % Cf <get_ep_min.html *get_ep_min*>  for minimum e to reach puberty
  % Cf <get_eb_min_R.html *get_eb_min_R*> for e at which maturation ceases at birth
  
  %% Example of use
  % get_eb_min_G([.1 .3 .01])
    
  % unpack par
  g = p(1); k = p(2); vHb = p(3);

  if exist('lb0', 'var') == 0
    lb0 = 0.5;
  end    

  [lb f_val info] = fzero(@fnget_lb_min, lb0, [], g, k, vHb);
  eb = lb;
  
  if info ~= 1
    fprintf('Warning from get_eb_min_G: no convergence for eb_min_G')
  end
end

% subfunctions

function fn = fnget_lb_min(lb, g, k, vHb)
  lb = max(1e-10, min(1-1e-10, lb));
  xb = g/ (g + lb);
  [x y] = ode45(@dydx, [1e-10; xb], 0, [], g, k, xb, lb);
  fn = y(end) - g * xb * vHb/ lb^3;
end

function dy = dydx(x, y, g, k, xb, lb)
  l = 1/((xb/ x)^(1/3)/ lb - beta0(x, xb)/ 3/ g/ x^(1/3));
  dy = g + l - y * (k - x) * l/ (1 - x)/ g/ x;
end
          