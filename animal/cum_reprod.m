%% cum_reprod
% gets cumulative reproduction as function of time

%%
function [N, L, UE0, Lb, Lp, t_b, t_p, info] = cum_reprod(t, f, p, Lf)
  % created 2008/08/06 by Bas Kooijman, modified Starrlight Augustine 2014/03/20
  
  %% Syntax
  % [N, L, UE0, Lb, Lp, t_b, t_p, info] = <../cum_reprod.m *cum_reprod*> (t, f, p, Lf)

  %% Description
  % Calculates the cumulative reproduction in number of eggs 
  %   for an individual of time since birth a and scaled reserve density e = f.
  % Optionally the initial conditions are length and f before time zero.
  % The assumption is that at time zero, reserve density adapts instantaneously to the new f
  %
  % Input
  %
  % * t: n-vector with time since L equals Lb0(1) or since birth if Lb0 is empty
  %     the code assumes that t(1) < ap - ab
  % * f: scalar with functional response
  % * p: 9-vector with parameters:
  %     kappa; kappa_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp
  % * Lf: optional scalar with length at birth (initial value only)
  %
  %     or optional 2-vector with length, L, and f before time 0
  %     for a individual that is now exposed to f, but previously at another f
  %  
  % Output
  %
  % * N: n-vector with cumulative reproduction
  % * L: n-vector with structural length
  % * UE0; scalar with initial scaled reserve
  % * Lb: scalar with structural length at birth
  % * Lp: scalar with structural length at puberty
  % * t_b: time at birth
  % * t_p: time at puberty 
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % For type M acceleration see <cum_reprod_j.html *cum_reprod_j*> 
  %   and for delayed type M acceleration <../cum_reprod_s.m *cum_reprod_s*>.
  % See also <reprod_rate.html *reprod_rate*>, <reprod_rate_foetus.html *reprod_rate_foetus*>, 
  %   <reprod_rate_j.html *reprod_rate_j*> and <reprod_rate_s.html *reprod_rate_s*>
  
  %% Example of use
  % see <../mydata_cum_reprod.m *mydata_cum_reprod*>
  
  % unpack parameters; parameter sequence, cf get_pars_r
  kap = p(1); kapR = p(2); g = p(3);   kJ = p(4);  kM = p(5);
  LT = p(6);  v = p(7);    
  UHb = p(8); UHp = p(9);

  % compound parameters and par-vector
  Lm = v/ (kM * g); % cm, max length
  rB = kM/ (1 + f/ g)/ 3; % 1/d, von Bert growth rate
  k = kJ/ kM;       % -, maintenance ratio
  VHb = UHb/ (1 - kap);        VHp = UHp/ (1 - kap);
  vHb = VHb * g^2 * kM^3/ v^2; vHp = VHp * g^2 * kM^3/ v^2; 

  p_lb = [g; k ; vHb];             % pars for get_lb
  p_lp = [g; k; LT/ Lm; vHb; vHp]; % pars for get_tp
  p_UE0 = [VHb; g; kJ; kM; v];     % pars for initial_scaled_reserve  
  p_mat = [kap; kapR; g; kJ; kM; LT; v; UHb; UHp]; % pars for maturity

  if exist('Lf','var') == 0
    Lf = [];
  end
  
  if length(Lf) <= 1
    l0 = Lf/ Lm; % scaled length at birth
    [tp tb lp lb info_tp] = get_tp(p_lp, f, l0);
    ap = tp/ kM; ab = tb/ kM; % d, age at puberty, birth
    t_b = 0;       % d, time since birth at birth
    t_p = ap - ab; % d, time since birth at puberty
    Lb = lb * Lm; Lp = lp * Lm; Li = f * Lm - LT; % volumetric length at birth, puberty, ultimate
    L0 = Lb;       % cm, structural length at time zero
    UH0 = UHb;     % d.cm^2, scaled maturity at time zero
    if info_tp ~= 1 % return at failure for tp
      fprintf('tp could not be obtained in cum_reprod \n')
      N = t(:,1) * 0; L = N; UE0 = [];
      return;
    end
  else % if length Lb0 = 2
    L0 = Lf(1); % cm, structural length at time 0
    f0 = Lf(2); % -, scaled func response before time 0
    rB0 = kM/ (1 + f0/ g)/ 3; % von Bert growth rate before time zero
    Lb = Lm * get_lb(p_lb, f0); % cm, structural length at birth
    Li = f0 * Lm - LT;
    t_b = (log((Li - L0)/ (Li - Lb)))/ rB0;     % d, time at birth  
    [UH0, a0, info_mat] = maturity(L0, f0, p_mat);  % d.cm^2, maturity at zero
    if info_mat ~= 1% return at failure for tp
      fprintf('maturity could not be obtained in cum_reprod \n')
      N = t(:,1) * 0; UE0 = [];
      return;
    end
    [UH, tL] = ode45(@dget_tL, [UH0; UHp], [0; L0], [], f, g, v, kap, kJ, Lm, LT); 
    Lp = tL(end,2);  % cm, struc length at puberty after time 0
    if L0 > Lp
      fprintf('Length at zero is larger than that at puberty\n')
      N = t(:,1) * 0; UE0 = [];
      return;
    end
    t_p = tL(end,1); % d, time at puberty
  end
 
  [t LU] = ode45(@dcum_reprod, [-1e-10; t], [L0; UH0], [], f, g, v, kap, kJ, UHp, Lm, LT, t_p);
  LU(1,:) = [];   L = LU(:,1); UR = LU(:,2);
  [UE0, Lb, info] = initial_scaled_reserve(f, p_UE0, Lb);
  if info ~= 1 % return at failure for tp
    fprintf('UE0 could not be obtained in cum_reprod \n')
  end
  N = max(0, kapR * UR/ UE0); % convert to number of eggs
end

% subfunctions

function dtL = dget_tL (UH, tL, f, g, v, kap, kJ, Lm, LT)
  % called by cum_reprod
  L = tL(2);
  r = v * (f/ L - (1 + LT/ L)/ Lm)/ (f + g); % 1/d, spec growth rate
  dL = L * r/ 3; % cm/d, d/dt L
  dUH = (1 - kap) * L^2 * f * (1 - r * L/ v) - kJ * UH; % cm^2, d/dt UH
  dtL = [1; dL]/ dUH; % 1/cm, d/dUH L
end

function dLU = dcum_reprod(t, LU, f, g, v, kap, kJ, UHp, Lm, LT, t_p)
  % called by cum_reprod

  L = LU(1); % unpack state variables: length & reprod buffer
  
  r = v * (f/ L - (1 + LT/ L)/ Lm)/ (f + g); % 1/d, spec growth rate
  dL = L * r/ 3;                             % cm/d, d/dt L

  if t < t_p
    dUR = 0;
  else
    SC = f * L^3 .* (g/ L + (1 + LT/ L)/ Lm)/ (f + g);
    dUR = (1 - kap) * SC - kJ * UHp;
  end
  dLU = [dL; dUR];
end
  