function f = hyp(p, XV)
  f = p(1) * (XV(:,1) ./ (XV(:,1) + p(2))) .^ 3;
