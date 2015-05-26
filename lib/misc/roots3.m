function x = roots3(a, k)
  %  created at 2002/05/22 by Bas Kooijman, modified 2013/01/20
  %
  %% Decription
  %  calculates roots of a_3 x^3 + a_2 x^2 + a_1 x + a_0 = 0
  %
  %% Input
  %  a: 4-vector with coefficients [a_3 a_2 a_1 a_0]
  %  k: indicator (optional) for
  %         -1 imaginary , 
  %          0 all (default), 
  %          1 real and different
  %          2 real and different and non-negative
  %
  %% Output
  %  x: 0 till 3 -vector with roots
  %
  %% Remarks
  %  rooth gives the hermite interpolation on an interval, given function values and their derivatives at the borders of the interval. 
  %
  %% Example of use
  %  roots3([2 6 1 3]) or roots3([2 6 1 3],1)

  %% Code
  if exist('k','var') == 0
    k = 0; % default all roots selection
  end

  x = roots(a);
  
  if k == -1 % imaginary roots only
    x = x(abs(im(x)) > 1e-6);
  elseif k > 0 % different real roots only
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
    if k == 2 % real and different and non-negative
        x = x(x >= 0);
    end
  end
