%% get_lb3
% Obtains scaled length at birth, given the scaled reserve density at birth

%%
function [lb info] = get_lb3 (p, eb, lb0)
  % created 2013/08/15 by Bas Kooijman, modified 2015/01/18
  %
  %% Description
  % Obtains scaled length at birth, given the scaled reserve density at birth. 
  %
  % Input
  %
  % * p: 3-vector with parameters: g, k, v_H^b (see below)
  % * eb: optional scalar with scaled reserve density at birth (default eb = 1)
  % * lb0: optional scalar with initial estimate for scaled length at birth (default lb0: lb for k = 1)
  %  
  % Output
  %
  % * lb: scalar with scaled length at birth 
  % * info: indicator equals 1 if successful, 0 otherwise

  %% Remarks
  % Like <get_lb2.html *get_lb2*>, but uses another numerical procedure.

  % unpack par
  g = p(1);   % g = [E_G] * v/ kap * {p_Am}, energy investment ratio
  k = p(2);   % k = k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  vHb = p(3); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = M_H^b/ {J_EAm}

  if ~exist('lb0', 'var')
    lb0 = 0.5;
  end    

  xb = g/ (g + eb);
  [lb f_val info] = fzero(@fnget_lb3, lb0, [], g, k, vHb, xb);
end

% subfunctions

function fn = fnget_lb3(lb, g, k, vHb, xb)
  [x y] = ode45(@dydx, [1e-10; xb], 0, [], g, k, lb, xb);
  fn = y(end) - g * xb * vHb/ lb^3;
end

function dy = dydx(x, y, g, k, lb, xb)
  l = 1/((xb/ x)^(1/3)/ lb - beta0(x, xb)/ 3/ g/ x^(1/3));
  dy = g + l - y * (k - x) * l/ (1 - x)/ g/ x;
end
          