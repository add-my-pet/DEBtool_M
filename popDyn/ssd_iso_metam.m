%% ssd_iso_metam
% Gets mean age, L, L^2, L^3 and specific growth rate in case of type M acceleration

%%
function [r Ea EL EL2 EL3 info] = ssd_iso_metam(p, f, r0) 
  %  created 2011/05/02 by Bas Kooijman, modified 2011/07/27 
  
  %% Syntax  
  % [r Ea EL EL2 EL3 info] = <../ssd_iso_metam.m *ssd_iso_metam*> (p, f, r0)
  
  %% Description
  % Obtains mean age, length, squared length, cubed length, spec pop growth rate.
  % Embryonic stage is excluded, early juvenile V1-stage is assumed.
  % Food ensity is assumed to be constant.
  %
  % Input
  %
  % * p: 12-vector with parameters: kap kapR g kJ kM LT v UHb UHj UHp ha sG
  % * f: optional scalar with scaled function response (default 1)
  % * r0: optional scalar with specific population growth rate
  %
  %     if specified, its computation is supressed
  %
  % Output
  %
  % * r: scalar with specific population growth rate
  % * Ea: scalar with mean age of juveniles & adults
  % * EL: scalar with mean structural length
  % * EL2: scale with mean squared structural length
  % * EL3: scale with mean cubed structural length
  % * info: scalar with 1 for success, 0 otherwise
  
  %% Remarks
  % Uses <ssd_iso_metam.html *ssd_iso_metam*> for the specific growth rate
  % r is numerically solved from: 1 = \int_0^infty S(t) R(t) exp(- r t) dt
  
  %% Example of use
  % [r Ea EL EL2 EL3 info] = ssd_iso_metam([0.8 0.95 0.1 0.002 0.02 0 0.02 1 2 5 1e-7 1e-8])
 
  % unpack parameters
  kap = p(1); kapR = p(2); g   = p(3); 
  kJ  = p(4); kM   = p(5); LT  = p(6);  
  v   = p(7); UHb  = p(8); UHj = p(9);
  UHp = p(10); ha  = p(11); sG = p(12);

  k = kJ/ kM; Lm = v/ g/ kM; lT = LT/ Lm; 
  VHb = UHb/ (1 - kap); vHb = VHb * g^2 * kM^3/ v^2; 
  VHj = UHj/ (1 - kap); vHj = VHj * g^2 * kM^3/ v^2; 
  VHp = UHp/ (1 - kap); vHp = VHp * g^2 * kM^3/ v^2;

  if ~exist('f', 'var')
    f = 1;
  end

  if exist('r0', 'var')
    r = r0; info = 1; 
    pars_tj = [g k lT vHb vHj];
    [tj tp tb lj lp lb li rhoj rhoB] = get_tj(pars_tj, f, vHb^(1/3));
  else
    pars_tj = [g k lT vHb vHj vHp];
    [tj tp tb lj lp lb li rhoj rhoB] = get_tj(pars_tj, f, vHb^(1/3));
    [r info tb tj tp lb] = sgr_iso_metam (p, f);
  end
  rho = r/ kM;
  hW = (ha * g/ 6/ kM^2)^(1/3); % hW/ kM
  hG = sG * g * f^3; % hG/ kM
  hWG3 = (hW/ hG)^3;
  tm = roots3([hW^3 0 rho log(1e-12)],1);

  N = quad(@fnE_iso, tb, tm, [], [], rho, hWG3, hW, hG); % norm to ensure that pdf integrates till 1
  Ea = quad(@fnEa_iso, tb, tm, [], [], rho, hWG3, hW, hG)/ N/ kM;
  EL  = Lm   * quad(@fnEL_iso_metam,  tb, tm, [], [], rho, rhoj, rhoB, lb, lj, li, tj, hWG3, hW, hG)/ N;
  EL2 = Lm^2 * quad(@fnEL2_iso_metam, tb, tm, [], [], rho, rhoj, rhoB, lb, lj, li, tj, hWG3, hW, hG)/ N;
  EL3 = Lm^3 * quad(@fnEL3_iso_metam, tb, tm, [], [], rho, rhoj, rhoB, lb, lj, li, tj, hWG3, hW, hG)/ N;
end

% subfunctions

function int = fnEL_iso_metam(t, rho, rhoj, rhoB, lb, lj, li, tj, hWG3, hW, hG) 
  % t: a * kM
  % int: l(t)^2 * exp(- rho*t) * S(t)
  % called by ssd_iso_metam

  if hWG3 > 100
    S = exp(- (hW * t).^3 - rho * t);
  else
    hGt = hG * t;
    S = exp(6 * hWG3 * (1 - exp(hGt) + hGt + hGt .^ 2/2) - rho * t);
  end

  if t < tj
    l = lb * exp(t * rhoj/ 3);
  else
    l = li - (li - lj) * exp( - rhoB * (t - tj));
  end
  int = S .* l;
end

function int = fnEL2_iso_metam(t, rho, rhoj, rhoB, lb, lj, li, tj, hWG3, hW, hG)
  % t: a * kM
  % int: l(t)^2 * exp(- rho*t) * S(t)
  % called by ssd_iso_metam

  if hWG3 > 100
    S = exp(- (hW * t).^3 - rho * t);
  else
    hGt = hG * t;
    S = exp(6 * hWG3 * (1 - exp(hGt) + hGt + hGt .^ 2/2) - rho * t);
  end

  if t < tj
    l = lb * exp(t * rhoj/ 3);
  else
    l = li - (li - lj) * exp( - rhoB * (t - tj));
  end
  int = S .* l.^2;
end

function int = fnEL3_iso_metam(t, rho, rhoj, rhoB, lb, lj, li, tj, hWG3, hW, hG)
  % t: a * kM
  % int: l(t)^3 * exp(- rho*t) * S(t)
  % called by ssd_iso_metam

  if hWG3 > 100
    S = exp(- (hW * t).^3 - rho * t);
  else
    hGt = hG * t;
    S = exp(6 * hWG3 * (1 - exp(hGt) + hGt + hGt .^ 2/2) - rho * t);
  end

  if t < tj
    l = lb * exp(t * rhoj/ 3);
  else
    l = li - (li - lj) * exp( - rhoB * (t - tj));
  end
  int = S .* l.^3;
end