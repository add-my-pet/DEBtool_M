function [ avg_distance ] = population_distance( population )
% Calculates the average distance between the members of a MMEA population

%% Calculation process

avg_distance = 0; 
% Loop over the population 
for i = 1:length(population)-1
    counter = 0; 
    distance_aux = 0; 
    for j = i+1:length(population)
        % Accumulate the distance between solutions
        distance = sum((population(i, :) - population(j, :)).^2 ./ (population(i, :).^2 + population(j, :).^2));
        distance_aux = distance_aux + distance; 
        counter = counter + 1;
    end
    % Accumulate the average distance between individual i and its 
    % neighbors js
    avg_distance = avg_distance + (distance_aux / counter); 
end
% Calculate the average distance for the whole population
avg_distance = avg_distance / length(population);

end