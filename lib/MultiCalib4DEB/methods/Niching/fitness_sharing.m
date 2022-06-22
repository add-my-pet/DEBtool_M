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
% This method promotes diversity among the set of solutions that make up
% the population of the Evolutionary Algorithm. 
   sharing_fitness = fitness_sharing_process(population, fitness, ranges, sigma_share);
end


%% Methods.
function [sharing_fitness] = fitness_sharing_process(population, fitness, ranges, sigma_share)
   % Applie the Fitness Sharing mechanism: this niching mechanism
   % encourages the diversity among a population of individuals by
   % punishing those individuals that are too close together. 
   % A sigma share parameter defines the threshold above which individuals'
   % fitness values are penalized.
   
   shareFunction = zeros(1, length(population));
   sharing_fitness = fitness;
   
   % Loop over the individuals...
   for i = 1:length(population)
      ind_i = population(i,:);
      % and over their neighbors.
      for j = i+1:length(population)
         ind_j = population(j,:);
         % Compute distance
         distance = genotype_distance(ind_i, ind_j);
         % Compute sharing function
         if distance <  sigma_share 
            share = 1 - (distance / sigma_share);
            shareFunction(i) = shareFunction(i) + share;
            shareFunction(j) = shareFunction(j) + share;
         end
      end
      % If the individual has been previously punished for not passing the
      % filters of the species, it is not punished.
      if fitness(i) >= 1e10
      else
         % Punish the individual if needed. 
         if shareFunction(i) > 0
            sharing_fitness(i) = fitness(i) * shareFunction(i);
         end
      end
   end
end