%% scaled_power
% Gets scaled powers as function of length

%%
function pACSJGRD = scaled_power(L, f, p, lb, lp)
  % created 2009/01/15 by Bas Kooijman
  
  %% Syntax
  % pACSJGRD = <../scaled_power.m *scaled_power*> (L, f, p, lb, lp)
  
  %% Description
  % Gets scaled powers assimilation, mobilisation, somatic maintenance, maturity maintenance,
  % growth, reproduction and dissipation as function of length.
  % Scaled powers are calculated on the assumption for maturity that food density is constant. 
  %
  % Input
  %
  % * L: n-vector with lengths
  % * f: scalar with (constant) scaled functional response
  % * p: 9-vector with parameters: kap kapR g kJ kM LT v UHb UHp
  % * lb: scalar with scaled length at birth for F; if not existent: NaN
  % * lp: scalar with scaled length at puberty for F; if not existent: NaN  
  %
  % Output
  %
  % * pACSJGRD: (n,7)-matrix with scaled powers p_A, p_C, p_S, p_J, p_G, p_R, p_D / L_m^2 {p_Am}
  
  %% Remarks
  % The powers can become negative for shrinking of structure or maturity. 
  % The scaled powers are dimensionless by dividing the powers by {pAm} Lm2. 
  % The maturity value relates to the one for which f has been constant.
  % See function <scaled_power_j.html *scaled_power_j*> for metabolic acceleration.
  
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
  Hb   = p(8);  % d cm^2, scaled maturity at birth
  Hp   = p(9);  % d cm^2, scaled maturity at puberty

  Lm = v/ kM/ g; k = kJ/ kM;
  L = L(:); l = L/ Lm; lT = LT/ Lm; 

  if isnan(lb) && isnan(lp) % juvenile stage cannot be reached
    lT = 0 * l;
    assim = 0 * l;
    kapR = 0 * l;
  elseif isnan(lp) % adult stage cannot be reached
    lT = (l > lb) .* lT;
    assim = (l > lb);
    kapR = 0 * l;
  else % adult stage can be reached
    lT = (l > lb) .* lT;
    assim = (l > lb);
    kapR = kapR * (l > lp);
  end

  H = maturity (L, f, p);  % scaled maturities E_H/ {p_Am}
  uH = H *  g^2 * kM^3/ v^2;

  pA = assim * f .* l.^2;                    % assim
  pC = f .* l.^2 .* (g + l + lT) ./ (g + f); % mobilisation
  pS = kap * l.^2 .* (l + lT);               % somatic  maint
  pJ = k * uH;                               % maturity maint
  pG = kap * pC - pS;                        % growth
  pR = (1 - kap) * pC - pJ;                  % maturation/reproduction
  pD = pS + pJ + (1 - kapR) .* pR ;          % dissipation

  pACSJGRD = [pA, pC, pS, pJ, pG , pR, pD];