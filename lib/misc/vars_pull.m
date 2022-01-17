%% vars_pull
% unpacks variables from a structure

%%
function vars_pull(s)
  % created 2015/08/03, starrlight - it is taken from the matlab website 
  % http://stackoverflow.com/questions/9669635/matlab-is-there-a-way-to-import-promote-variables-from-a-structure-to-the-curre

  %% Syntax 
  % <../vars_pull.m *vars_pull*>
  
  %% Description
  % Allows the user to unpack variables from a stucture. 
  %
  % Input
  %
  % * s: a structure
  %  
  % Output
  %
  % * no output, but the variables appear in the work space of the function
  % or scrip which calls this function, a bit like globals in fact.
  
  for n = fieldnames(s)'    %name = n{1};
    assignin('caller',n{1},s.(n{1}));
  end
    
end    
