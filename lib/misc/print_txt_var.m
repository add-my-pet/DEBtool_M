%% print_txt_var
% prints text, values

%%
function print_txt_var(txt,x)
  % created at 2010/08/05 by Bas Kooijman
  
  %% Syntax 
  % <../printpar.m *print_txt_var*>(txt,x)
  
  %% Description
  % Prints text, values. 
  %
  % Input:
  %
  % * txt: n-cell string with text
  % * var: (n,r)-matrix with values
  
  %% Example of use 
  % print_txt_var([{'txt1'}; {'txt2'}], ones(2,3))
  
  r_txt = size(txt,1); [r_x k] = size(x);
  if r_txt ~= r_x
    fprintf('number of texts not equal to rows of data \n');
    return;
  end
  
  for i = 1:r_txt
    fprintf('%s', [txt{i}, ' ']);
    fprintf('%10.6f', x(i,:));
    fprintf('\n');
  end
