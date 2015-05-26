function f = bert(p,a)
  ## von Bertalanffy growth model: Eq 3.20 {95}
  f = p(2) - (p(2) - p(1)) * exp( - p(3) * a(:,1));
endfunction
