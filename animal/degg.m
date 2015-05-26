function dEV = degg(t, EViV)

    global EG Em pM pAm kap

    % unpack state variables
    E = EViV(1); V = EViV(2); L = abs(V)^(1/3);

    Lm = kap * pAm/ pM; v = pAm/ Em;
    r = v * (E/ L - Em * V/ Lm)/ (E + EG * V/ kap);
    dEV = [E * (r - v/ L); r * V; V];