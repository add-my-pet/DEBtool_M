function fm = f_mean(n,f)
  %% n: (N,1)-vector with numbers
  %% f: (sum(n),1)-vector with values
  %% fm:(N,1)-vector with mean values

  N = length(n); fm = zeros(N,1); x = 1;
  for i = 1:N
    fm(i) = sum(f(x:(x + n(i) - 1)))/ n(i);
    x = x + n(i);
  end  
  
