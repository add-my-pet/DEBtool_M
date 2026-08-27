%% reprod_rate_t
% gets reproduction rate as function of time

%%
function [R, UE0, Lb, Lp, info] = reprod_rate_t(t, f, p)
  % created 2026/08/23 by Bas Kooijman
  
  %% Syntax
  % [R, UE0, Lb, Lp, info] = <reprod_rate_t.m *reprod_rate_t*>(t, f, p)
  
  %% Description
  % Calculates the reproduction rate in number of eggs per time for an individual at time since birth t and scaled reserve density f.
  %
  % Input
  %
  % * t: n-vector with time since birth
  % * f: scalar with functional response
  % * p: structure or 9-vector with parameters: kap, kapR, g, kJ, kM, LT, v, UHb, UHp
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
  % For cumulative reproduction, see <cum_reprod.html *cum_reprod*>,
   %  <cum_reprod_j.html *cum_reprod_j*>, <cum_reprod_s.html *cum_reprod_s*>
  
  %% Example of use
  % See <mydata_reprod_rate.m *mydata_reprod_rate*>
  
  %  Explanation of variables:
  %  R = kapR * pR/ E0
  %  pR = (1 - kap) pC - kJ * EHp
  %  [pC] = [Em] (v/ L + kM (1 + LT/L)) f g/ (f + g); pC = [pC] L^3
  %  [Em] = {pAm}/ v
  % 
  %  U0 = E0/{pAm}; UHp = EHp/{pAm}; SC = pC/{pAm}; 
  %
  % unpack parameters; parameter sequence, cf get_pars_r

  if isstruct(p)
    vars_pull(p);
  else 
    kap = p(1); kapR = p(2); g = p(3); kJ = p(4); kM = p(5);
    LT = p(6); v = p(7); vHb = p(8); vHp = p(9);
  end
  
  Lm = v/ (kM * g); % cm, maximum struct length
  k = kJ/ kM;       % -, maintenance ratio
  lT = LT/ Lm;

  [lp, lb, info] = get_lp([g; k; lT; vHb; vHp], f); % -, scaled struct length
  li = f-lT; Lb = Lm*lb; Lp = Lm*lp; % -, scaled max struct length
  rB = kM/3/(1+f/g); % 1/d, von Bert growth rate
  l = li-(li-lb)*exp(-rB*t); % -, scaled struc length
  uE0 = get_ue0([g; k ; vHb],f); vE0 = uE0/(1-kap); UE0 = uE0*v^2/g^2/kM^3; % scaled cost per egg
  
  R = (l>lp)*kapR*kM/vE0.*(f*l.^2/(f+g).*(g+lT+l)-k*vHp); % #/d, reprod rate 
