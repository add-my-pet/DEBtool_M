%% ssd_iso_foetus
% Gets mean age, L, L^2, L^3 and specific growth rate in case of foetal development

%%
function [r Ea EL EL2 EL3 info] = ssd_iso_foetus(p, f, r0) 
  % created 2010/09/29 by Bas Kooijman
  
  %% Syntax
  % [r Ea EL EL2 EL3 info] = <../ssd_iso_foetus.m *ssd_iso_foetus*> (p, f, r0) 
  
  %% Description
  % Obtains mean age, length, squared length, cubed length, spec pop growth rate of isomorphs.
  % Foetal development is assumed, without acceleration and the embryonic stage is excluded.
  % Food ensity is assumed to be constant.
  %
  % Input
  %
  % * p: 11-vector with parameters: kap kapR g kJ kM LT v UHb UHp ha sG
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
  %  r is solved numerically from: 1 = \int_0^infty S(t) R(t) exp(- r t) dt
  % See <ssd_iso.html *ssd_iso*> for egg development.
  
  %% Example of use
  %  [r Ea EL EL2 EL3 info] = ssd_iso_foetus([0.8 0.95 0.1 0.002 0.02 0 0.02 1 5 1e-7 1e-8])

  % unpack parameters
  kap = p(1); kapR = p(2); g   = p(3); 
  kJ  = p(4); kM   = p(5); LT  = p(6);  
  v   = p(7); UHb  = p(8); UHp = p(9);
  ha = p(10); sG = p(11);

  if ~exist('f','var') 
    f= 1;
  end

  if exist('r0', 'var')
    r = r0; info = 1; tp = 1e6; 
  else
    [r info tb tp lb] = sgr_iso_foetus (p, f);
  end
  rho = r/ kM;

  Lm = v/ g/ kM;
  rhoB = 1/ (3 + 3 * f/g); % rB/ kM
  hW = (ha * g/ 6/ kM^2)^(1/3); % hW/ kM
  hG = sG * g * f^3; % hG/ kM
  hWG3 = (hW/ hG)^3;
  tm = roots3([hW^3 0 rho log(1e-12)],1);

  N = quad('fnE_iso', tb, tm, [], [], rho, hWG3, hW, hG); % norm to ensure that pdf integrates till 1
  Ea = quad('fnEa_iso', tb, tm, [], [], rho, hWG3, hW, hG)/ N/ kM;
  EL = Lm * quad('fnEL_iso', tb, tm, [], [], f, lb, tb, rho, rhoB, hWG3, hW, hG)/ N;
  EL2 = Lm^2 * quad('fnEL2_iso', tb, tm, [], [], f, lb, tb, rho, rhoB, hWG3, hW, hG)/ N;
  EL3 = Lm^3 * quad('fnEL3_iso', tb, tm, [], [], f, lb, tb, rho, rhoB, hWG3, hW, hG)/ N;