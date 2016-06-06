%% cont1
% intervals of independent variable, for which dependent variable is smaller than a specified value

%%
function x = cont1 (xy, y)
  %  created at 2001/09/16 by Bas Kooijman; modified 2007/08/08 
  
  %% Syntax
  % x = <../cont1.m *cont1*>(xy, y)
  
  %% Description
  % Finds intervals of independent variable, for which dependent variable
  % is smaller than a specified value by linear interpolation in a xy-table
  %
  % Input:
  %
  % * xy: (nx,2)-matrix with xy-coordinates, ordered in x
  % * y: scalar with y-value
  %
  % Ouput:
  %
  % * x: (r,2)-matrix with x-values that correspond to value y
  %      using linear interpolation in the xy-table
  
  %% Remarks
  % x(:,1) have negative derivatives; x(:,2) positive ones;
  % so each row of x represents the boundaries of the interval
  % for wich the variable y is lower than the value y

  %% Example of use
  % cont1([[1 2 3 4]',[5 3 1 6]'],2)

  nx = size(xy, 1);
  
  if nx <= 2
    fprintf('nothing to interpolate/n');
    return
  end
  
  col = 0; % initiate column indicator (at invalid value)
  x = [NaN, NaN]; % initiate root matrix
  r = 1; % interval number indicator 
  
  for i = 1:nx % loop across all table points  
    if (y < xy(i,2))
      if (col == 2) % low-to-high crossing detected
	x(r,2) = xy(i-1,1) + ...
	    (xy(i,1) - xy(i-1,1))* (y - xy(i-1,2))/ (xy(i,2) - xy(i-1,2));
	x = [x; [NaN, NaN]];
	r = r+1;
      end
      col = 1;
    elseif (y > xy(i,2))
      if (col == 1) % high-to-low crossing detected
	x(r,1) = xy(i-1,1) + ...
	    (xy(i,1) - xy(i-1,1))* (y - xy(i-1,2))/ (xy(i,2) - xy(i-1,2));
      end
      col = 2;
    else % y == xy(i,2)
      if i == 1
	if (y > xy(2,2))
	  x = [NaN, xy(1,1)];
	elseif (y < xy(2,2))
	  x = [xy(1,1), NaN];
	else % y == xy(2,2)
	  if nx > 2
	    i = 2;
	    if (y > xy(3,2))
	      x = [xy(1,1), xy(2,1)];
	      col = 1;
	    elseif (y < xy(3,2))
	      x = [NaN, xy(1,1); xy(2,1), NaN];
	      col = 2;
	    end
	  else
	    x = [xy(1,1), xy(2,1)];
	    return
	  end
	end
      else
	if  col == 1
	  x(r,1) = xy(i,1);
	  col = 2;
	else
	  x(r,2) = xy(i,1);
	  x = [x; [NaN, NaN]];
	  r = r+1;
	  col = 1;
	end
      end
    end      
  end

  if 0 == sum((x(r,:) > -1e20)) & (r>1)
    x = x(1:r-1,:);
  end
