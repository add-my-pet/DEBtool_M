%% reprod_rate
% gets reproduction rate as function of time

%%
function [R, UE0, Lb, Lp, info] = reprod_rate(L, f, p, Lf)
  % created 2003/03/18 by Bas Kooijman, modified 2014/02/26
  
  %% Syntax
  % [R, UE0, Lb, Lp, info] = <reprod_rate.m *reprod_rate*>(L, f, p, Lf)
  
  %% Description
  % Calculates the reproduction rate in number of eggs per time
  % for an individual of length L and scaled reserve density f
  %
  % Input
  %
  % * L: n-vector with length
  % * f: scalar with functional response
  % * p: 9-vector with parameters: kap, kapR, g, kJ, kM, LT, v, UHb, UHp
  % * Lf: optional scalar with length at birth (initial value only)
  %
  %      or optional 2-vector with length, L, and scaled functional response f0
  %      for a juvenile that is now exposed to f, but previously at another f
  %  
  % Output
  %
  % * R: n-vector with reproduction rates
  % * UE0: scalar with scaled initial reserve
  % * Lb: scalar with (volumetric) length at birth
  % * Lp: scalar with (volumetric) length at puberty
  % * info: indicator with 1 for success, 0 otherwise
  
  %% Remarks
  % See also <reprod_rate_foetus.html *reprod_rate_foetus*>, 
  %   <reprod_rate_j.html *reprod_rate_j*>, <reprod_rate_s.html *reprod_rate_s*>.
  % For cumulative reproduction, see <cum_reprod_rate.html *cum_reprod_rate*>
  
  %% Example of use
  % See <mydata_reprod_rate.m *mydata_reprod_rate*>
  
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
  kap = p(1); kapR = p(2); g = p(3); kJ = p(4); kM = p(5);
  LT = p(6); v = p(7); UHb = p(8); UHp = p(9);

  Lm = v/ (kM * g); % maximum length
  k = kJ/ kM;       % -, maintenance ratio
  VHb = UHb/ (1 - kap); VHp = UHp/ (1 - kap);
  vHb = VHb * g^2 * kM^3/ v^2; vHp = VHp * g^2 * kM^3/ v^2; 

  p_lb = [g; k ; vHb];             % pars for get_lb
  p_lp = [g; k; LT/ Lm; vHb; vHp]; % pars for get_tp
  p_UE0 = [VHb; g; kJ; kM; v];     % pars for initial_scaled_reserve  
  p_mat = [kap; kapR; g; kJ; kM; LT; v; UHb; UHp]; % pars for maturity

  if exist('Lf', 'var') == 0
    Lf = [];
  end

  if length(Lf) <= 1
    lb0 = Lf/ Lm; % scaled length at birth
    [lp, lb, info_lp] = get_lp(p_lp, f, lb0);
    Lb = lb * Lm; Lp = lp * Lm; % volumetric length at birth, puberty
    if info_lp ~= 1 % return at failure for tp
      fprintf('lp could not be obtained in reprod_rate \n')
      R = L * 0; UE0 = [];
      return;
    end
  else % if length Lb0 = 2
    L0 = Lf(1); % cm, structural length at time 0
    f0 = Lf(2); % -, scaled func response before time 0
    [UH0, info_mat] = maturity(L0, f0, p_mat);  % d.cm^2, maturity at zero
    if info_mat ~= 1% return at failure for tp
      fprintf('maturity could not be obtained in reprod_rate \n')
      R = L * 0; UE0 = [];
      return;
    end
    [lp, lb, info_lp] = get_lp(p_lp, f);
    Lb = lb * Lm;
    [UH, tL] = ode45(@dget_tL, [UH0; UHp], [0; L0], [], f, g, v, kap, kJ, Lm, LT); 
    Lp = tL(end,2);  % cm, struc length at puberty after time 0
  end

  [UE0 Lb info] = initial_scaled_reserve(f, p_UE0, Lb);
  SC = f * L.^3 .* (g ./ L + (1 + LT ./ L)/ Lm)/ (f + g);
  SR = (1 - kap) * SC - kJ * UHp;
  R = (L >= Lp) * kapR .* SR/ UE0; % set reprod rate of juveniles to zero
  
end

% Subfunctions

function dtL = dget_tL (UH, tL, f, g, v, kap, kJ, Lm, LT)
  % called by cum_reprod
  L = tL(2);
  r = v * (f/ L - (1 + LT/ L)/ Lm)/ (f + g); % 1/d, spec growth rate
  dL = L * r/ 3; % cm/d, d/dt L
  dUH = (1 - kap) * L^3 * f * (1/ L - r/ v) - kJ * UH; % cm^2, d/dt UH
  dtL = [1; dL]/ dUH; % 1/cm, d/dUH L
end