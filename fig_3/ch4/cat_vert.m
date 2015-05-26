function r = cat_vert(n,f);
  ## n: (m,1)-matrix with integers
  ## f; (m,1)-matrix with values
  ## r: (sum(n),1)-matrix with vertically catenated values

  N = length(n); r = [];
  for i=1:N
    r = [r; f(i) * ones(n(i),1)];
  end
endfunction
