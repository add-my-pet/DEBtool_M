%% get_eb_min_R
%

%%
function [eb lb info] = get_eb_min_R (p, lb0)
  % created 2013/08/15 by Bas Kooijman
  
  %% Syntax
  % [eb lb info] = <../get_eb_min_R.m *get_eb_min_R*> (p, lb0)
  
  %% Description
  % Obtains the scaled reserve at birth for maturation ceasing at birth. 
  % It can be seen as the lower viable scaled reserve density for embryo development. 
  %
  % Input
  %
  % * p: 3-vector with parameters: g, k, v_H^b see get_lb
  % * lb0: optional scalar with initial estimate for lb
  %  
  % Output
  %
  % * eb: scalar with e_b such that maturation ceases at birth
  % * lb: scalar with l_b such that maturition ceases at birth
  % * info: scalar with 1 for success and 0 otherwise
  
  %% Remarks
  % The theory behind get_eb_min is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.html the comments for DEB3>.
  % If k < 1, shrinking can occur at birth if maturation just ceases
  % Cf <get_eb_min_G.html *get_eb_min_G*> for e at which growth ceases at birth

  %% Example of use
  % get_eb_min_R([.1 .3 .01])

  % unpack par
  g = p(1); k = p(2); vHb = p(3);

  if exist('lb0', 'var') == 0
    lb0 = .5;
  end    

  [lb f_val info] = fzero(@fnget_lb_min_R, lb0, [], g, k, vHb);
  lb2 = lb * lb; lb3 = lb2 * lb;
  eb = g * k * vHb/ (lb3 + g * lb2 - k * vHb);
end

% subfunctions

function fn = fnget_lb_min_R(lb, g, k, vHb)
  lb = max(1e-10, min(1-1e-10, lb));
  lb2 = lb * lb; lb3 = lb2 * lb;
  xb = (lb3 + g * lb2 - k * vHb)/ (lb3 + g * lb2);
  
  [x y] = ode23s(@dydx, [1e-10; xb], 0, [], g, k, lb, xb);
  fn = y(end) - g * xb * vHb/ lb3;
end

function dy = dydx(x, y, g, k, lb, xb)
  l = max(1e-8, 1/((xb/ x)^(1/3)/ lb - beta0(x, xb)/ 3/ g/ x^(1/3)));
  dy = min(100, g + l - y * (k - x) * l/ (1 - x)/ g/ x);
end
          