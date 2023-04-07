%% roots2
% gets roots of quadratic polynomial

%%
function x = roots2(a, k)
  % created at 2023/04/04 by Bas Kooijman
  
  %% Syntax
  % x = <../roots2.m *roots2*> (a, k) 

  %% Description
  % Calculates roots of a_2 x^2 + a_1 x + a_0 = 0
  %
  % Input:
  %
  % * a: 3-vector with coefficients [a_2 a_1 a_0]
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
  % * x: 0 till 2 -vector with roots
  
  %% Remarks
  % The comparison tolerance for equality/sign/imaginarity of roots is set by tol in this function
  
  %% Example of use
  % roots2([6 1 3]) or roots2([-.1 1 1],3)

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
    if 2 == length(x)
      if abs(x(1) - x(2)) < tol 
	    x(1) = [];
      end
    end
    if k == 2 % real and different and non-negative
        x = x(x >= 0);
    elseif k == 3 % real and different and positive
        x = x(x > 0);        
    end
  end
