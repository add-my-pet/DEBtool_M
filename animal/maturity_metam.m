%% maturity_metam
% Gets maturity as function of length for type M acceleration

%%
function [H, info] = maturity_metam(L, f, p)
  %  L: n-vector with length 
  %  F: scalar with (constant) scaled functional response
  %  p: 10-vector with parameters: kap kapR g kJ kM LT v Hb Hj Hp
  %  H: n-vector with scaled maturities: H = M_H/ {J_EAm}
  %  info: scalar with 1 for success, 0 otherwise
  %
  %% Remarks
  % Called by DEBtool/animal/scaled_power_metam
  % *This function is obsolate and will be phased out*: 
  % see <maturity_j.html *maturity_j*>

  %global f g kap lT k uHb uHj uHp ljb

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
  %% kapR is not used, but kept for consistency with iget_pars_r, reprod_rate

  if exist('f', 'var') == 0
    f = 1; % abundant food
  end
  
  Lm = v/ kM/ g; lT = LT/ Lm; k = kJ/ kM;
  
  uHb = Hb * g^2 * kM^3/ (v^2); vHb = uHb/ (1 - kap);
  uHj = Hj * g^2 * kM^3/ (v^2); vHj = uHj/ (1 - kap);
  uHp = Hp * g^2 * kM^3/ (v^2); vHp = uHp/ (1 - kap);
  [lj lp lb info] = get_lj([g; k; lT; vHb; vHj; vHp], f);
  Lp = Lm * lp; 
  
  ue0 = get_ue0([g; k; vHb], f, lb); % initial scaled reserve M_E^0/{J_EAm}
  [l_out, teh] = ode45(@dget_teh_metam, [1e-6; L(1)/ 2; L]/ Lm, [0; ue0; 0], [], k, g, kap, f, uHb, uHj, uHp, lT, lb, lj);
  teh(1:2,:) = []; 
  H = teh(:,3) * v^2/ g^2/ kM^3;
  H(L >= Lp) = Hp;

