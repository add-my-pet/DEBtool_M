%% maturity
% calculates the scaled maturity

%%
function [H, a, info] = maturity(L, f, p)
  %  created 2006/09/29 by Bas Kooijman, modified 2014/03/03, 2019/06/01
  
  %% Syntax
  % [H, a, info] = <../maturity.m *maturity*> (L, f, p)
  
  %% Description
  % calculates the scaled maturity UH = MH/ {JEAm} at constant food density. 
  %
  % Input
  %
  % * L: n-vector with length, ordered from small to large 
  % * f: scalar with (constant) scaled functional response
  % * p: 9-vector with parameters (see below)
  %
  % Output
  %
  % * H: n-vector with scaled maturities: H = M_H/ {J_EAm}
  % * a: n-vactor with ages at which lengths are reached
  % * info: scalar for 1 for success, 0 otherwise
  
  %% Remarks
  %  called by DEBtool/tox/*rep and DEBtool/animal/scaled_power
  % See <maturity_j.html *maturity_j*> for type M accleration and
  % <maturity_s.html *maturity_s*> for delayed type M acceleration.
  
  %% Example of use
  %  [H, a, info] = maturity(.4, 1, [.8,.95, .2, .002, .01, 0, .02, .2, 2])

  % unpack parameters
  kap = p(1); % -, fraction allocated to growth + som maint
  %kapR = p(2);% -, fraction of reprod flux that is fixed in embryo reserve 
  g  = p(3);  % -, energy investment ratio
  kJ = p(4);  % 1/d, maturity maint rate coeff
  kM = p(5);  % 1/d, somatic maint rate coeff
  LT = p(6);  % cm, heating length
  v  = p(7);  % cm/d, energy conductance
  Hb = p(8);  % d cm^2, scaled maturity at birth
  Hp = p(9);  % d cm^2, scaled maturity at puberty
  % kapR is not used, but kept for consistency with iget_pars_r, reprod_rate
  
  if exist('f','var') == 0
    f = 1; % abundant food
  end

  Lm = v/ kM/ g; lT = LT/ Lm; k = kJ/ kM;
  l = L(:)/ Lm; n = sum(l == 1); 
  if n > 0
    l(l == l) = l(l == l) - fliplr(1:n) * 1e-4;% -, scaled lengths 
  end

  uHb = Hb * g^2 * kM^3/ (v^2); vHb = uHb/ (1 - kap);
  uHp = Hp * g^2 * kM^3/ (v^2); vHp = uHp/ (1 - kap);
  [uE0, lb, info] = get_ue0([g, k, vHb], f);

  options = odeset('Events', @event_length); 
  [t, luEuH, t_l, luEuH_l, event_l] = ode23(@dget_luEuH, [0; 1e20], [1e-10; uE0; 0], options, l, f, kap, g, k, lT, uHb, uHp);
  if length(t) < length(l)
    event_l = [1; event_l]; t_l = [0; t_l]; luEuH_l = [[0, uE0, 0]; luEuH_l];
  end
  [l, in] = unique(event_l); a = t_l(in)/ kM; H = luEuH_l(in,3) * v^2/ g^2/ kM^3; 

end

% subfunctions
function dluEuH = dget_luEuH(tau, luEuH, l, f, kap, g, k, lT, uHb, uHp)

  % tau: a k_M; scaled age
  % luEuH: 3-vector with (l, uE, uH) 
  %   scalar with scaled length  l = L g k_M/ v
  %   uE = (g^2 k_M^3/ v^2) M_E/ {J_EAm}; scaled reserve
  %   uH = (g^2 k_M^3/ v^2) M_H/ {J_EAm}; scaled maturity
  % dluEuH: 3-vector with (dl/dtau, duE/dtau, duH/dtau)
  
  l = luEuH(1); l2 = l * l; l3 = l2 * l; % scaled length
  uE = max(1e-10,luEuH(2)); % scaled reserve
  uH = luEuH(3); % scaled maturity
  
  if uH < uHb % isomorphic embryo
    r = (g * uE/ l - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE =  - uE * (g/ l - r);
    duH = (1 - kap) * uE * (g/ l - r) - k * uH;
  elseif uH < uHp % isomorphic late juvenile
    r = (g * uE/ l - l2 * lT - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE = f * l2 - uE * (g/ l - r);
    duH = (1 - kap) * uE * (g/ l - r) - k * uH;
  else % isomorphic adult
    r = (g * uE/ l - l2 * lT - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE = f * l2 - uE * (g/ l - r);
    duH = 0; % no maturation in adults
  end

  dluEuH = [dl; duE; duH]; % pack output
end

function [value,isterminal,direction] = event_length(t, luEuH, l, f, kap, g, k, lT, uHb, uHp)
  % luEuH: 3-vector with [l; uE; uH]
  n = length(l);
  value = l - luEuH(1);
  isterminal = zeros(n,1); isterminal(n) = 1;
  direction = zeros(n,1); 
end