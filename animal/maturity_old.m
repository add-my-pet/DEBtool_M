%% maturity
% calculates the scaled maturity

%%
function [H, a, info] = maturity_old(L, f, p)
  %  created 2006/09/29 by Bas Kooijman, modified 2014/03/03
  
  %% Syntax
  % [H, a, info] = <../maturity_old.m *maturity*> (L, f, p)
  
  %% Description
  % calculates the scaled maturity UH = MH/ {JEAm} at constant food density. 
  %
  % Input
  %
  % * L: n-vector with length, ordered from small to large 
  % * p: 9-vector with parameters (see below)
  % * F: scalar with (constant) scaled functional response
  %
  % Output
  %
  % * H: n-vector with scaled maturities: H = M_H/ {J_EAm}
  % * info: scalar for 1 for success, 0 otherwise
  
  %% Remarks
  %  called by DEBtool/tox/*rep and DEBtool/animal/scaled_power
  % See <maturity_j.html *maturity_j*> for type M accleration and
  % <maturity_s.html *maturity_s*> for delayed type M acceleration.
  % obsolate function, which is replace by maturity
  
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
  
  uHb = Hb * g^2 * kM^3/ (v^2); vHb = uHb/ (1 - kap);
  uHp = Hp * g^2 * kM^3/ (v^2); vHp = uHp/ (1 - kap);
  [tp, tb, lp, lb, info] = get_tp([g; k; lT; vHb; vHp], f);
  Lp = Lm * lp; 
  
  H = Hp * (L >= Lp); a = tp * (L > Lp)/ kM; % prefill output for adults
  
  n_mat = sum(L < Lp); % number of embryo and juvenile values: H < Hp
  if  n_mat == 0 % all adult lengths
    return
  else % some embryo and juvenile values
    L = L(L< Lp); % select embryo and juvenile values
    ue0 = get_ue0([g; k; vHb], f, lb); %% initial scaled reserve M_E^0/{J_EAm}
    [l_out, teh] = ode45(@dget_teh, [-1e-6; L(1)/ 2; L]/ Lm, [0; ue0; 0], [], k, g, kap, f, uHb, uHp, lT);
    teh(1:2,:) = []; % remove added L values
    H(1:n_mat) = teh(:,3) * v^2/ g^2/ kM^3; 
    a(1:n_mat) = teh(:,1)/ kM;
  end

end

% subfunctions
function dtEH = dget_teh(l, tEH, k, g, kap, f, uHb, uHp, lT)
  % dtEH = dget_teh(l, tEH)
  % l: scalar with scaled length  l = L g k_M/ v
  % tEH: 3-vector with (tau, uE, uH) of embryo and juvenile
  %   tau = a k_M; scaled age
  %   uE = (g^2 k_M^3/ v^2) M_E/ {J_EAm}; scaled reserve
  %   uH = (g^2 k_M^3/ v^2) M_H/ {J_EAm}; scaled maturity
  % dtEH: 3-vector with (dt/duH, duE/duH, dl/duH)
  % called by maturity
  
  t = tEH(1); % scaled age
  uE = max(1e-10,tEH(2)); % scaled reserve
  uH = tEH(3); % scaled maturity
  l2 = l * l; l3 = l2 * l;

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

  % then obtain dt/dl, duE/dl, duH/dl, 
  dtEH = [1; duE; duH]/ dl;
end
