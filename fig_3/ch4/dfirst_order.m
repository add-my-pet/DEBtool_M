function dE = dfirst_order(E)
  global EG kE pM

  r = (E * kE - pM)/ EG;
  dE = - E * (kE + r);
endfunction
