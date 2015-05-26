function x = roots3_old(a, k)
  %  created at 2002/05/22 by Bas Kooijman, modified 2009/09/29
  %
  %% Description
  %  calculates roots of a_3 x^3 + a_2 x^2 + a_1 x + a_0 = 0
  %
  %% Input
  %  a: 4-vector with coefficients [a_3 a_2 a_1 a_0]
  %  k: indicator (optional) for
  %     imaginary (-1), all (0, default), real and different(1)
  % 
  %% Output
  %  x: 0 till 3 -vector with roots
  
  %% Code
  if exist('k','var') == 0
    k = 0; % default all roots selection
  end

  if a(1) ~= 0 % true cubic polynomial
    a = a/ a(1); % normalize to a_3 = 1
    q = a(3)/ 3 - (a(2)/ 3)^2;
    r = (a(3) * a(2) - 3 * a(4))/ 6 - (a(2)/ 3)^3;
    D = q^3 + r^2; sqrtD = sqrt(D);
    s1 = (r + sqrtD)^(1/3); s2 = (r - sqrtD)^(1/3);
    x1 = (s1 + s2) - a(2)/ 3; i = sqrt(-1);
    X = -(s1 + s2)/ 2 - a(2)/ 3; iX = sqrt(3) * (s1 - s2)/ 2;
    x2 = X + i * iX; x3 = X - i * iX; x = [x1; x2; x3];
    % [x1+x2+x3+a(2);  x1*x2+x1*x3+x2*x3 - a(3);  a(4)+x1*x2*x3]
    %% must be zeros

    if k == -1 % imaginary roots only
      x = x(abs(im(x)) > 1e-6);
    elseif k == 1 % different real roots only
      x = x(abs(im(x)) < 1e-6); x = re(x);
      if 3 == length(x)
	if abs(x(1) - x(2)) < 1e-6 || abs(x(1) - x(3)) < 1e-6
	  x(1) = [];
	end
	if abs(x(2) - x(3)) < 1e-6
	  x(2) = [];
	end
      end
      if 2 == length(x)
	if abs(x(1) - x(2)) < 1e-6
	  x = x(1);
	end
      end
    end
  elseif a(2) ~= 0 % a_3 = 0  with a = [a_3 a_2 a_1 a_0]
    a = a/ a(2); % normalize to a_2 = 1
    D = a(3)^2 - 4 * a(4); sqrtD = sqrt(D);
    x1 = - (a(3) + sqrtD)/ 2;
    x2 = - (a(3) - sqrtD)/ 2;
    if k == -1 % imaginary roots only
      if D < 0
        x = [x1; x2];
      else
        x = [];
      end
    elseif k == 1 % different real roots only
      if D > 0 % unequal roots
        x = [x1; x2];
      elseif D == 0 % equal roots
	  x = x1;
      end      
    else % all roots
        x = [x1; x2];
    end
    %% [x1+x2+a(3)/a(2), x1*x2-a(4)/a(2)] % must be zero
  elseif a(3) ~= 0 % a_3, a_2 = 0  with a = [a_3 a_2 a_1 a_0]
    x = - a(4)/ a(3);
  else
    x = [];
  end
  
