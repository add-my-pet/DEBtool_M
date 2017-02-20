%% get_tp_foetus
% Gets scaled age at puberty for foetal development

%%
function [tp tb lp lb info] = get_tp_foetus(p, f, lb0)
  % created at 2011/04/16 by Bas Kooijman, modified 2015/01/18, 2017/02/20
  
  %% Syntax 
  % [tp tb lp lb info] = <../get_tp_foetus.m *get_tp_foetus*>(p, f, lb0)
  
  %% Description
  % Obtains scaled age at puberty in the case of foetal development;
  % Food density is assumed to be constant.
  % Multiply the result with the somatic maintenance rate coefficient to arrive at age at puberty. 
  %
  % Input
  %
  % * p: 5-vector with parameters: g, k, l_T, v_H^b, v_H^p 
  % * f: optional scalar with functional response (default f = 1)
  % * lb0: optional scalar with scaled length at birth
  %
  %      or optional 2-vector with scaled length, l, and scaled maturity, vH
  %      for a juvenile that is now exposed to f, but previously at another f
  %
  % Output
  %
  % * tp: scaled with age at puberty \tau_p = a_p k_M
  %
  %      if length(lb0)==2, tp is the scaled time till puberty
  %
  % * tb: scaled with age at birth \tau_b = a_b k_M
  % * lp: scaler length at puberty
  % * lb: scaler length at birth
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % Function <get_tp.html *get_tp*> does the same for egg development. 

  %% Example of use
  % get_tp_foetus([.5, .1, .1, .01, .2])

  %  unpack pars
  g   = p(1); % energy investment ratio
  k   = p(2); % k_J/ k_M, maintenance ratio
  lT  = p(3); % scaled heating length {p_T}/[p_M]Lm
  vHb = p(4); % v_H^b = U_H^b g^2 kM^3/ (1 - kap) v^2; U_B^b = M_H^b/ {J_EAm}
  vHp = p(5); % v_H^p = U_H^p g^2 kM^3/ (1 - kap) v^2; U_B^p = M_H^p/ {J_EAm}
  
  if ~exist('f','var')
    f = 1;
  elseif isempty(f)
    f = 1;
  end

  info = 1;
  if k == 1 && f * (f - lT)^2 > vHp * k
    lb = vHb^(1/3); 
    tb = get_tb_foetus([g, k, vHb]);
    lp = vHp^(1/3);
    li = f - lT;
    rB = 1 / 3/ (1 + f/g);
    tp = tb + log((li - lb)/ (li - lp))/ rB;
  elseif f * (f - lT)^2 <= vHp * k % reproduction is not possible
    [tb lb] = get_tb_foetus ([g k vHb]); 
    tp = 1e20; % tau_p is never reached
    lp = 1;    % lp is nerver reached
  else % reproduction is possible
    if exist('lb0','var') == 0
      lb0 = [];
    end

    li = f - lT;
    irB = 3 * (1 + f/ g); % k_M/ r_B
    [tb lb] = get_tb_foetus ([g, k, vHb]); 
    [lp lb info] = get_lp(p, f, lb);
    if length(lb0) ~= 2
      tp = tb + irB * log((li - lb)/ (li - lp));
    else % lb0 = l and t for a juvenile
      tb = NaN;
      l = lb0(1);
      tp = irB * log((li - l)/ (li - lp));
    end
  end
  
  if isreal(tp) == 0 % tp must be real and positive
      info = 0;
  elseif tp < 0
      info = 0;
  end
  
  