function [ avg_norm_dist ] = population_normalized_euclidean_distance( population, ranges )
% Calculates the average normalized euclidean distance between the members 
% of a MMEA population 
%
% The method uses the minimum and maximum ranges defined for each 
% calibration parameter to normalize the parameter values before to
% calculate the Euclidean distance. 
% 
% This steps avoids having different dimensions between the calibration 
% parameters. 
%
% This consideration allows obtaining accurate distances between
% individuals while restricting the distance to the calibration
% parameters domain.

%% Calculation process

avg_norm_dist = 0; 
% Loop over the population 
for i = 1:length(population)-1
    counter = 0; 
    norm_aux = 0; 
    for j = i+1:length(population)
        % Accumulate the distance between solutions
        dist = normalized_euclidean_distance(population(i, :), ..., 
            population(j, :), ranges);
        norm_aux = norm_aux + dist; 
        counter = counter + 1;
    end
    % Accumulate the average distance between individual i and its 
    % neighbors js
    avg_norm_dist = avg_norm_dist + (norm_aux / counter); 
end
% Calculate the average distance
avg_norm_dist = avg_norm_dist / length(population);

end

