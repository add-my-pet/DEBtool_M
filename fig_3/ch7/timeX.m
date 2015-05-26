function f = timeX(p,X)
  %% gut residence time is inversely proportional to feeding rate
  f = p(2) * (X(:,1) + p(1)) ./ X(:,1);
