%% cum_reprod_s
% gets cumulative reproduction as function of time for delayed type M acceleration

%%
function [N, L, UE0, Lb, Ls, Lj, Lp, t_b, t_s, t_j, t_p, info] = cum_reprod_s(t, f, p, Lf)
  % created 2014/02/22 by Starrlight Augustine and Bas Kooijman, modified 2014/03/20
  
  %% Syntax
  % [N, L, UE0, Lb, Ls, Lj, Lp, t_b, t_s, t_j, t_p, info] = <../cum_reprod_s.m *cum_reprod_s*> (t, f, p, Lf)

  %% Description
  % Calculates the cumulative reproduction in number of eggs with delayed type M acceleration as juvenile 
  %   for an individual of age t and scaled reserve density e. 
  %
  % Input
  %
  % * t: n-vector with time since birth or since start if Lb0 has length 2
  % * f: scalar with functional response
  % * p: 11-vector with parameters:
  %     kappa; kappa_R, g, k_J, k_M, L_T, v, U_Hb, U_Hs, U_Hj, U_Hp
  %
  %     g and v refer to the values for embryo; scaling is always with respect to embryo values
  %
  % * Lf: optional scalar with length at birth (initial value only)
  %      or optional 2-vector with length, L, and scaled maturity, UH < UHp
  %      for a juvenile that is now exposed to f, but previously at another f
  %  
  % Output
  %
  % * N: n-vector with cumulative reproduction
  % * UE0; scalar with initial scaled reserve
  % * Lb: scalar with length at birth
  % * Ls: scalar with length at start acceleration
  % * Lj: scalar with length at end acceleration
  % * Lp: scalar with length at puberty
  % * t_b: time at birth if always exposed to f
  % * t_s: time at start acceleration if always exposed to f
  % * t_j: time at end acceleration if always exposed to f
  % * t_p: time at puberty if always exposed to f
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % For type M acceleration see <cum_reprod_j.html *cum_reprod_j*> 
  %   and for delayed type M acceleration <cum_reprod_s.html *cum_reprod_s*>.
  % For reproduction rates see <reprod_rate.html *reprod_rate*>, 
  % <reprod_rate_foetus.html *reprod_rate_foetus*>, 
  % <reprod_rate_j.html *reprod_rate_j*> and <reprod_rate_s.html *reprod_rate_s*>
  
  %% Example of use
  % See <../mydata_cum_reprod.m *mydata_cum_reprod*>
  
  % unpack parameters; parameter sequence, cf reprod_rate_metam
  kap = p(1); kapR = p(2);  g = p(3);  kJ = p(4) ; 
   kM = p(5);   LT = p(6);  v = p(7); UHb = p(8); UHs = p(9);
  UHj = p(10);  UHp = p(11);

  % compound parameters and par-vectors
  Lm = v/ (kM * g); % cm, max length
  k = kJ/ kM;       % -, maintenance ratio
  VHb = UHb/ (1 - kap); VHs = UHs/ (1 - kap); VHj = UHj/ (1 - kap); VHp = UHp/ (1 - kap);
  vHb = VHb * g^2 * kM^3/ v^2; vHs = VHs * g^2 * kM^3/ v^2; vHj = VHj * g^2 * kM^3/ v^2; vHp = VHp * g^2 * kM^3/ v^2; 

  p_UE0 = [VHb; g; kJ; kM; v];          % pars for initial_scaled_reserve  
  p_ts = [g; k; LT/ Lm; vHb; vHs; vHj; vHp]; % pars for get_ts
  p_mat = [kap; kapR; g; kJ; kM; LT; v; UHb; UHs; UHj; UHp]; % pars for maturity_s

  if exist('Lf','var') == 0
    Lf = [];
  end
  
  if length(Lf) <= 1 % Lf is initial estimate for lb
    l0 = Lf/ Lm; % scaled length at birth
    [ts tj tp tb ls lj lp lb li rhoj rhoB info_ts] = get_ts(p_ts, f, l0);
    ap = tp/ kM; aj = tj/ kM; as = ts/ kM; ab = tb/ kM; % d, age at puberty, metamorphosis, birth
    t_b = 0;       % d, time since birth at birth
    t_s = as - ab; % d, time since birth at start acceleration
    t_j = aj - ab; % d, time since birth at end acceleration
    t_p = ap - ab; % d, time since birth at puberty
    Lb = lb * Lm; Ls = ls * Lm; Lj = lj * Lm; Lp = lp * Lm; Li = li * Lm; % volumetric length at birth, metamorphosis, puberty, ultimate
    L0 = Lb;       % cm, structural length at time zero
    UH0 = UHb;     % c.cm^2, scaled maturity at time zero
    if info_ts ~= 1% return at failure for tj
      fprintf('ts could not be obtained in cum_reprod_s \n')
      N = t(:,1) * 0; L = N; UE0 = [];
      return;
    end
  else % if length Lf = 2, Lf is L at time 0 and f before time 0
    L0 = Lf(1); % cm, structural length at time 0
    f0 = Lf(2); % -, scaled func response before time 0
    [ts tj tp tb ls lj lp lb li rhoj rhoB info_ts] = get_ts(p_ts, f0);
    if info_ts ~= 1% return at failure for tp
      fprintf('maturity_s could not be obtained in cum_reprod_s \n')
      N = t(:,1) * 0; UE0 = [];
      return;
    end
    Lb = lb * Lm; Ls = ls * Lm; Lj = lj * Lm; Lp = lp * Lm; Li = li * Lm;
    if L0 > Lp
      fprintf('Length at zero is larger than that at puberty\n')
      N = t(:,1) * 0; UE0 = [];
      return;
    end
    [UH0, a0, info_mat] = maturity_s(L0, f0, p_mat);  % before time 0
    if info_mat ~= 1% return at failure for tp
      fprintf('maturity_s could not be obtained in cum_reprod_s \n')
      N = t(:,1) * 0; UE0 = [];
      return;
    end
    if UHj < UH0 % UHj < UH0 < UHp
      [UH, tL] = ode45(@dget_tL_sjp, [UH0; UHp], [0; L0], [], f, g, v, kap, kJ, Ls, Lj, Lm, LT); 
      t_p = tL(end,1); Lp = tL(end,2); % cm, struc length at puberty after time 0
      t_j = t_p - (tp - tj)/ kM; 
      t_s = t_p - (tp - ts)/ kM; 
      t_b = t_p - (tp - tb)/ kM; 
    elseif UHs < UH0 % UHs < UH0 < UHj
      [UH, tL] = ode45(@dget_tL_sjp, [UH0; UHj; UHp], [0; L0], [], f, g, v, kap, kJ, Ls, Lj, Lm, LT); 
      t_p = tL(end,1); Lp = tL(end,2); 
      t_j = tL(2,1); Lj = tL(2,2);
      t_s = t_p - (tp - ts)/ kM; 
      t_b = t_p - (tp - tb)/ kM; 
     else % UHb < UH0 < UHs
      [UH, tL] = ode45(@dget_tL_sjp, [UH0; UHs; UHj; UHp], [0; L0], [], f, g, v, kap, kJ, Ls, Lj, Lm, LT); 
      t_p = tL(end,1); Lp = tL(end,2); 
      t_j = tL(3,1); Lj = tL(3,2);
      t_s = tL(2,1); Ls = tL(2,2); 
      t_b = t_p - (tp - tb)/ kM; 
    end
  end
 
  [t LU] = ode45(@dcum_reprod_s, [-1e-10; t], [L0; 0], [], f, g, v, kap, kJ, UHp, Ls, Lj, Lm, LT, t_p);
  LU(1,:) = []; L = LU(:,1); UR = LU(:,2);
  [UE0, Lb, info] = initial_scaled_reserve(f, p_UE0, Lb);
  if info ~= 1 % return at failure for tp
    fprintf('UE0 could not be obtained in cum_reprod_s \n')
  end
  N = max(0, kapR * UR/ UE0); % convert to number of eggs
  
end

% subfunctions

function dtL = dget_tL_sjp(UH, tL, f, g, v, kap, kJ, Ls, Lj, Lm, LT)
  % called by cum_reprod_s: UH between UHb and UHp
 
  L = tL(2); % cm, structural length
  if L < Ls
    sM = 1;
  else
    sM =  min(L, Lj)/ Ls;
  end
  r = v * (f * sM/ L - (1 + LT * sM/ L)/ Lm)/ (f + g); % 1/d, spec growth rate
  dL = L * r/ 3;                              % cm/d, d/dt L
  dUH = (1 - kap) * L^3 * f * (sM/ L - r/ v) - kJ * UH; % cm^2, d/dt UH
  dtL = [1; dL]/ dUH;                         % 1/cm, d/dUH L
end

function dLU = dcum_reprod_s(t, LU, f, g, v, kap, kJ, UHp, Ls, Lj, Lm, LT, t_p)
  % called by cum_reprod_s
  
  L = LU(1); % unpack state variables: length & reprod buffer

  if L < Ls 
    sM = 1;
  elseif L < Lj 
    sM = min(L, Lj)/ Ls;
  else % L > Lj
    sM = Lj/ Ls;
  end  
  r = v * (f * sM/ L - (1 + LT * sM/ L)/ Lm)/ (f + g); % 1/d, spec growth rate
  dL = L * r/ 3;                              % cm/d, d/dt L
  
  if t < t_p
    dUR = 0; 
  else
    SC = f * L^3 * (sM/ L - r/ v); % cm^2, p_C/ {p_Am}
    dUR = (1 - kap) * SC - kJ * UHp;
  end
  dLU = [dL; dUR];
end
  