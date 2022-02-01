%% maturity_j
% Gets maturity as function of length for type M acceleration

%%
function [H, a, info] = maturity_j(L, f, p)
  %  created 2006/09/29 by Bas Kooijman, modified 2014/03/03
  
  %% Syntax
  % [H, a, info] = <../maturity_j.m *maturity_j*> (L, f, p)
  
  %% Description
  % Life history events b (birth), j (and of acceleration), p (puberty).
  % Acceleration between b and j.
  % Calculates the scaled maturity UH = MH/ {JEAm} at constant food
  %  density in the case of acceleration between UHb and UHj with UHb < UHj < UHp
  %
  % Input
  %
  % * L: n-vector with length 
  % * f: scalar with (constant) scaled functional response
  % * p: 10-vector with parameters: kap kapR g kJ kM LT v Hb Hj Hp
  %
  % Output
  %
  % * H: n-vector with scaled maturities: H = M_H/ {J_EAm}
  % * a: n-vector with ages at which lengths are reached 
  % * info: scalar for 1 for success, 0 otherwise
  
  %% Remarks
  % See <maturity.html *maturity*> in absence of acceleration and
  % <maturity_s.html *maturity_s*> if accleration is delayed

  %% Example of use
  % [H, a, info] = maturity_j(.4, 1, [.8,.95, .2, .002, .01, 0, .02, .2, .4, 2])
 
  % unpack parameters
  kap = p(1); % -, fraction allocated to growth + som maint
  %kapR = p(2);% -, fraction of reprod flux that is fixed in embryo reserve 
  g  = p(3);  % -, energy investment ratio
  kJ = p(4);  % 1/d, maturity maint rate coeff
  kM = p(5);  % 1/d, somatic maint rate coeff
  LT = p(6);  % cm, heating length
  v  = p(7);  % cm/d, energy conductance
  Hb = p(8); % d cm^2, scaled maturity at birth
  Hj = p(9); % d cm^2, scaled maturity at metamorphosis
  Hp = p(10); % d cm^2, scaled maturity at puberty
  % kapR is not used, but kept for consistency with iget_pars_r, reprod_rate
    
  if isempty('f')
    f = 1; % abundant food
  end

  Lm = v/ kM/ g; lT = LT/ Lm; k = kJ/ kM;
  
  uHb = Hb * g^2 * kM^3/ (v^2); vHb = uHb/ (1 - kap);
  uHj = Hj * g^2 * kM^3/ (v^2); vHj = uHj/ (1 - kap);
  uHp = Hp * g^2 * kM^3/ (v^2); vHp = uHp/ (1 - kap);
  [lj, lp, lb, info] = get_lj([g; k; lT; vHb; vHj; vHp], f);
  Lp = Lm * lp; 
  
  ue0 = get_ue0([g; k; vHb], f, lb); % initial scaled reserve M_E^0/{J_EAm}
  [l_out, teh] = ode45(@dget_teh_j, [1e-6; L(1)/ 2; L]/ Lm, [0; ue0; 0], [], k, g, kap, f, uHb, uHj, uHp, lT, lb, lj);
  teh(1:2,:) = []; 
  H = teh(:,3) * v^2/ g^2/ kM^3;
  H(L >= Lp) = Hp;
  a = teh(:,1)/ kM;

end

% subfunctions

function dtEH = dget_teh_j(l, tEH, k, g, kap, f, uHb, uHj, uHp, lT, lb, lj)
  % l: scalar with scaled length  l = L g k_M/ v
  % tEH: 3-vector with (tau, uE, uH) of embryo and juvenile
  %   tau = a k_M; scaled age
  %   uE = (g^2 k_M^3/ v^2) M_E/ {J_EAm}; scaled reserve
  %   uH = (g^2 k_M^3/ v^2) M_H/ {J_EAm}; scaled maturity
  % dtEH: 3-vector with (dt/duH, duE/duH, dl/duH)
  % called by maturity_j
  
  t = tEH(1); % scaled age
  uE = max(1e-10,tEH(2)); % scaled reserve
  uH = tEH(3); % scaled maturity
  l2 = l * l; l3 = l2 * l;
 
  % first obtain dl/dt, duE/dt, duH/dt
  if uH < uHb % isomorphic embryo
    r = (g * uE/ l - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE =  - uE * (g/ l - r);
    duH = (1 - kap) * uE * (g/ l - r) - k * uH;
  elseif uH < uHj % V1-morphic early juvenile
    rj = (g * uE/ lb - l3 * lT/ lb - l3)/ (uE + l3); % scaled exponential growth rate between b and j
    dl = l * rj/ 3;
    duE = f * l^3/ lb - uE * (g/ lb - rj);
    duH = (1 - kap) * uE * (g/ lb - rj) - k * uH;
  elseif uH < uHp % isomorphic late juvenile
    sM = lj/ lb;
    r = (g * uE * sM/ l - l2 * lT * sM - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE = f * l2 * sM - uE * (g * sM/ l - r);
    duH = (1 - kap) * uE * (g * sM/ l - r) - k * uH;
  else % isomorphic adult
    sM = lj/ lb;
    r = (g * uE * sM/ l - l2 * lT * sM - l3)/ (uE + l3); % spec growth rate in scaled time
    dl = l * r/ 3;
    duE = f * l2 * sM - uE * (g * sM/ l - r);
    duH = 0; % no maturation in adults
  end

  % then obtain dt/dl, duE/dl, duH/dl, 
  dtEH = [1; duE; duH]/ dl;
end
