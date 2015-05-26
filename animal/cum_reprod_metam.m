%% cum_reprod_metam 
% gets cumulative reproduction as function of time for type M acceleration

%%
function [N, UE0, Lb, Lj, Lp, ab, aj, ap, info] = cum_reprod_metam(a, f, p, Lb0)
  % created 2011/06/16 by Bas Kooijman, modified Starrlight Augustine 2012/08/28

  %% Syntax
  % function [N, UE0, Lb, Lj, Lp, ab, aj, ap, info] = <../cum_reprod_metam.m *cum_reprod_metam*>(a, f, p, Lb0)

  %% Description
  % Calculates the cumulative reproduction in number of eggs with acceleration as juvenile 
  %   for an individual of age a and scaled reserve density e. 
  %
  % Input
  %
  % * a: n-vector with time since birth or since start if Lb0 has length 2
  % * f: scalar with functional response
  % * p: 10-vector with parameters:
  %     kappa; kappa_R, g, k_J, k_M, L_T, v, U_Hb, U_Hj, U_Hp
  %
  %     g and v refer to the values for embryo; scaling is always with respect to embryo values
  %
  % * Lb0: optional scalar with length at birth (initial value only)
  %
  %     or optional 2-vector with length, L, and scaled maturity, UH < UHp
  %     for a juvenile that is now exposed to f, but previously at another f
  %  
  % Output
  %
  % * N: n-vector with cumulative reproduction
  % * UE0; scalar with initial scaled reserve
  % * Lb: scalar with length at birth
  % * Lp: scalar with length at puberty
  % * ab: age at puberty at birth
  % * ap: time at puberty since birth or time till puberty if Lb0 has length 2
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % The function <cum_reprod.html *cum_reprod*> does the same, but without acceleration.
  % For reproduction rates see <reprod_rate_metam.html *reprod_rate_metam*> for reproduction rate.
  % *This function will be phased out* and replaced by <cum_reprod_j.html *cum_reprod_j*>
  
  %% Example of use
  % p_R = [.8 .95 .42 1.7 1.7 0 3.24 .012 .366]; 
  %    cum_reprod([.5 1 10 30]', 1, p_R). 
  
  % unpack parameters; parameter sequence, cf reprod_rate_metam
  kap = p(1); kapR = p(2);  g = p(3);  kJ = p(4) ; 
   kM = p(5);   LT = p(6);  v = p(7); UHb = p(8);
  UHj = p(9);  UHp = p(10);

  % compound parameters and par-vector
  Lm = v/ (kM * g); % max length
  VHb = UHb/ (1 - kap); VHj = UHj/ (1 - kap); VHp = UHp/ (1 - kap);
  vHb = VHb * g^2 * kM^3/ v^2; vHj = VHj * g^2 * kM^3/ v^2; vHp = VHp * g^2 * kM^3/ v^2; 
  p_tj = [g; kJ/ kM; LT/ Lm; vHb; vHj; vHp];   % pars for get_tj
  p_UE0 = [VHb; g; kJ; kM; v]; % pars for initial_scaled_reserve  

  if exist('Lb0','var') == 0
    lb0 = [];
  else
    lb0 = Lb0/ Lm; % scaled length at birth
  end
 
  [tj tp tb lj lp lb li rhoj rhoB info] = get_tj(p_tj, f, lb0);
  ab = tb/ kM;  aj = tj/ kM; ap = tp/ kM; rB = kM * rhoB;
  Lb = lb * Lm; Lj = lj * Lm; Lp = lp * Lm; % volumetric length at birth, puberty
  if info ~= 1 % return at failure for tp
    fprintf('tp could not be obtained in cum_reprod_metam \n')
    N = a(:,1) * 0; UE0 = [];
    return;
  end

  sM = lj/ lb; % -, acceleration factor 
  a0 = 0; na = length(a); % number of time points
  Ui = 0; U = 0 * a; % initialise U: scaled reserve allocated to reprod
  for i = 1:na
    if a(i) + ab < aj
      Ui = 0;
    else
      if a0 < a(i)
        Ui = Ui + quad(@fncum_reprod_metam, a0 + ab - aj, a(i) + ab - aj, [], [], f, g, kap, kJ, UHp, Lj, Lp, Lm, LT, rB, sM); 
        a0 = a(i);
      end
    end
    U(i) = Ui;
  end
    
  [UE0 Lb info] = initial_scaled_reserve(f, p_UE0, Lb);
  if info ~= 1 % return at failure for tp
    fprintf('UE0 could not be obtained in cum_reprod_metam \n')
  end
  N = max(0, kapR * U/ UE0); % convert to number of eggs
  
end

% subfunction

function UN = fncum_reprod_metam (a, f, g, kap, kJ, UHp, Lj, Lp, Lm, LT, rB, sM)
  % called by cum_reprod_metam
  
  Li = sM * (f * Lm - LT);
  L = Li - (Li - Lj) * exp(-a * rB);
  SC = f .* L.^3 .* (g * sM ./ L + (1 + LT * sM ./ L)/ Lm)/ (f + g);
  UN = (L >= Lp) .* ((1 - kap) * SC - kJ * UHp);
end