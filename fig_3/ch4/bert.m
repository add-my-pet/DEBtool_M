function f = bert(p, t)
  f = p(2) - (p(2) - p(1)) * exp(-p(3) * t(:,1));
endfunction
