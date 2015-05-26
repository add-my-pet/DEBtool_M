%% shregr2
% Plots model predictions and data

%%
function shregr2 (func, p, x, y, Z)
  %  created: 2002/02/10 by Bas Kooijman; 2005/01/27; 2007/09/14
  
  %% Syntax 
  % <../shregr2.m *shregr2*>(func, p, x, y, Z)
  
  %% Description
  % Plots model predictions and data (optionally). 
  % It allows you to plot a response surface in 3 dimensions, together with your data, or sets of xz-curves or yz-curves. 
  % The data are projected on the surface, and on the curves, to show the difference between the data and model predictions. 
  % These projections help to reveal which data-point relates to which curve.  
  %
  % Input
  %
  % * func: name of user-defined function (see nrregr2)
  % * p: (r,k)-matrix with parameters in p(1,:)
  % * x: (n,1)-vector with first independent variable
  % * y: (m,1)-vector with second independent variable
  % * Z: (n,m)-matrix with observations (optional)
  
  %% Remarks
  % Options can be set by <shregr2_options.html *shregr2_options*>
  % Inputs as in nrregr2; the data matrix is optional. 
  % The ranges of the two independent variables can be set optionally in two 2-vectors with upper and lower values. 

  %% Example of use
  %  assuming that function_name, pars, xvalues, yvalues, and zdata are defined properly: 
  %  shregr2('function_name', pars, xvalues, yvalues, zdata) or shregr2 ('function_name', pars, xvalues, yvalues). 

  %% Code
  global xtext ytext ztext plotnr Range all_in_one;

  % set options if necessary
  if prod(size(plotnr)) == 0     % select plot number
    plotnr = 3; % plotnr 1 and 2
  end
  if prod(size(all_in_one)) == 0 % all graphs in one
    all_in_one = 0;
  end
  if prod(size(Range)) == 0      % set plot ranges
    Range = [0.9*min(x) 1.1*max(x); 0.9*min(y) 1.1*max(y)];
  end
  if prod(size(xtext)) == 0
    xtext = ' ';
  end
  if prod(size(ytext)) == 0
    ytext = ' ';
  end
  if prod(size(ztext)) == 0
    ztext = ' ';
  end

  nx = max(size(x)); ny = max(size(y)); n = nx*ny;
  N = 100; M = 10;
  xaxis = linspace(Range(1,1), Range(1,2), N)';
  yaxis = linspace(Range(2,1), Range(2,2), N)';
  Xaxis = linspace(Range(1,1), Range(1,2), M)';
  Yaxis = linspace(Range(2,1), Range(2,2), M)';
  
  p = p(:,1); 
  eval(['F = ', func,' (p, x, y);']);

  clf;

  if all_in_one == 1
    hold on;
    for i = 1:M
      eval(['f = ', func, '(p, Xaxis(i), yaxis);']);
      xyz = [Xaxis(i*ones(N,1)), yaxis, f'];
      plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'r');
    end
    for j = 1:M
      eval(['f = ', func, '(p, xaxis, Yaxis(j));']);
      xyz = [xaxis, Yaxis(j*ones(N,1)), f];
      plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'r');
    end
    xlabel(xtext); ylabel(ytext); zlabel(ztext);
    view(-37.5, 30);
    grid on
    axis square
    rotate3d on;
  
    if prod(size(Z)) ~= 0
      xyz = zeros(n, 3);
      for i= 1:nx
        xyz((i-1)*ny + (1:ny), :) = [x(i*ones(ny,1)), y, Z(i,:)'];
      end
      plot3(xyz(:,1), xyz(:,2), xyz(:,3),'*b'); % with points;
      z = ones(2,1);
      for i = 1:nx
        for j=1:ny
	      xyz = [x(i*z), y(j*z), [Z(i,j);F(i,j)]];
	      plot3 (xyz(:,1), xyz(:,2), xyz(:,3),'m');
        end
      end
    end
    
  elseif plotnr == 1
    hold on;
    eval(['f = ', func, '(p, xaxis, y);']);
    for i = 1:ny
      plot(xaxis, f(:,i), 'r')
      if prod(size(Z)) ~= 0
        plot(x, Z(:,i), 'b+');
        for j = 1:nx
          plot(x([j j]), [Z(j,i); F(j,i)], 'm');
        end
      end
    end
    xlabel(xtext);
    ylabel(ztext);

  elseif plotnr == 2
    hold on;
    for i = 1:nx
      eval(['f = ', func, '(p, x(i), yaxis);']);
      plot(yaxis, f, 'r');
      if prod(size(Z)) ~= 0
        plot(y, Z(i,:)', 'b+');
        for j = 1:ny
          plot(y([j j]), [Z(i, j); F(i, j)], 'm');
        end
      end
    end
    xlabel(ytext);
    ylabel(ztext);
  
  else
    subplot(1,2,1); hold on;
    for i = 1:ny
      eval(['f = ', func, '(p, xaxis, y(i));']);
      plot(xaxis, f, 'r');
      if prod(size(Z)) ~= 0
        plot(x, Z(:,i), 'b+');
        for j = 1:nx
          plot(x([j j]), [Z(j,i); F(j,i)], 'm');
        end
      end
    end
    xlabel(xtext);
    ylabel(ztext);
  
    subplot(1,2,2); hold on;
    for i = 1:nx
      eval(['f = ', func, '(p, x(i), yaxis);']);
      plot(yaxis, f', 'r');
      if prod(size(Z)) ~= 0
        plot(y, Z(i,:)', 'b+');
        for j = 1:ny
          plot(y([j j]), [Z(i,j); F(i,j)], 'm');
        end
      end
    end
    xlabel(ytext);
    ylabel(ztext);
  
  end
