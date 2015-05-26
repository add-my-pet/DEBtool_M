function print_txt_var(txt,x)
  % print text, values
  
  r_txt = size(txt,1); [r_x k] = size(x);
  if r_txt ~= r_x
    fprintf('number of texts not equal to rows of data \n');
    return;
  end
  
  for i = 1:r_txt
    fprintf('%s', txt{i});
    fprintf('%10.6f', x(i,:));
    fprintf('\n');
  end
