%% intScaled_power
% Gets life-span integrated scaled powers
%%
function tpACSJGRD = intScaled_power(tm, f, p, lb, lp)
  % created 2026/03/29 by Bas Kooijman
  
  %% Syntax
  % tpACSJGRD = <../intScaled_power.m *intScaled_power*> (tm, f, p, lb, lp)
  
  %% Description
  % Gets integrated scaled powers, form ab to am: assimilation, mobilisation, somatic maintenance, maturity maintenance,
  % growth, maturation/reproduction and dissipation as function of length: \int_0^tm p_*(tau) dtau
  % food density is assimed to be constant.
  %
  % Input
  %
  % * tm: scalar with scaled time since birth at death: (a_m - a_b)*k_M
  % * f: scalar with (constant) scaled functional response
  % * p: 9-vector with parameters: kap kapR g kJ kM LT v UHb UHp
  % * lb: scalar with scaled length at birth for f
  % * lp: scalar with scaled length at puberty for f
  %
  % Output
  %
  % * tpACSJGRD: (n,7)-vector with integrated scaled powers p_A, p_C, p_S, p_J, p_G, p_R, p_D
  
  %% Remarks
  %
  % * The scaled integrated powers are dimensionless; unscale by multiplying by {p_Am}*k_M*L_m^2 . 
  % * The maturity value relates to the one for which f has been constant.
  
  %% Example of use
  % See <../statistics.m *statistics*> and <../shpower.m *shpower*>

  % unpack parameters
  kap  = p(1);  % -, fraction allocated to growth + som maint
  kapR = p(2);  % -, fraction of reprod flux that is fixed in embryo reserve 
  g    = p(3);  % -, energy investment ratio
  kJ   = p(4);  % 1/d, maturity maint rate coeff
  kM   = p(5);  % 1/d, somatic maint rate coeff
  LT   = p(6);  % cm, heating length 
  v    = p(7);  % cm/d, energy conductance
  Hb   = p(8);  % d cm^2, scaled maturity at birth Hb = M_H/{J_EAm} = E_Hb/{p_Am}
  Hp   = p(9);  % d cm^2, scaled maturity at puberty Hp = M_H/{J_EAm} = E_Hp/{p_Am}

  Lm = v/ kM/ g;    % cm, max struc length
  k = kJ/ kM;       % -, maintenance ratio
  rB = 1/3/(1+f/g); % -, scaled von Bert growth rate r_B/k_M
  lT = LT/ Lm;      % -, scaled heating length
  uHb = Hb *  g^2 * kM^3/ v^2; % -, scaled maturity at birth
  uHp = Hp *  g^2 * kM^3/ v^2; % -, scaled maturity at puberty

  [~, tlbm2, tlbm3] = tL123_std([lb, li, rB], 0, tm);
  %[~, tlbp2, tlbp3] = tL123_std([lb, lp, rB], 0, tp);  % required to separate maturation from reproduction
  %[~, tlpm2, tlpm3] = tL123_std([lp, li, rB], tp, tm); % required to separate maturation from reproduction
  
  [~, luHcuH] = ode45(@get_luHcuH,[0;tm/kM], [lb;uHb;0], [], uHp, li, lT, f, kap, g, k);

  tpA = f * tlbm2;                            % assim
  tpC = f * (tlbm2 * (g + lT) + tlbm3)/ (g + f); % mobilisation
  tpS = kap * (tlbmL3 + tlbm2);               % somatic  maint
  tpJ = luHcuH(end,3);                        % maturity maint
  tpG = kap * tpC - tpS;                      % growth
  tpR = (1 - kap) * (tpC - tpJ);              % maturation/reproduction
  tpD = tpS + tpJ + (1 - kapR) * tpR;         % dissipation

  tpACSJGRD = [tpA, tpC, tpS, tpJ, tpG, tpR, tpD];
end

function dluHcuH = get_luHcuH(~, luHcuH, uHp, li, lT, f, kap, g, k)
  l = luHcuH(1); uH = min(luHcuH(2), uHp);
  
  dl = (li - l)/ 3/ (1 + f/ g);
  pC = f * l^2 * (g + lT + l)/ (g + f);
  dcuH = k * uH; % cumulative uH
  duH = (1 - kap)*pC - dcuH;
  dluHcuH = [dl; duH; dcuH];
end
  