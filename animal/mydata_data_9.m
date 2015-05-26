% run filter on data
for i = 1:1e3
  data = rand_data_9; 
  [F flag] = filter_data_9(data);
  if F == 1
    pars = get_pars_9(data);
    Data = iget_pars_9(pars);
    error = sum(abs(data - Data) ./ data)/ 9;
    fprintf([num2str(i), ' ', num2str(error), '\n'])
  else
    fprintf([num2str(i), ' ', num2str(flag), '\n'])
  end
end