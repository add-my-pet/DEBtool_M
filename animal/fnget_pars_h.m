function [Lb, Li, rB] = fnget_pars_h(p, fLbw, fLiw, frBw)
  % called by get_pars_h

  % unpack input parameters
  VHb = p(1); % scaled maturity at birth
  g   = p(2); % energy investment ratio
  kJ  = p(3); % maturity maintenance rate coefficient
  kM  = p(4); % somatic maintenance rate coefficient
  v   = p(5); % energy conductance

  f = fLbw(:,1); % scaled functional responses
  % is supposed to be the same for all 3 data sets

  nf = length(f); Lb = zeros(nf,1);
  q = [g; kJ/ kM; VHb * g^2 * kM^3/ v^2]; % pars for get_lb
  for i = 1:nf % get Lb
    [lb info(i)] = get_lb(q, f(i)); %% continuation
    %% try get_lb1 or get_lb2 for higher accuracy
    Lb(i) = lb * v/ kM/ g;
  end
  Lm = v/ (kM * g); Li = f * Lm; % max, ultimate length
  rB = kM * g ./ (3 * (f + g));  % von Bert growth rate
