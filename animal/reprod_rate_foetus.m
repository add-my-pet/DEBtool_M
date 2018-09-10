%% reprod_rate_foetus
% gets reproduction rate as function time for foetal development

%%
function [R, UE0, Lb, Lp] = reprod_rate_foetus(L, f, p)
  % created 2010/09/09 by Bas Kooijman, modified 2012/08/29
  % modified 2018/09/10 (fixed typos in description) Nina Marn
  
  %% Syntax
  % [R, UE0, Lb, Lp] = <../reprod_rate_foetus.m *reprod_rate_foetus*> (L, f, p)
  
  %% Description
  % Calculates the reproduction rate in number of foetusses per time
  % for an individual of length L and scaled reserve density f
  %
  % Input
  %
  % * L: n-vector with length
  % * f: scalar with functional response
  % * p: 9 or 10-vector with parameters: kap kapR g kJ kM LT v UHb UHp and
  %     optionally sF (default: sF = 1e8 for slow foetal develpment), see comments to DEB3
  % * Lb0: optional scalar with length at birth (initial value only)
  %
  %      or optional 2-vector with length, L, and scaled maturity, UH < UHp
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
  % See also <reprod_rate.html *reprod_rate*>, 
  %   <reprod_rate_j.html *reprod_rate_j*>, and <reprod_rate_s.html *reprod_rate_s*>.
  % For cumulative reproduction, see <cum_reprod.html *cum_reprod*>,
  %  <cum_reprod_j.html *cum_reprod_j*>, <cum_reprod_s.html *cum_reprod_s*>
   
  %% Example of use
  % p_R = [.8 .95 .42 1.7 1.7 0 3.24 .012 .366]; 
  % reprod_rate_foetus([.5 1 10 30]', 1, p_R)
  
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
  if length (p) >=10
    sF = p(10); % if 1: fast foetal development
  else
    sF = 1e8;   % slow foetal development
  end

  Lm = v/ (kM * g); % maximum length
  VHb = UHb/ (1 - kap); VHp = UHp/ (1 - kap);
  vHb = VHb * g^2 * kM^3/ v^2; vHp = VHp * g^2 * kM^3/ v^2; 
  k = kJ/ kM;

  p_tx = [g; k; LT/ Lm; vHb; vHb+1e-9; max(vHb+2e-10,vHp); sF]; % pars for get_tx
  [tp tx tb lp lx lb] = get_tx(p_tx, f); %-, scaled ages, lengths
  Lb = lb * Lm; Lp = lp * Lm; % volumetric length at birth, puberty
  UE0 = Lb^3 * (f + g)/ v * (1 + 3 * lb/ 4/ f); % d.cm^2, scaled cost per foetus

  SC = f * L.^3 .* (g ./ L + (1 + LT ./ L)/ Lm)/ (f + g);
  SR = (1 - kap) * SC - kJ * UHp;
  R = (L >= Lp) * kapR .* SR/ UE0; % set reprod rate of juveniles to zero
