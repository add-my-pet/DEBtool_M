function scatter_plot( x, y, fitness, name_x, name_y, opt)
%SCATTER Plots scatter from data.
%
% 2 options for now: 
% - 1) To plot only a simple scatter with fitness points scaled by value. 
% - 2) To plot a scatter where each point is colored by the spatial 
%      density of nearby points.
%
% Inputs
%
%      
%    'x': The first parameter to print and to compare in the
%                 heatmaps. It is placed in X axis. 
%
%    'x': The second parameter to print. It is placed in the Y
%                 axis.
%
%    'name_x': The name of the first parameter (only used to set the
%                labels and further information);
%
%    'name_y': The name of the second parameter (only used to set the
%                labels and other information).
%
%    'fitness': The fitness of the solutions (for scatter).
%
%    'opt': option for the scatter plot. 
%           - 1: Simple scatter with fitness points scaled by value. 
%           - 2: Scatter plot where each point is colored by the spatial 
%                density of nearby points.
%
% Considerations: 
%    
%    ** It is mandatory that the sizes for the x, y, and have the same length. 
%    ** The limits for the X and Y axes are set to the minimum/maximum
%       values of X and Y respectively. 
%    ** If the opt parameter is not defined, the simple scatter plot is
%       show. 
%

% Check if x name and y names are of 'char' data type and transform them if
% neccesary
if ~isa(name_x, 'char')
   name_x = char(name_x);
end
if ~isa(name_y, 'char')
   name_y = char(name_y);
end
if nargin >= 3 && nargin <= 5
    % Check if the parameter sizes are the same. If not, then finish. 
    if length(x) ~= length(y) && length(y) ~= length(fitness)
         disp('The sizes for parameter one, two, and fitness values need to be the same');
    else
        % Check if the parameter names are introduced 
        if nargin == 3
            name_x = 'First parameter';
            name_y = 'Second parameter';
        elseif nargin == 4
            name_y = 'Second parameter';
        else
            % Nothing to do here
        end
        % Plot the scatter
        simple_scatter(x, y, fitness, name_x, name_y, 1);
    end
elseif nargin == 6
    if length(x) ~= length(y) && length(y) ~= length(fitness)
        disp('The sizes for parameter one, two, and fitness values need to be the same');
    else
        if opt == 2
           scatter_kde(x, y, fitness, name_x, name_y, 'filled', 'MarkerSize', 30);
        else
            simple_scatter(x, y, fitness, name_x, name_y, 2);
        end
    end
else
    disp('There are not enough parameters to plot the heatmap');
end

end

function simple_scatter(x, y, fitness, name_x, name_y, opt)
    close all; clc;
    
     % Generate the plot figure. 
    figure; 
    % Set the plot position and size
    set(gcf,'Position',[100 100 500 500])
    % Set the title name
    set(gcf,'Name',['Comparison of ' name_x, ' and ' name_y]) %select the name you want
        
    % Working with the axes
    ax1 = axes;
  
    cmap = parula(256);
    
    aux = zeros(1, length(fitness));
    neg_fitnss = fitness*-1;
    for i = 1:length(fitness)
        aux(i) = (255 - 1) * (neg_fitnss(i) - min(neg_fitnss)) / (max(neg_fitnss) - min(neg_fitnss)) + 1;
    end
    
    %v = rescale(fitness, 1, 256); % Nifty trick!
    numValues = length(aux);
    markerColors = zeros(numValues, 3);
    % Now assign marker colors according to the value of the data.

    for k = 1 : numValues
        row = round(aux(k));
        markerColors(k, :) = cmap(row, :);
    end
    
    % Parameters for the scatter plot.
    if opt==1
      sz = 30;
    else
       sz = zeros(1, length(fitness));
       for i = 1:length(fitness)
           sz(i) = (35 - 15) * (neg_fitnss(i) - min(neg_fitnss)) / (max(neg_fitnss) - min(neg_fitnss)) + 15;
       end
    end
    % Create the scatter plot.
    scatter(x, y, sz, fitness, 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth',1);
    
    colormap(flip(parula(256)));
    cb1 = colorbar('YDir', 'reverse');
    set(get(cb1, 'title'), 'string', 'Solutions fitness value', 'FontSize', 10, 'FontWeight', 'bold');
    
    % Change the colorbar font size and weight
    cb1.FontSize = 10;
    cb1.FontWeight = 'bold';
    
    % Get current title position with respect to the colorbar 
    lbpos = get(cb1,'title');
    set(lbpos,'units','normalized','position',[0.5,1.03]);
    
    ax = gca;
    % Setting backgorund color
    ax.Color = [.7 .7 .7 .1];
    
    % Set the ticks labels font and size
    ax1.XAxis.FontSize = 10; 
    ax1.YAxis.FontSize = 10; 
    ax1.XAxis.FontWeight = 'bold'; 
    ax1.YAxis.FontWeight = 'bold';
    
    % Axis labels, font size and type
    xlabel(['Parameter ' name_x], 'FontSize', 14, 'FontWeight', 'bold');
    ylabel(['Parameter ' name_y], 'FontSize', 14, 'FontWeight', 'bold');
    
    ax1.GridColor = [.0 .0 .0];
    ax1.GridAlpha = 0.3; % Set's transparency of the grid.
    
    grid on;
end

function scatter_kde(x, y, ~, name_x, name_y, varargin)
% Scatter plot where each point is colored by the spatial density of nearby
% points. The function use the kernel smoothing function to compute the
% probability density estimate (PDE) for each point. It uses the PDE has
% color for each point.
%
% Input
%     x <Nx1 double> position of markers on X axis
%     y <Nx1 double> posiiton of markers on Y axis
%     varargin can be used to send a set of instructions to the scatter function
%           Supports the MarkerSize parameter
%           Does not support the MarkerColor parameter
%
% Output:
%     h returns handles to the scatter objects created
%
% Example
%     % Generate data
%     x = normrnd(10,1,1000,1);
%     y = x*3 + normrnd(10,1,1000,1);
%     % Plot data using probability density estimate as function
%     figure(1); 
%     scatter_kde(x, y, 'filled', 'MarkerSize', 100);
%     % Add Color bar
%     cb = colorbar();
%     cb.Label.String = 'Probability density estimate';
%
% author: Nils Haentjens
% created: Jan 15, 2018
% Use Kernel smoothing function to get the probability density estimate
    
    close all; clc; 

    % Generate the plot figure. 
    figure; 
    % Set the plot position and size
    set(gcf,'Position',[100 100 500 500])
    % Set the title name
    set(gcf,'Name',['Comparison of ' char(name_x), ' and ' char(name_y)]) %select the name you want
    
    % Working with the axes
    ax1 = axes;
    
    c = ksdensity([x,y], [x,y]);
    
    if nargin > 2
      % Set Marker Size
      i = find(strcmp(varargin, 'MarkerSize'),1);
      if ~isempty(i) 
          MarkerSize = varargin{i+1}; varargin(i:i+1) = [];
      else
          MarkerSize = []; 
      end
      % Plot scatter plot
      scatter(x, y, MarkerSize, c, varargin{:}, 'MarkerEdgeColor',[0 0 0], 'LineWidth',1);
    else
      scatter(x, y, [], c);
    end
    
    axis xy;
    
    colormap(parula); % For the heat map
    cb = colorbar();
    set(get(cb, 'title'), 'string', 'Solutions fitness value', 'FontSize', 10, 'FontWeight', 'bold');
    
    % Change the colorbar font size and weight
    cb.FontSize = 10;
    cb.FontWeight = 'bold';
    
    % Get current title position with respect to the colorbar 
    lbpos = get(cb,'title');
    set(lbpos,'units','normalized','position',[0.5,1.03]);
    
    ax = gca;
    % Setting backgorund color
    ax.Color = [.8 .8 .8 .1];
    
    % Set the ticks labels font and size
    ax1.XAxis.FontSize = 10; 
    ax1.YAxis.FontSize = 10; 
    ax1.XAxis.FontWeight = 'bold'; 
    ax1.YAxis.FontWeight = 'bold';
    
    % Axis labels, font size and type
    xlabel(['Parameter ' name_x], 'FontSize', 14, 'FontWeight', 'bold');
    ylabel(['Parameter ' name_y], 'FontSize', 14, 'FontWeight', 'bold');
    
    ax1.GridColor = [.0 .0 .0];
    ax1.GridAlpha = 0.3; % Set's transparency of the grid.
    
    grid on;
end