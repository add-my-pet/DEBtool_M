%% wrap
% Unravel a matrix and wrap it into a (nr,nc)-matrix

%%
function b = wrap(a, nr, nc)
  %  Created by Bas Kooijman at 2000/08/28, modified 2009/10/22
  
  %% Syntax
  % b = <../wrap.m *wrap*> (a, nr, nc)

  %% Description
  % Unravel a matrix and wrap it into a (nr,nc)-matrix, repeating elements
  %  or not-using elements depending on the number of elements required relative to the number of elements offered; 
  %  in routine reshapes the number of elements must match. 
  %
  % Input:
  %
  % * a: data-matrix
  % * nr: number of rows
  % * nc: number of colums
  %
  % Output
  %
  % * b: (nr,nc)-matrix
    
  %% Example of use
  % wrap(1:3,4,5) or wrap(1:10,2,2)
  
  b = zeros(nr, nc);
  a = a(:);                % unravel a
  m = size (a,1);  
    for i = 1:nr
      for j = 1:nc
	    k = j + (i - 1) * nc; k = k - m * floor((k - 1)/ m);
	    b(i,j) = a(k);	
      end
    end