  function [Lb, Lp, Li, rB, Ri] = fnget_pars_t(p, fLbw, fLpw, fLiw, frBw, fRiw)
    % created 2006/10/27 by Bas Kooyman, modified 2007/08/07
    % called by get_pars_t
    % calls initial_scaled_reserve

    global kapR

    ns = size(fLbw,1); % number of samples
    F = fLbw(:,1); % scaled functional responses
    % is supposed to be the same for all 5 data sets
  
    % unpack parameters; this is the only difference with fnget_lnpars_t
    kap = p(1); % fraction allocated to somatic maint + growth
    g   = p(2); % energy investment ratio
    kM  = p(3); % somatic maintenance rate coefficient
    v   = p(4); % energy conductance
    Hb  = p(5); % scaled maturity at birth: M_H^b/{J_EAm}
    Hp  = p(6); % scaled maturity at puberty: M_H^p/{J_EAm}

    kJ  = kM; % maturity maintenance rate coefficient
    Lm = v/ (kM * g); Li = F * Lm; % max, ultimate length
    rB = kM * g ./ (3 * (F + g)); % von Bert growth rate

    % initial scaled reserve M_E^0/{J_EAm}, length at birth
    [U0, Lb] = initial_scaled_reserve(F, [Hb/ (1 - kap); g; kJ; kM; v]); 
    % get Lp, Ub, Up, Ri given kJ = kM
    Ub = F .* Lb .^ 3/ v; % scaled reserve at birth: M_E^b/{J_EAm}
    Lp = ones(ns,1) * (Hp * v/ ((1 - kap) * g))^(1/3); % length at puberty
    Up = Ub .* (Lp ./ Lb) .^ 3; % scaled reserve at puberty: M_E^p/{J_EAm}
    Ri = ((1 - kap) * F .* Li .^2 - kJ * Hp) * kapR ./ U0; % ultimate reprod
    