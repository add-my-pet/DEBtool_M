%% shloglogstar
% plots star with slopes in multiples of 1/3

%%
function shloglogstar(p, r, color)
  % created 2000/10/23 by Bas Kooijman, modified 2009/02/05
  
  %% Syntax
  % <../shloglogstar.m *shloglogstar*> (p, r, color)

  %% Description
  % Plots star with slopes in multiples of 1/3
  %
  % Input:
  %
  % * p: (1,2)-matrix with coordinates of star centre
  % * r: (2,2)-matrix with plot ranges for x,y values
  %
  %    r(1,i)<p(i)<r(2,i) for i = 1,2
  %
  % * color: specification of color
  
  %% Example of use
  % see <shstar.html *shstar*>

  if (p(1) < r(1,1)) || (p(1) > r(2,1)) || (p(2) < r(1,2)) || ...
	 (p(2) > r(2,2)) || (r(1,1) > r(2,1)) || (r(1,2) > r(2,2))
    return;
  end

  hold on;

  p = log10 (p);
  r = log10 (r);

  for i = 1:5
    t = tan([i; -i]/4);
    x_r = [r([2; 2], 1), p(2) + t*(r(2, 1) - p(1))];  % edge right
    x_d = [p(1) + (r(1, 2) - p(2))./t, r([1; 1], 2)]; % edge down
    x_u = [p(1) + (r(2, 2) - p(2))./t, r([2; 2], 2)]; % edge up
    x_l = [r([1; 1], 1), p(2) + t*(r(1, 1) - p(1))];  % edge left
    if x_r(1,2) > r(2,2)            % u, positive angles
      if x_d(1,1) < r(1,1)          % u,l
	    x0 = [x_u(1,:); x_l(1,:)];
      else                          % u,d
	    x0 = [x_u(1,:); x_d(1,:)];
      end  
    else                            % r
      if x_d(1,1) < r(1,1)          % r,l	
        x0 = [x_r(1,:); x_l(1,:)];
      else                          % r,d
	    x0 = [x_r(1,:); x_d(1,:)];
      end
    end
    if x_r(2,2) < r(1,2)            % d, negative angles
      if x_u(2,1) < r(1,1)          % d,l
	    x1 = [x_d(2,:); x_l(2,:)];
      else                          % d,u
	    x1 = [x_d(2,:); x_u(2,:)];
      end
    else                            % r
      if x_u(2,1) < r(1,1)          % r,l	
        x1 = [x_r(2,:); x_l(2,:)];
      else                          % r,u
	    x1 = [x_r(2,:); x_u(2,:)];
      end
    end
    % x0 = 10.^x0; x1 = 10.^x1;
    % loglog(x0(:,1), x0(:,2), color, x1(:,1), x1(:, 2), color); 
    plot(x0(:,1), x0(:,2), color, x1(:,1), x1(:, 2), color);
  end

  % p = 10.^p;
  % r = 10.^r;
  % loglog(p([1; 1]), r(:,2), color, r(:,1), p([2; 2]), color);
  plot(p([1; 1]), r(:,2), color, r(:,1), p([2; 2]), color);