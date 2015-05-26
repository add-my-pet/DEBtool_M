%% cum_reprod_j
% gets cumulative reproduction as function of time for type M acceleration

%%
function [N, L, UE0, Lb, Lj, Lp, t_b, t_j, t_p, info] = cum_reprod_j(t, f, p, Lf)
  % created 2008/08/06 by Bas Kooijman, modified Starrlight Augustine 2014/03/20
  
  %% Syntax
  % [N, L, UE0, Lb, Lj, Lp, t_b, t_j, t_p, info] = <../cum_reprod_j.m *cum_reprod_j*> (t, f, p, Lf)

  %% Description
  % Calculates the cumulative reproduction in number of eggs for type M acceleration
  %   for an individual of time since birth t and scaled reserve density e = f.
  % Optionally the initial conditions are length and f before time zero.
  % The assumption is that at time zero, reserve density adapts instantaneously to the new f.
  %
  % Input
  %
  % * t: n-vector with time since L equals Lb0(1) or since birth if Lb0 is empty
  %      the code assumes that t(1) < ap - ab
  % * f: scalar with functional response
  % * p: 10-vector with parameters:
  %     kappa; kappa_R; g; k_J; k_M; L_T; v; U_Hb; U_Hj; U_Hp
  % * Lf: optional scalar with length at birth (initial value only)
  %     or optional 2-vector with length, L, and f before time 0
  %     for a individual that is now exposed to f, but previously at another f
  %  
  % Output
  %
  % * N: n-vector with cumulative reproduction
  % * L: n-vector with structural length
  % * UE0; scalar with initial scaled reserve
  % * Lb: scalar with structural length at birth
  % * Lj: scalar with structural length at metamorphosis
  % * Lp: scalar with structural length at puberty
  % * t_b: time at birth
  % * t_j: time at metamorphosis
  % * t_p: time at puberty 
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % For standard DEB model see <cum_reprod.html *cum_reprod*> 
  %  and for delayed type M acceleration <cum_reprod_s.html *cum_reprod_s*>.
  % See also <reprod_rate.html *reprod_rate*>, <reprod_rate_foetus.html *reprod_rate_foetus*>, 
  %  <reprod_rate_j.html *reprod_rate_j*> and <reprod_rate_s.html *reprod_rate_s*>
 
  %% Example of use
  % See <../mydata_cum_reprod.m *mydata_cum_reprod*>
  
  % unpack parameters; parameter sequence, cf get_pars_r
  kap = p(1); kapR = p(2); g = p(3);  kJ = p(4);  kM = p(5);
  LT = p(6);  v = p(7); UHb = p(8); UHj = p(9); UHp = p(10);

  % compound parameters and par-vectors
  Lm = v/ (kM * g); % cm, max length
  k = kJ/ kM;       % -, maintenance ratio
  VHb = UHb/ (1 - kap); VHj = UHj/ (1 - kap); VHp = UHp/ (1 - kap);
  vHb = VHb * g^2 * kM^3/ v^2; vHj = VHj * g^2 * kM^3/ v^2; vHp = VHp * g^2 * kM^3/ v^2; 

  p_UE0 = [VHb; g; kJ; kM; v];          % pars for initial_scaled_reserve  
  p_tj = [g; k; LT/ Lm; vHb; vHj; vHp]; % pars for get_tj
  p_mat = [kap; kapR; g; kJ; kM; LT; v; UHb; UHj; UHp]; % pars for maturity_j

  if exist('Lf','var') == 0
    Lf = [];
  end
  
  if length(Lf) <= 1
    l0 = Lf/ Lm; % scaled length at birth
    [tj tp tb lj lp lb li rhoj rhoB info_tj] = get_tj(p_tj, f, l0);
    ap = tp/ kM; aj = tj/ kM; ab = tb/ kM; % d, age at puberty, metamorphosis, birth
    t_b = 0;       % d, time since birth at birth
    t_j = aj - ab; % d, time since birth at metamorphosis
    t_p = ap - ab; % d, time since birth at puberty
    Lb = lb * Lm; Lj = lj * Lm; Lp = lp * Lm; Li = li * Lm; % volumetric length at birth, metamorphosis, puberty, ultimate
    L0 = Lb;       % cm, structural length at time zero
    UH0 = UHb;     % d.cm^2, scaled maturity at time zero
    if info_tj ~= 1% return at failure for tj
      fprintf('tj could not be obtained in cum_reprod_j \n')
      N = t(:,1) * 0; L = N; UE0 = [];
      return;
    end
  else % if length Lb0 = 2
    L0 = Lf(1); % cm, structural length at time 0
    f0 = Lf(2); % -, scaled func response before time 0
    [tj tp tb lj lp lb li rhoj0 rhoB0 info_tj] = get_tj(p_tj, f0);
    if info_tj ~= 1% return at failure for tp
      fprintf('maturity_j could not be obtained in cum_reprod_j \n')
      N = t(:,1) * 0; UE0 = [];
      return;
    end
    Lb = lb * Lm; Lj = lj * Lm; Lp = lp * Lm; Li = li * Lm;
    if L0 > Lp
      fprintf('Length at zero is larger than that at puberty\n')
      N = t(:,1) * 0; UE0 = [];
      return;
    end
    [UH0, a0, info_tj] = maturity_j(L0, f0, p_mat);  % before time 0
    if info_tj ~= 1% return at failure for tp
      fprintf('maturity_j could not be obtained in cum_reprod_j \n')
      N = t(:,1) * 0; UE0 = [];
      return;
    end
    if UHj < UH0 % UHb < UHj < UH0 < UHp
      [UH, tL] = ode45(@dget_tL_jp, [UH0; UHp], [0; L0], [], f, g, v, kap, kJ, Lb, Lj, Lm, LT); 
    else % UHb < UH0 < UHj < UHp
      [UH, tL] = ode45(@dget_tL_jp, [UH0; UHj; UHp], [0; L0], [], f, g, v, kap, kJ, Lb, Lj, Lm, LT); 
       t_j = tL(2,1); Lj = tL(2,2);
    end
    t_p = tL(end,1); Lp = tL(end,2); % cm, struc length at puberty after time 0
    
    [tj tp tb lj lp lb li rhoj rhoB info_tj] = get_tj(p_tj, f);
    t_j = t_p - (tp - tj)/ kM;
    t_b = t_p - (tp - tb)/ kM;
  end
 
  [t LU] = ode45(@dcum_reprod_j, [-1e-10; t], [L0; 0], [], f, g, v, kap, kJ, UHp, Lb, Lj, Lm, LT, t_p);
  LU(1,:) = []; L = LU(:,1); UR = LU(:,2);
  [UE0, Lb, info] = initial_scaled_reserve(f, p_UE0, Lb);
  if info ~= 1 % return at failure for tp
    fprintf('UE0 could not be obtained in cum_reprod_j \n')
  end
  N = max(0, kapR * UR/ UE0); % convert to number of eggs
  
end

% subfunctions

function dtL = dget_tL_jp(UH, tL, f, g, v, kap, kJ, Lb, Lj, Lm, LT)
  % called by cum_reprod_j: UH between UHb and UHp
 
  L = tL(2); % cm, structural length
  sM = min(L, Lj)/ Lb;
  r = v * (f * sM/ L - (1 + LT * sM/ L)/ Lm)/ (f + g); % 1/d, spec growth rate
  dL = L * r/ 3;                  % cm/d, d/dt L
  SC = f * L^3 * (sM/ L - r/ v);  % cm^2, p_C/ {p_Am}
  dUH = (1 - kap) * SC - kJ * UH; % cm^2, d/dt UH
  dtL = [1; dL]/ dUH;                               % 1/cm, d/dUH L

end

function dLU = dcum_reprod_j(t, LU, f, g, v, kap, kJ, UHp, Lb, Lj, Lm, LT, t_p)
  % called by cum_reprod_j
  
  L = LU(1); % unpack state variables: length & reprod buffer

  sM = min(L, Lj)/ Lb;
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
  