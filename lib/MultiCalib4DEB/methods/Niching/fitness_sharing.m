function [ sharing_fitness ] = fitness_sharing( population, fitness, ranges, sigma_share )
% created 2021/04/07 by Juan Francisco Robles
% edited 2021/07/13, 2021/07/15, 2021/07/22, 2021/06/02
% by Juan Francisco Robles
%% Syntax 
% [ sharing_fitness ] = <../fitness_sharing.m *fitness_sharing*>
% (population, fitness, ranges, sigma_share

%% Description
% Applies a penalization based on the fitness sharing niching mechanisms to
% a set of solutions. 
%
% * From a desired sigma share value, calculates the solutions whose
% distance is under the above-mentioned variable value, punishing the
% solution fitness value according to the sigma share value. 
%
% Input
%
% * population: a set of parameter combinations (each one defining an
% individual (solution). 
% * fitness: the real fitness of the above-mentioned solutions. 
% * ranges: the minimum and maximum ranges for each solution's parameters.
% * sigma_share: the sigma share value. 
%  
% Output
%
% * sharing_fitness: the fitness of the solutions population received as
% input modifyed according to the fitness sharing niching mechanism. 

%% Remarks
% This method promotes the diversity between the solutions set that forms 
% the evolutionary algorithm's population. 
    sharing_fitness = fitness_sharing_niching(population, fitness, ranges, sigma_share);
end

%% Methods.

function [sharing_fitness] = fitness_sharing_niching(population, fitness, ranges, sigma_share)
	shareFunction = ones(1, length(population));
   sharing_fitness = fitness;
   % Loop over the population
	for i = 1:length(population)
      ind_i = population(i,:);
      for j = i+1:length(population)
         ind_j = population(j,:);
         % Compute distance
         distance = normalized_euclidean_distance(ind_i, ind_j, ranges);
         % Compute sharing function
         if distance <  sigma_share 
            share = 1 - (distance / sigma_share);
            shareFunction(i) = shareFunction(i) + share;
            shareFunction(j) = shareFunction(j) + share;
         end
      end
      % Apply the sharing punishment
      sharing_fitness(i) = fitness(i) * shareFunction(i);
	end
end