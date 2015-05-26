%% count_figs
% Counts existing figures in path

%%
function counter = count_figs(name) 

ex = 1;
conter = 0;

while ex
  test = counter + 1;
  if test < 10
    fullnm = [name, '_0', test, '.png'];
  else
    fullnm = [name, '_', test, '.png'];
  end
  
  if exist(fullnm, 'file')
    counter = counter +1;
  else
    ex = 0;
  end
end

