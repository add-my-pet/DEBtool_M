function shsurv_options (key, nr, val)
  %  created at 2002/02/08 by Bas Kooijman; 2005/01/27
  %  sets options for function 'shsurv' one by one
  %  run 'shsurv' first to initiate option settings

  global dataset Range all_in_one;

    if ~exist('key', 'var') 
      key = 'unkown';
    end
    
    switch key

      case 'default'
      Range = []; dataset = []; all_in_one = [];
	  j = 1;
	  while exist(['xlabel', num2str(j)], 'var') || exist(['ylabel', num2str(j)], 'var')
	        eval(['clear xlabel', num2str(j)]);
	        eval(['clear ylabel', num2str(j)]);
	        j = j + 1;
      end
     
      case 'dataset'
	  dataset = nr;

      case 'Range'
	  Range(nr, :) = val;

      case 'xlabel'
      eval(['global xlabel', num2str(nr), ';']);
	  eval(['xlabel', num2str(nr), ' = val;']);

      case 'ylabel'
      eval(['global ylabel', num2str(nr),';']);
	  eval(['ylabel', num2str(nr), ' = val;']);

      case 'all_in_one'
	  all_in_one = nr;

      otherwise % option 'other'
      fprintf('unkown option \n');
	
    end