function [ norm_dist ] = population_normalized_euclidean_distance( population, ranges )
% NORMALIZED_EUCLIDEAN_DISTANCE Calculates the normalized euclidean distance 
% for a whole solution's set

% The method uses the minimum and maximum ranges defined for
% each calibration parameter to normalize the parameter values before to
% calculate the Euclidean distance. This steps avoids to have different
% dimensions between the calibration parameters. 
%
% This consideration allows obtaining accurate distances between
% individuals while restricting the distance to the calibration
% parameters domain.

norm_dist = 0; 
% Loop over the population 
for i = 1:length(population)-1
    for j = i+1:length(population)
        % Accumulate the distance between solutions
        norm_dist = norm_dist + normalized_euclidean_distance(population(i, :), population(j, :), ranges);
    end
end
% Calculate the average distance
norm_dist = norm_dist / length(population);

end

