function density_heatmap(param_one, param_two, name_one, name_two, funvals)
%HEATMAP 
%   
% Plots a heatmap with the density of solutions for two parameter vectors
% and an scatter plot with the fitness value for each solution.
%
% 2 options for now: 
% - 1) To plot only a density heatmap with: plot_density_heatmap function.
% - 2) To plot a heatmap with a scatter plot with solution's fitness with:
% plot_density_heatmap_with_scatter.
%
% Inputs
%
%      
%    'param_one': The first parameter to print and to compare in the
%                 heatmaps. It is placed in X axis. 
%
%    'param_two': The second parameter to print. It is placed in the Y
%                 axis.
%
%    'name_one': The name of the first parameter (only used to set the
%                labels and further information);
%
%    'name_two': The name of the second parameter (only used to set the
%                labels and other information).
%
%    'funvals': The fitness of the solutions (for scatter).
%
%
% Considerations: 
%    
%    ** It is mandatory that the sizes for the param_one, param_two, and
%       the funvals set have the same legth.  
%    ** The limits for the X and Y axes are set to the minimum/maximum
%       values of X and Y respectively. 
%    ** If the opt parameter is not defined, the desity heatmap without
%       scatter heatmap plot is automatically performed. 
%

% Check if x name and y names are of 'char' data type and transform them if
% neccesary
if ~isa(name_one, 'char')
   name_one = char(name_one);
end
if ~isa(name_two, 'char')
   name_two = char(name_two);
end

if nargin >= 2 && nargin <= 4
    % Check if the parameter names are introduced 
    if nargin == 2
        name_one = 'First parameter';
        name_two = 'Second parameter';
    elseif nargin == 3
        name_two = 'Second parameter';
    else
        % Nothing to do here
    end
    % Check if the parameter sizes are the same. If not, then finish. 
    if length(param_one) ~= length(param_two)
        disp('The sizes for parameter one and parameter two values need to be the same');
    else
        plot_density_heatmap(param_one, param_two, name_one, name_two);
    end
elseif nargin == 5
    % Check if the parameter sizes are the same. If not, then finish. 
    if length(param_one) ~= length(param_two) && length(param_two) ~= length(funvals)
        disp('The sizes for parameter one, two, and fitness values need to be the same');
    else
        plot_density_heatmap_with_scatter(param_one, param_two, char(name_one), char(name_two), funvals);
    end
else
    disp('There are not enough parameters to plot the heatmap');
end

end

function [ dmap ] = dataDensity( x, y, width, height, limits, fudge )
%DATADENSITY Get a data density image of data 
%   x, y - two vectors of equal length giving scatterplot x, y co-ords
%   width, height - dimensions of the data density plot, in pixels
%   limits - [xmin xmax ymin ymax] - defaults to data max/min
%   fudge - the amount of smear, defaults to size of pixel diagonal
%
% By Malcolm McLean
%
    if(nargin == 4)
        limits(1) = min(x);
        limits(2) = max(x);
        limits(3) = min(y);
        limits(4) = max(y);
    end
    deltax = (limits(2) - limits(1)) / width;
    deltay = (limits(4) - limits(3)) / height;
    if(nargin < 6)
        fudge = sqrt(deltax^2 + deltay^2);
    end
    dmap = zeros(height, width);
    for ii = 0: height - 1
        yi = limits(3) + ii * deltay + deltay/2;
        for jj = 0 : width - 1
            xi = limits(1) + jj * deltax + deltax/2;
            dd = 0;
            for kk = 1: length(x)
                dist2 = (x(kk) - xi)^2 + (y(kk) - yi)^2;
                dd = dd + 1 / ( dist2 + fudge); 
            end
            dmap(ii+1,jj+1) = dd;
        end
    end
            
end

function plot_density_heatmap( x, y, name_x, name_y)
%DATADENSITYPLOT Plot the data density 
%   Makes a contour map of data density
%   x, y - data x and y coordinates
%   levels - number of contours to show
%
% By Malcolm Mclean, updated by Juan Francisco Robles
%
    close all; clc;

    % Generate a set of linear values for the x and y axes
    pts_x = linspace(min(x), max(x), 101);
    pts_y = linspace(min(y), max(y), 101);
    % Generate a grid
    [X, Y] = meshgrid(pts_x, pts_y);
   
    % Only if we want to use distances between solutions for the heatmap 
    %distances = pdist2([x(:) y(:)], [X(:) Y(:)], 'euclidean', 'Smallest', 1);
    
    % Calculate the centers and the density of solutions in the search space.
    [~, centers] = hist3([x(:), y(:)],[256 256]);
    density = dataDensity(x, y, 256, 256);
    
    % Generate the plot figure. 
    figure; 
    % Set the plot position and size
    set(gcf,'Position',[100 100 500 500])
    % Set the title name
    set(gcf,'Name',['Comparison of ' name_x, ' and ' name_y]) %select the name you want
    
    % Working with the axes
    ax1 = axes;
    
    % Plot the heat map
    %imagesc(centers{:}, distances); % For distances
    imagesc(centers{:}, density); % For density
    
    axis xy;
    
    % Title label, font size and weigth.
    title(['Comparison of ' name_x, ' and ' name_y], 'FontSize', 14, 'FontWeight', 'bold');
    
    % choose a colormap of your liking
    colormap(ax1, 'hot'); % For the heat map
    
    % Working with axes, colors, and colorbars titles before to finish
    set(ax1,'Position', [.17 .11 .685 .815]); 
    cb1 = colorbar(ax1,'Position', [.035 .11 .0675 .815]); 

    % Setting title
    set(get(cb1, 'title'), 'string', 'Search Space Density', 'FontSize', 10, 'FontWeight', 'bold');
    
    % Change the colorbar font size and weight
    cb1.FontSize = 10;
    cb1.FontWeight = 'bold';
    
    % Get current title position with respect to the colorbar 
    lbpos = get(cb1,'title');
    set(lbpos,'units','normalized','position',[0.5,1.03]);
    
    % Set the ticks labels font and size
    ax1.XAxis.FontSize = 10; 
    ax1.YAxis.FontSize = 10; 
    ax1.XAxis.FontWeight = 'bold'; 
    ax1.YAxis.FontWeight = 'bold';
    
    % Axis labels, font size and type
    xlabel(['Parameter ' name_x], 'FontSize', 14, 'FontWeight', 'bold');
    ylabel(['Parameter ' name_y], 'FontSize', 14, 'FontWeight', 'bold');
    
    % Set the global limits
    set(gca, 'XLim', [min(pts_x); max(pts_x)], 'YLim', [min(pts_y); max(pts_y)], 'YDir', 'normal');
    
    hold off;
    
end

function plot_density_heatmap_with_scatter( x, y, name_x, name_y, funvals)
% PLOT_DENSITY_HEATMAP_WITH_SCATTER
% Plots a density heat map from x and y points with an scatter plot inside.
% The plot compares two parameters by calculating the desity of solutions
% in the search space (heat map) and showing the fitness solutions
% (scatter). 
%
% By Juan Francisco Robles
%
    close all; clc;

    % Generate a set of linear values for the x and y axes
    pts_x = linspace(min(x), max(x), 101);
    pts_y = linspace(min(y), max(y), 101);
    % Generate a grid
    [X, Y] = meshgrid(pts_x, pts_y);
   
    % Only if we want to use distances between solutions for the heatmap 
    %distances = pdist2([x(:) y(:)], [X(:) Y(:)], 'euclidean', 'Smallest', 1);
    
    % Calculate the centers and the density of solutions in the search space.
    [~, centers] = hist3([x(:), y(:)],[256 256]);
    density = dataDensity(x, y, 256, 256);
    
    % Generate the plot figure. 
    figure; 
    % Set the plot position and size
    set(gcf,'Position',[100 100 500 500])
    % Set the title name
    set(gcf,'Name',['Comparison of ' name_x, ' and ' name_y]) %select the name you want
    
    % Working with the axes
    ax1 = axes;
    
    % Plot the heat map
    %imagesc(centers{:}, distances); % For distances
    imagesc(centers{:}, density); % For density
    
    axis xy;
    
    % Title label, font size and weigth.
    title(['Comparison of ' name_x, ' and ' name_y], 'FontSize', 14, 'FontWeight', 'bold');

    % Set the ticks labels font and size
    ax1.XAxis.FontSize = 10; 
    ax1.YAxis.FontSize = 10; 
    ax1.XAxis.FontWeight = 'bold'; 
    ax1.YAxis.FontWeight = 'bold';
    
    % Axis labels, font size and type
    xlabel(['Parameter ' name_x], 'FontSize', 14, 'FontWeight', 'bold');
    ylabel(['Parameter ' name_y], 'FontSize', 14, 'FontWeight', 'bold');
    
    % Maintain the main plt to add the scatter plot to him
    hold on; 
    
    % Working with the second plot's axes. 
    ax2 = axes;
    
    % Parameters for the scatter plot. 
    sz = 30;
    c = linspace(min(funvals), max(funvals), length(funvals));
    scatter(ax2, x, y, sz, flip(c),  'filled');
    
    % Link axes 
    linkaxes([ax1, ax2]);
    % Hide the top axes 
    ax2.Visible = 'off'; 
    ax2.XTick = []; 
    ax2.YTick = [];

    % choose a colormap of your liking
    colormap(ax1, 'hot'); % For the heat map
    colormap(ax2, flip(winter)); % For the scatter plot. 
    
    % Working with axes, colors, and colorbars titles before to finish
    set([ax1,ax2],'Position', [.17 .11 .685 .815]); 
    cb1 = colorbar(ax1,'Position', [.035 .11 .0675 .815]); 
    cb2 = colorbar(ax2,'Position', [.88 .11 .0675 .815], 'YDir', 'reverse');
    cb2.Title.String = '';
    
    % Setting the colorbar labales and font options
    set(get(cb1, 'title'), 'string', 'Search Space Density', 'FontSize', 10, 'FontWeight', 'bold');
    set(get(cb2, 'title'), 'string', 'Solutions Fitness', 'FontSize', 10, 'FontWeight', 'bold');
    
    % Change the colorbar font size and weight
    cb1.FontSize = 10;
    cb1.FontWeight = 'bold';
    cb2.FontSize = 10;
    cb2.FontWeight = 'bold';
    
    % Get current title position with respect to the colorbar 
    lbpos = get(cb1,'title');
    set(lbpos,'units','normalized','position',[0.5,1.03]);
    lbpos = get(cb2,'title');
    set(lbpos,'units','normalized','position',[0.5,1.03]);
    
    % Set the global limits
    set(gca, 'XLim', [min(pts_x); max(pts_x)], 'YLim', [min(pts_y); max(pts_y)], 'YDir', 'normal');
    
    hold off;
    
end