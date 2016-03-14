%% ispline1
% integral over a cubic spline

%%
function Y = ispline(x, knots, Dy1, Dyk)
  %  created at 2002/05/24 by Bas Kooijman; modified 2006/08/11

  %% Syntax
  % y = <../ispline.m *ispline*> (x, knots, Dy1, Dyk)
  
  %% Description
  % Calculates integral over a cubic spline;
  %  works similar to <../html/spline.html *spline*> but gives a single n-vector with integrated values of the cubic spline. 
  % The first element is zero by definition. 
  %
  % Input:
  %
  % * x: n-vector with ordinates; must be ascending; n>1
  % * knots: (r,2)-matrix with coordinates of knots;
  %         knots(:,1) must be ascending
  % * Dy1: optional scalar with first derivative at first knot;
  %       empty means: no specification and second derivative equals 0
  % * Dyk: optional scalar with first derivative at last knot;
  %       empty means: no specification and second derivative equals 0
  %
  % Output:
  %
  % * Y: n-vector with integrated spline values;
  %   Y(1) = 0 by definition
  
  %% Example of use
  % see <../mydata_smooth.m *mydata_smooth*>

  x = x(:); nx = length(x); nk = size(knots,1);

  if nk < 4
    printf('number of knots must be at least 4\n');
    Y = []; return
  end
  
  if exist('Dy1') == 0 % make sure that left clamp is specified
    Dy1 = []; % no left clamp; second derivative at first knot is zero
  end
  if exist('Dyk') == 0 % make sure that right clamp is specified
    Dyk = []; % no right clamp; second derivative at last knot is zero
  end

  xk = knots(:,1); yk = knots(:,2); % abbraviate names
  x = [x;0]; % append extra element
  xpk = xk(1:nk-1) .* xk(2:nk); xsk = xk(1:nk-1) + xk(2:nk); 
  Dk = knots(2:nk,:) - knots(1:nk-1,:); D = Dk(:,2) ./ Dk(:,1);

  % %% compute first three derivatives at knots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % %% first two for each clamping case, then third derivative %%%%%%%%%%%%%%%
  
  if isempty(Dy1) & isempty(Dyk) % natural cubic spline
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

  elseif ~isempty(Dy1) & isempty(Dyk) % left clamp
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

  elseif isempty(Dy1) & ~isemty(Dyk) % right clamp
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

  % %% third derivatives at knots
  DDD = [DDDk(1:nk-1) ./ Dk(:,1);0];

  % %% start integration procedure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  Y = zeros(nx,1); % initiate output
  b = x(1); % set upper integration boundary (initiation)
  ba1 = 1; % set integration interval (initiation)
  i = 2;  j = sum(b > xk); % initiate ordinate and knot counters
  
  while i <= nx | b < x(nx) % loop across required x-values
    a = b; % set lower integration boundary to previous upper one
    if j < nk
      b = min(x(i),xk(j + 1)); % set upper integration boundary
    else
      b = x(i);
    end
    
    ba1 = b - a; ba2 = (b^2 - a^2)/ 2;
    ba3 = (b^3 - a^3)/ 3; ba4 = (b^4 - a^4)/ 4;

    if j == 0 % first linear segment
      Y(i) = Y(i) + ba1 * (yk(1) - xk(1) * Dy(1)) + ba2 * Dy(1);
    elseif j == nk % last linear segment
      Y(i) = Y(i) + ba1 * (yk(nk) - xk(nk) * Dy(nk)) + ba2 * Dy(nk);    
    else % middle cubic polynomial segments
      Y(i) = Y(i) + ba1 * (yk(j) + (a/ 2 + b/ 2 - xk(j)) * D(j)) + ...
	  (xpk(j) * ba1 - xsk(j) * ba2 + ba3) * ...
	  (2 * DDy(j) + DDy(j + 1) - xk(j) * DDD(j))/ 6 + ...
	  (xpk(j) * ba2 - xsk(j) * ba3 + ba4) * DDD(j)/ 6;
    end

    if b == xk(min(nk,j+1)) & j < nk & i < nx
      j = j + 1; % set knot counter
      i = i + 1; % set ordinate counter
    elseif b == x(i) | j == nk
      i = i + 1; % set ordinate counter
    else
      j = j + 1; % set knot counter
    end

  end
  Y = cumsum(Y); % cumulate surfaces between abcissa