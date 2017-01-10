%% get_EMJHG
% gets cumulative energy investment to endpoints at birth

%%
function [EMJHG uE0 info] = get_EMJHG(p, eb)
  % created at 2011/01/19 by Bas Kooijman
  
  %% Syntax
  % [EMJHG E0 info] = <../get_EMJHG.m *get_EMJHG*> (p, eb)
  
  %% Description
  % Gets cumulative energy investment to somatic and maturity maintenance, growth and maturation at birth
  % If p(5) is specified, growth is splitted in dissipated and fixed in structure
  %
  % Input
  %
  % * p: 4 or 5-vector with parameters: g, k, vHb, kap, kap_G
  % * eb: optional scalar with scaled reserve density at birth (default eb = 1)
  %
  % Output
  %
  % * EMJHG: (n,5 or 6)-matrix with in the columns fractions of initial reserve at birth
  %
  %    - reserve left at birth, cumulatively allocated to som maint, mat maint, maturation, growth 
  %
  % * uE0: n-vector with scaled initial reserve
  % * info: n-vector with 1's for success and 0's otherwise for uE0 and tau_b-computations
  
  %% Remark
  % Called by <birth_pie.html *birth_pie*> for graphical presentation

  %  unpack p
  g   = p(1);
  k   = p(2); 
  vHb = p(3);
  kap = p(4);

  if length(p) > 4
    kap_G = p(5);
  end

  if exist('eb','var') == 0
    eb = 1; % maximum value as juvenile
  end
  n = length(eb);
  EMJHG = zeros(n,5); info = ones(n);

  for i = 1:n
    [uE0(i), lb, info_ue0] = get_ue0(p, eb(i));
    [tb lb info_tb] = get_tb(p, eb(i), lb);
    [t ulhMJ] = ode45(@dget_ulhMJ, [0;tb], [uE0(i); 0; 0; 0; 0], [], g, kap, k);
    EMJHG(i, :) = [ulhMJ(end,[1 4 5]), vHb * (1 - kap), kap * lb^3];
    EMJHG(i, :) = EMJHG(i, :)/ sum(EMJHG(i, :));
    info(i) = min(info_ue0, info_tb);
  end

  if exist('kap_G','var') == 1
    EMJHG = [EMJHG(:,1:4), EMJHG(:,5) * [ (1 - kap_G), kap_G]];
  end

end

% subfunction

function dulhMJ = dget_ulhMJ(t, ulhMJ, g, kap, k)
  % change in state variables during embryo stage
  % called by get_EMJG to get energy fractions at birth
  
  % unpack state variables
  u = ulhMJ(1);  % u_E scaled reserve
  l = ulhMJ(2);  % l, scaled length
  h = ulhMJ(3);  % u_H, scaled maturity
  
  l2 = l * l; l3 = l2 * l; l4 = l3 * l;

  du = - u * l2 * (g + l)/ (u + l3);                   % d/dt u_E 
  dl = (g * u - l4)/ (u + l3)/ 3;                      % d/dt l
  dh = (1 - kap) * u * l2 * (g + l)/ (u + l3) - k * h; % d/dt u_H
  dM = kap * l3;                                       % d/dt u_M, som maint
  dJ = k * h;                                          % d/dt u_J, mat maint

  % pack derivatives
  dulhMJ = [du; dl; dh; dM; dJ];
end