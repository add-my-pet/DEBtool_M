%% get_EMJHG_foetus
% gets cumulative energy investment to endpoints at birth for foetal development

%%
function [EMJHG uE0 info] = get_EMJHG_foetus(p, eb)
  % created at 2011/01/19 by Bas Kooijman 
  
  %% Syntax
  % [EMJHG E0 info] = <../get_EMJHG_foetus.m *get_EMJHG_foetus*> (p, eb)
  
  %% Description
  % Gets cumulative energy investment to somatic and maturity maintenance,
  % growth and maturation at birth for foetal development.
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
  %    -  reserve left at birth, cumulatively allocated to som maint, mat maint, maturation, growth 
  %   
  % * uE0: n-vector with total energy investment in foetus
  % * info: n-vector with 1's for success and 0's otherwise for uE0 and tau_b-computations
  
  %% Remark
  % Called by <birth_pie_foetus.html *birth_pie_foetus*> for graphical presentation
  
  % unpack p
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
    [uE0(i), lb, tb, info(i)] = get_ue0_foetus(p, eb(i));
    [t ulhMJ] = ode45(@dget_ulhMJ_foetus, [0;tb], [uE0(i); 0; 0; 0; 0], [], g, kap, k);
    EMJHG(i, :) = [eb(i) * lb^3/ g, ulhMJ(end,[4 5]), vHb * (1 - kap), kap * lb^3];
    EMJHG(i, :) = EMJHG(i, :)/ sum(EMJHG(i, :));
  end

  if exist('kap_G','var') == 1
    EMJHG = [EMJHG(:,1:4), EMJHG(:,5) * [ (1 - kap_G), kap_G]];
  end
end

% subfunction

function dulhMJ = dget_ulhMJ_foetus(t, ulhMJ, g, kap, k)
  % change in state variables during embryo stage
  % called by get_EMJG_foetus to get energy fractions at birth
  
  % unpack state variables
  u = ulhMJ(1);  % u_E scaled reserve
  l = ulhMJ(2);  % l, scaled length
  h = ulhMJ(3);  % u_H, scaled maturity
  
  l2 = l * l; l3 = l2 * l;

  du = 0;                                 % d/dt u_E 
  dl = g/ 3;                              % d/dt l
  dh = (1 - kap) * l2 * (g + l) - k * h;  % d/dt u_H
  dM = kap * l3;                          % d/dt u_M, som maint
  dJ = k * h;                             % d/dt u_J, mat maint

  % pack derivatives
  dulhMJ = [du; dl; dh; dM; dJ];
end