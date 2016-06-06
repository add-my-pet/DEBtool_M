%% scaled_power_j
% Gets scaled powers as function of length in case of type M acceleration

%%
function pACSJGRD = scaled_power_j(L, f, p, lb, lj, lp)
  % created 2011/04/28 by Bas Kooijman, modified 2012/09/22
  
  %% Syntax
  % pACSJGRD = <..scaled_power_j.m *scaled_power_j*> (L, f, p, lb, lj, lp)
  
  %% Description
  % Gets scaled powers assimilation, mobilisation, somatic maintenance, maturity maintenance,
  % growth, reproduction and dissipation as function of length
  %
  % Input
  %
  % * L: n-vector with lengths
  % * f: scalar with (constant) scaled functional response
  % * p: 10-vector with parameters: kap kapR g kJ kM LT v UHb UHj UHp
  % * lb: scalar with scaled length at birth for f; if not existent: NaN
  % * lj: scalar with scaled length at metamorphosis for f; if not existent: NaN
  % * lp: scalar with scaled length at puberty for f; if not existent: NaN  
  %
  % Output
  %
  % * pACSJGRD: (n,7)-matrix with scaled powers p_A, p_C, p_S, p_J, p_G, p_R, p_D / L_m^2 {p_Am}
  
  %% Remarks
  % Similar to <scaled_power.html *scaled_power*> for metabolic acceleration between birth and metamorphosis.
  % The maturity value relates to the one for which f has been constant.
  % Powers can become negative for shrinking of structure or maturity.
  % See function <scaled_power.html *scaled_power*> for no metabolic acceleration.
  
  %% Example of use
  % See <../statistics.m *statistics*>

  % unpack parameters
  kap  = p(1);  % -, fraction allocated to growth + som maint
  kapR = p(2);  % -, fraction of reprod flux that is fixed in embryo reserve 
  g    = p(3);  % -, energy investment ratio
  kJ   = p(4);  % 1/d, maturity maint rate coeff
  kM   = p(5);  % 1/d, somatic maint rate coeff
  LT   = p(6);  % cm, heating length 
  v    = p(7);  % cm/d, energy conductance
  U_Hb = p(8);  % d cm^2, scaled maturity at birth
  U_Hj = p(9);  % d cm^2, scaled maturity at metamorphosis
  U_Hp = p(10); % d cm^2, scaled maturity at puberty

  Lm = v/ kM/ g; k = kJ/ kM;
  L = L(:); l = L/ Lm; lT = LT/ Lm; 

  if isnan(lb) && isnan(lp) % juvenile stage cannot be reached
    lT = 0 * l;
    assim = 0 * l;
    kapR = 0 * l;
    sM = 1 + 0 * l;
  elseif isnan(lj) % metamorphosis cannot be reached
    lT = (l > lb) .* lT;
    assim = (l > lb);
    kapR = 0 * l;
    sM = max(lb, l)/ lb;    % -, stress fractor for acceleration
  elseif isnan(lp) % adult stage cannot be reached
    lT = (l > lb) .* lT;
    assim = (l > lb);
    kapR = 0 * l;
    sM = min(lj, max(lb, l))/ lb;    % -, stress fractor for acceleration
  else % adult stage can be reached
    lT = (l > lb) .* lT;
    assim = (l > lb);
    kapR = kapR * (l > lp);
    sM = min(lj, max(lb, l))/ lb;    % -, stress fractor for acceleration
  end

  H = maturity_j(L, f, p);  % scaled maturities E_H/ {p_Am}
  uH = H *  g^2 * kM^3/ v^2;

  % scaled powers: powers per max assimilation {p_Am} L_m^2
  pA = assim * f .* sM .* l.^2;              % assim
  pC = l.^2 .* ((g + lT) .* sM + l )/ (1 + g/ f);   % mobilisation
  pS = kap * l.^2 .* (l + lT);               % somatic  maint
  pJ = k * uH;                               % maturity maint
  pG = kap * pC - pS;                        % growth
  pR = (1 - kap) * pC - pJ;                  % maturation/reproduction
  pD = pS + pJ + (1 - kapR) .* pR ;          % dissipation

  pACSJGRD = [pA, pC, pS, pJ, pG , pR, pD];