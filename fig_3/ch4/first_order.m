function E = first_order(p, tE)
  global EG kE pM
  E0 = p(1); EG = p(2); kE = p(3); pM = p(4);

  E = lsode("dfirst_order", E0, tE(:,1));
endfunction
