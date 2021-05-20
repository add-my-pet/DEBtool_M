function str = cell2str(cell)
  if isempty(cell)
    str = '{}'; return
  elseif ischar(cell)
    str = ['{''', cell, '''}']; return
  end
  n = length(cell);
  if n == 1
    str = ['{''', cell{1}, '''}']; return
  else
    str = '{';
    for i=1:n
      str = [str,'''',cell{i}, ''','];
    end
    str(end) = '}';
  end
end
