%% roots3
% gets roots of cubic polynomial

%%
function x = roots3(a, k)
  % created at 2002/05/22 by Bas Kooijman, modified 2013/01/20
  
  %% Syntax
  % x = <../roots3.m *roots3*> (a, k) 

  %% Description
  % Calculates roots of a_3 x^3 + a_2 x^2 + a_1 x + a_0 = 0
  %
  % Input:
  %
  % * a: 4-vector with coefficients [a_3 a_2 a_1 a_0]
  % * k: indicator (optional) for
  %
  %      -   -1 imaginary  
  %      -    0 all (default) 
  %      -    1 real and different
  %      -    2 real and different and non-negative
  %      -    3 real and different and positive
  %
  % Output:
  %
  % * x: 0 till 3 -vector with roots
  
  %% Remarks
  % The comparison tolerance for equality/sign/imaginarity of roots is set by tol in this function
  
  %% Example of use
  % roots3([2 6 1 3]) or roots3([2 6 1 3],1)

  % Code
  if exist('k','var') == 0
    k = 0; % default all roots selection
  end

  x = roots(a); 
  tol = 1e-12; % comparison tolerance 
  
  if k == -1  % imaginary roots only
    x = x(abs(im(x)) > tol);
  elseif k > 0 % different real roots only
    x = x(abs(im(x)) < tol); x = re(x);
    if 3 == length(x)
      if abs(x(1) - x(2)) < tol || abs(x(1) - x(3)) < tol
	    x(1) = [];
      end
      if abs(x(2) - x(3)) < tol
	    x(2) = [];
      end
    end
    if 2 == length(x)
      if abs(x(1) - x(2)) < tol
	    x = x(1);
      end
    end
    if k == 2 % real and different and non-negative
        x = x(x >= 0);
    elseif k == 3 % real and different and positive
        x = x(x > 0);        
    end
  end
