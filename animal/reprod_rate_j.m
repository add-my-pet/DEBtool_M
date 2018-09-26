%% reprod_rate_j
% gets reproduction rate as function time for type M acceleration

%%
function [R, UE0, Lb, Lj, Lp, info] = reprod_rate_j(L, f, p, Lf)
  % created 2009/03/24 by Bas Kooijman, modified 2014/02/26
  % modified 2018/09/10 (fixed typos in description) Nina Marn
  
  %% Syntax
  % [R, UE0, Lb, Lj, Lp, info] = <../reprod_rate_j.m *reprod_rate_j*> (L, f, p, Lf)
  
  %% Description
  % Calculates the reproduction rate in number of eggs per time 
  % in the case of acceleration between events b and j
  % for an individual of length L and scaled reserve density f
  %
  % Input
  %
  % * L: n-vector with length
  % * f: scalar with functional response
  % * p: 10-vector with parameters: kap, kapR, g, kJ, kM, LT, v, UHb, UHj, UHp
  %
  %     g and v refer to the values for embryo; scaling is always with respect to embryo values
  %     V1-morphic juvenile between events b and j with E_Hb > E_Hj > E_Hp
  %
  % * Lf: optional scalar with length at birth (initial value only)
  %
  %     or optional 2-vector with length, L, and scaled functional response f0
  %     for a juvenile that is now exposed to f, but previously at another f
  %  
  % Output
  %
  %  R: n-vector with reproduction rates
  %  UE0: scalar with scaled initial reserve
  %  info: indicator with 1 for success, 0 otherwise
  
  %% Remarks
  % Theory is given in comments to DEB3 section 7.8.2
  % See also <reprod_rate.html *reprod_rate*>, <reprod_rate_s.html *reprod_rate_s*>, 
  %  <reprod_rate_foetus.html *reprod_rate_foetus*>.
  % For cumulative reproduction, see <cum_reprod.html *cum_reprod*>, 
  %  <cum_reprod_j.html *cum_reprod_j*>, <cum_reprod_s.html *cum_reprod_s*>
  
  %% Example of use
  % See <../mydata_reprod_rate *mydata_reprod_rate*>
  
  %  Explanation of variables:
  %  R = kapR * pR/ E0
  %  pR = (1 - kap) pC - kJ * EHp
  %  [pC] = [Em] (v/ L + kM (1 + LT/L)) f g/ (f + g); pC = [pC] L^3
  %  [Em] = {pAm}/ v
  % 
  %  remove energies; now in lengths, time only
  % 
  %  U0 = E0/{pAm}; UHp = EHp/{pAm}; SC = pC/{pAm}; SR = pR/{pAm}
  %  R = kapR SR/ U0
  %  SR = (1 - kap) SC - kJ * UHp
  %  SC = f (g/ L + (1 + LT/L)/ Lm)/ (f + g); Lm = v/ (kM g)
  %
  % unpack parameters; parameter sequence, cf get_pars_r
  kap = p(1); kapR = p(2);  g = p(3); kJ = p(4) ; 
  kM  = p(5); LT   =  p(6); v = p(7); 
  UHb = p(8); UHj  = p(9); UHp = p(10);

  Lm = v/ (kM * g); % maximum length
  k = kJ/ kM;       % -, maintenance ratio
  VHb = UHb/ (1 - kap); VHj = UHj/ (1 - kap); VHp = UHp/ (1 - kap);
  vHb = VHb * g^2 * kM^3/ v^2; vHj = VHj * g^2 * kM^3/ v^2; vHp = VHp * g^2 * kM^3/ v^2; 

  p_UE0 = [VHb; g; kJ; kM; v];          % pars for initial_scaled_reserve  
  p_lj = [g; k; LT/ Lm; vHb; vHj; vHp]; % pars for get_lj
  p_mat = [kap; kapR; g; kJ; kM; LT; v; UHb; UHj; UHp]; % pars for maturity_j

  if exist('Lf','var') == 0
    Lf = [];
  end

  if length(Lf) <= 1
    lb0 = Lf/ Lm; % scaled length at birth
    [lj, lp, lb, info_lj] = get_lj(p_lj, f, lb0);
    Lb = lb * Lm; Lj = lj * Lm; Lp = lp * Lm; % volumetric length at birth, puberty
    if info_lj ~= 1 % return at failure for tp
      fprintf('lp could not be obtained in reprod_rate_j \n')
      R = L * 0; UE0 = [];
      return;
    end
  else % if length Lb0 = 2
    L0 = Lf(1); % cm, structural length at time 0
    f0 = Lf(2); % -, scaled func response before time 0
    [UH0, info_mat] = maturity_j(L0, f0, p_mat);  % d.cm^2, maturity at zero
    if info_mat ~= 1% return at failure for tp
      fprintf('maturity could not be obtained in reprod_rate_j \n')
      R = L * 0; UE0 = [];
      return;
    end
    [lj, lp, lb, info_lj] = get_lj(p_lj, f);
    Lb = lb * Lm; Lj = lj * Lm;
    [UH, tL] = ode45(@dget_tL_jp, [UH0; UHp], [0; L0], [], f, g, v, kap, kJ, Lb, Lj, Lm, LT); 
    Lp = tL(end,2);  % cm, struc length at puberty after time 0
  end
 
  [UE0, Lb, info] = initial_scaled_reserve(f, p_UE0, Lb);

  SC = L .^ 2 .* ((g + LT/ Lm) * Lj/ Lb + L/ Lm)/ (1 + g/ f);
  SR = (1 - kap) * SC - kJ * UHp;
  R = (L >= Lp) * kapR .* SR/ UE0; % set reprod rate of juveniles to zero
end

% subfunctions

function dtL = dget_tL_jp(UH, tL, f, g, v, kap, kJ, Lb, Lj, Lm, LT)
  % called by cum_reprod_j: UH between UHb and UHp
 
  L = tL(2); % cm, structural length
  sM = min(L, Lj)/ Lb;
  r = v * (f * sM - (L + LT * sM)/ Lm)/ L/ (f + g); % 1/d, spec growth rate
  dL = L * r/ 3;                              % cm/d, d/dt L
  dUH = (1 - kap) * L^3 * f * (sM/ L - r/ v) - kJ * UH; % cm^2, d/dt UH
  dtL = [1; dL]/ dUH;                         % 1/cm, d/dUH L

end