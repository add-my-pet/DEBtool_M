% run filter on pars
for i = 1:1e3
  pars = rand_pars_9; 
  [F flag] = filter_pars_9(pars);
  if F == 1 %|| F == 0
    data = iget_pars_9(pars);
    Pars = get_pars_9(pars);
    error = sum(abs(pars - Pars) ./ pars)/ 9;
    fprintf([num2str(i), ' ', num2str(error), '\n'])
    fprintf([num2str(i),'\n'])
  else
    fprintf([num2str(i), ' ', num2str(flag), '\n'])
  end
end