%% get_tj_foetus
% Get scaled age at metamorphosis for foetal development

%%
function [tj tp tb lj lp lb li rj rB info] = get_tj_foetus(p, f)
  % created at 2012/06/29 by Bas Kooijman; modified 2015/01/18 Bas Kooijman
  
  %% Syntax
  % [tj tp tb lj lp lb li rj rB info] = <../get_tj_foetus.m *get_tj_foetus*> (p, f)
  
  %% Description
  % Obtains scaled ages at metamorphosis, puberty, birth and the scaled lengths at these ages in case of foetal development
  % Multiply the result with the somatic maintenance rate coefficient to arrive at unscaled ages. 
  % Metabolic acceleration occurs between birth and metamorphosis.
  % Notice j-p-b sequence in output, due to the name of the routine
  %
  % Input
  %
  % * p: 6-vector with parameters: g, k, l_T, v_H^b, v_H^j v_H^p 
  % * f: optional scalar with functional response (default f = 1)
  %  
  % Output
  %
  % * tj: scaled age at metamorphosis \tau_j = a_j k_M
  % * tp: scaled age at puberty \tau_p = a_p k_M
  % * tb: scaled age at birth \tau_b = a_b k_M
  % * lj: scaled length at end of V1-stage
  % * lp: scaled length at puberty
  % * lb: scaled length at birth
  % * li: ultimate scaled length
  % * rj: scaled exponential growth rate between s and j
  % * rB: scaled von Bertalanffy growth rate between b and s and between j and i
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % See <get_tj.html *get_tj*> in case of egg development
  
  %% Example of use
  % get_tj_foetus([.5, .1, 0, .01, .05, .2])

  %  unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, ratio of maturity and somatic maintenance rate coeff
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_H^b = E_H^b/ {p_Am}
  vHj = p(5); % v_H^j = U_H^j g^2 kM^3/ (1 - kap) v^2; U_H^j = E_H^j/ {p_Am}
  vHp = p(6); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_H^p = E_H^p/ {p_Am}
  
  if ~exist('f','var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end

  % no acceleration
  if vHb == vHj 
    [tp, tb, lp, lb, info] = get_tp_foetus(p([1 2 3 4 6]), f);
    tj = tb; lj = lb; li = f - lT; rj = 0; rB = 1/ 3/ (1 + f/ g);
    return
  end

  % maintenance ratio k = 1: maturity thresholds coincide with length thresholds
  if k == 1 && f * (f - lT)^2 > vHp * k % constant maturity density, reprod possible
    lb = vHb^(1/3);                  % scaled length at birth
    tb = get_tb_foetus(p([1 2 4]));  % scaled age at birth
    lj = vHj^(1/3);                  % scaled length at metamorphosis
    rj = g * (f/ lb - 1 - lT/ lb)/ (f + g); % scaled exponential growth rate between b and j
    tj = tb + (log(lj/ lb)) * 3/ rj; % scaled age at metamorphosis
    lp = vHp^(1/3);                  % scaled length at puberty
    li = f * lj/ lb - lT;            % scaled ultimate length
    rB = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate between j and i
    tp = tj + log ((li - lj)/ (li - lp))/ rB; % scaled age at puberty
    info = 1;
    return
  elseif k == 1 && f * (f - lT)^2 > vHj * k % constant maturity density, metam possible
    lb = vHb^(1/3);                  % scaled length at birth
    tb = get_tb_foetus(p([1 2 4]));  % scaled age at birth
    lj = vHj^(1/3);                  % scaled length at metamorphosis
    rj = g * (f/ lb - 1 - lT/ lb)/ (f + g); % scaled exponential growth rate between b and j
    tj = tb + log(lj/ lb) * 3/ rj;   % scaled age at metamorphosis
    lp = vHp^(1/3);                  % scaled length at puberty
    li = f * lj/ lb - lT;            % scaled ultimate length
    rB = 1/ 3/ (1 + f/ g);           % scaled von Bert growth rate between j and i
    tp = 1e20;                       % scaled age at puberty
    info = 1;
    return
  end
  
  tb = get_tb_foetus (p([1 2 4])); 
  [lj lp lb info] = get_lj_foetus(p, f);
  rj = g * (f/ lb - 1 - lT/ lb)/ (f + g); % scaled exponential growth rate between b and j
  tj = tb + log(lj/ lb) * 3/ rj;     % scaled age at metamorphosis
  rB = 1/ 3/ (1 + f/ g);             % scaled von Bert growth rate between j and i
  li = f * lj/ lb - lT;              % scaled ultimate length

  if  li <=  lp                      % reproduction is not possible
    tp = 1e20;                       % tau_p is never reached
    lp = 1;                          % lp is nerver reached
  else % reproduction is possible
    tp = tj + log((li - lj)/ (li - lp))/ rB;
  end
    
  if ~isreal(tp) || ~isreal(tj) % tj and tp must be real and positive
    info = 0;
  elseif tp < 0 || tj < 0
    info = 0;
  end
  