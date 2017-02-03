function shregr2_options (key, item, val)
  %  created at 2001/09/07 by Bas Kooijman; 2015/01/27
  %  sets options for function 'shregr2' one by one

  global xtext ytext ztext plotnr Range all_in_one;

    options = {'default'; 'plotnr'; 'Range'; 'xlabel'; 'ylabel'; 'zlabel'; ...
	       'all_in_one'; 'unkown'};
    [r, k] = size(options); 

    if ~exist('key', 'var')
      for i = 1:(r-1)
	    txt = options(i,:);
	    if ~exist('txt', 'var')
	      fprintf([options(i,:), ' : unkown \n']);
	    else
          if i == 2
	        n = max(size(plotnr));
	        plnr = ' ';
	        for j = 1:n
	          plnr = [plnr, ' ', num2str(plotnr(j))];
	        end
	        fprintf(['plotnr :', plnr, '\n']);
	      elseif i == 3
	        fprintf('Range : \n');
	        for kr = 1:2
	          for rr= 1:2 
	            fprintf([num2str(Range(kr,rr)), ' ']);
	          end
	          fprintf('\n');
	        end		       
	      else	    
	        fprintf([options(i,:), ' : ',num2str(eval(options(i,:))), '\n']);
	      end	  
	    end
      end
      return;
    end

    switch key

      case 'default'
        clear xtext ytext ztext plotnr all_in_one Range
	
      case 'plotnr'
	    plotnr = item;

      case 'Range'
	    Range(item, :) = val;

      case 'xlabel'
	    xtext = item;

      case 'ylabel'
        ytext = item;

      case 'zlabel'
        ztext = item;

      case 'all_in_one'
	    all_in_one = item;

      otherwise % option 'other'
        fprintf('unkown option \n');
	
    end