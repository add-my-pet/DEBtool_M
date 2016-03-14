%% spline
% gives values and 1st, 2nd, 3rth derivatives of a cubic spline

%%
function [y, dy, ddy, dddy] = spline(x, knots, Dy1, Dyk)
  % created at 2002/05/22 by Bas Kooijman, modified 2009/09/29
  
  %% Syntax
  % [y, dy, ddy, dddy] <../spline.m *spline*>(x, knots, Dy1, Dyk)

  %% Description
  % Calculates (natural or clamped) the ordinates of a cubic spline, first three derivatives;
  %   clamping can be none, left, right, left & right;
  %   outside the knot-abscissa-range the spline is linear, also if clamped;
  %   spline(x, xy, [], []) is identical to spline(x, xy)
  % Cubic splines are piece-wise cubic polynomials between knots, and linear outside the knots, 
  %    such that the spline is differentiable everywhere. 
  % Natural cubic splines have a second derivative equal to zero at the first and last knot; 
  %    the first derivative is differentable everywhere, the second derivative is continuous, 
  %    and the third derivative is piecewise constant and not continuous. 
  % Left and/or right clamped cubic splines have a prescribed first derivative at the first and/or last knot; 
  %    the second derivative at these knots is (generally) not equal to zero, while it is outside the knot-range.
  % The spline is interpolating, see knot for obtaining knot coordinates of a smoothing spline. 
  % The natural cubic spline is selected by default, but it can optionally be clamped left and/or right. 
  %
  % Input:
  %
  % * x: n-vector with ordinates
  % * knots: (nk,2)-matrix with coordinates of knots; we must have nk > 3;
  %         knots(:,1) must be ascending
  % * Dy1: scalar with first derivative at first knot (optional);
  %       empty means: no specification and second derivative equals 0
  % * Dyk: scalar with first derivative at last knot (optional);
  %       empty means: no specification and second derivative equals 0
  %
  % Output
  %
  % * y: n-vector with spline values
  % * dy: n-vector with first derivatives of spline
  % * ddy: n-vector with second derivatives of spline
  % * dddy; n-vector with third derivatives of spline
  
  %% Remarks
  % cf <../html/islpine.html *spline1*> for integration;
  %    <../html/rspline.html *rspline*> for roots;
  %    <../html/espline.html *espline*> for local extremes.

  %% Example of use 
  % x = (1:10)'; y = 3*(x+.1*rand(10,1)).^2;: k = knot(0.5+[0 2 5 7]',[x,y]); 
  % [Y, dY, ddY, dddY] = spline(x,k); iY = ispline(x,k); rspline(k,5)

  %% Example of use of clamps
  % Y = spline(x,k,0) (left clamp); Y = spline(x,k,[],0) (right clamp); 
  % Y = spline(x,k,0,0) (left and right clamp)
  % See <../mydata_spline.m *mydata_spline*> and <../mydata_smooth.m *mydata_smooth*> for further illustrations. 

  x = x(:); nx = length(x); nk = size(knots,1);
  if nk < 4
    fprintf('number of knots must be at least 4\n');
    y = []; dy = []; ddy = []; dddy = []; return
  end
  
  if exist('Dy1','var') == 0 % make sure that left clamp is specified
    Dy1 = []; % no left clamp; second derivative at first knot is zero
  end
  if exist('Dyk','var') == 0 % make sure that right clamp is specified
    Dyk = []; % no right clamp; second derivative at last knot is zero
  end
  
  % between which knots are the required x-values?
  ix = sum((x(:,ones(1,nk)) >= knots(:,ones(1,nx))')')'; % indices

  Dk = knots(2:nk,:) - knots(1:nk-1,:); D = Dk(:,2) ./ Dk(:,1);

  % compute first three derivatives at knots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % first two for each clamping case, then third derivative %%%%%%%%%%%%%%%
  
  if isempty(Dy1) && isempty(Dyk) % natural cubic spline
    % second derivatives at knots
    C = zeros(nk-2,nk-4);
    C = [2 * (Dk(1:nk-2,1) + Dk(2:nk-1,1)), Dk(2:nk-1,1), C, Dk(1:nk-2,1)];
    C = wrap(C',nk-2,nk-2);
    E = 6 * (D(2:nk-1) - D(1:nk-2));
    DDy = [0; C\E; 0];

    % first derivatives at knots
    Dy = D - (2 * DDy(1:nk-1) + DDy(2:nk))/ 6;
    Dy = [Dy; D(nk-1) + DDy(nk-1) * Dk(nk-1,1)/ 6];
    DDk = [Dy(2:nk-1) - Dy(1:nk-2); 0; 0];

  elseif isempty(Dy1) == 0 && isempty(Dyk) % left clamp
    % second derivatives at knots
    C = zeros(nk-2,nk-3);
    C = [Dk(1:nk-2,1), 2 * (Dk(1:nk-2,1) + Dk(2:nk-1,1)), Dk(2:nk-1,1), C];
    C = wrap(C',nk-2,nk-1);
    C = [[[2 1] .* Dk(1,1),zeros(1,nk-3)]; C];
    E = 6 * (D(2:nk-1) - D(1:nk-2)); E = [6 * (D(1) - Dy1); E];
    DDy = [C\E; 0];

    % first derivatives at knots
    Dy = D - (2 * DDy(1:nk-1) + DDy(2:nk))/ 6;
    Dy = [Dy; D(nk-1) + DDy(nk-1) * Dk(nk-1,1)/ 6];
    DDk = [Dy(2:nk-1) - Dy(1:nk-2); 0; 0];

  elseif isempty(Dy1) && isempty(Dyk) == 0 % right clamp
    % second derivatives at knots
    C = zeros(nk-2,nk-3);
    C = [2 * (Dk(1:nk-2,1) + Dk(2:nk-1,1)), Dk(2:nk-1,1), C, Dk(1:nk-2,1)];
    C = wrap(C',nk-2,nk-1);
    C = [C; [zeros(1,nk-3), [1 2] * Dk(nk-1,1)]];
    E = 6 * (D(2:nk-1) - D(1:nk-2)); E = [E; 6 * (Dyk - D(nk-1))];
    DDy = [0; C\E];

    % first derivatives at knots
    Dy = D - (2 * DDy(1:nk-1) + DDy(2:nk))/ 6;
    Dy = [Dy; Dyk];
    DDk = [Dy(2:nk-1) - Dy(1:nk-2); 0; 0];

  else % left & right clamp
    % second derivatives at knots
    C = zeros(nk-2,nk-2);
    C = [Dk(1:nk-2,1), 2 * (Dk(1:nk-2,1) + Dk(2:nk-1,1)), Dk(2:nk-1,1), C];
    C = wrap(C',nk-2,nk);
    C = [[[2 1] .* Dk(1,1),zeros(1,nk-2)]; C; ...
	 [zeros(1,nk-2), [1 2] * Dk(nk-1,1)]];
    E = 6 * (D(2:nk-1) - D(1:nk-2));
    E = [6 * (D(1) - Dy1); E; 6 * (Dyk - D(nk-1))];
    DDy = C\E;
   
    % first derivatives at knots
    Dy = D - (2 * DDy(1:nk-1) + DDy(2:nk))/ 6;
    Dy = [Dy; Dyk];
    DDk = [Dy(2:nk-1) - Dy(1:nk-2); 0; 0];

  end

  DDDk = [DDy(2:nk) - DDy(1:nk-1); 0];

  % third derivatives at knots plus leading zero
  DDDy = [0;DDDk(1:nk-1) ./ Dk(:,1);0]; 

  % compute y dy ddy dddy at required x-values %%%%%%%%%%%%%%%%%%%%%%%%%%%

  dddy = DDDy(1 + ix); %% third derivatives at x-values
  ddy = x; dy = x; y = x; % initiate output

  for i = 1:nx % loop across required x-values
    if ix(i) == 0 % first linear segment
      ddy(i) = 0;
      if isempty(Dy1)
	    dy(i) = D(1) - Dk(1,1) * DDy(2)/ 6;
      else
	    dy(i) = Dy1;
      end
      y(i) = knots(1,2) - (knots(1,1) - x(i)) * Dy(1);
    elseif ix(i) == nk % last linear segment
      ddy(i) = 0;
      if isempty(Dyk)
	    dy(i) = D(nk-1) + Dk(nk-1,1) * DDy(nk - 1)/ 6;
      else
	    dy(i) = Dyk;
      end
      y(i) = knots(nk,2) + (x(i) - knots(nk,1)) * Dy(nk);
    else % middle cubic polynomial segments
      ddy(i) = DDy(ix(i)) + (x(i) - knots(ix(i),1)) * DDDk(ix(i))/ Dk(ix(i),1);
      Y = (DDy(ix(i)) + ddy(i) + DDy(1 + ix(i)))/ 6;
      dy(i) = D(ix(i)) + (2 * x(i) - knots(ix(i),1) - knots(1 + ix(i),1)) * Y;
      y(i) = knots(ix(i),2) + (x(i) - knots(ix(i),1)) * ...
	  (D(ix(i)) - (knots(1+ix(i),1) - x(i)) * Y);
    end
  end
