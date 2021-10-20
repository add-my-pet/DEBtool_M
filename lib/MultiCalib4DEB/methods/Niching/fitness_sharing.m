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
function [distance] = euclidean_distance(individual_one, individual_two, ranges)
    % Calculates the normalized euclidean distance between tho solutions
    % vectors. The method uses the minimum and maximum ranges defined for
    % each calibration parameter to normalize the final distance value.
    % This consideration allows obtaining accurate distances between
    % individuals while restricting the distance to the calibration
    % parameters domain.
    distance = sqrt(sum(((individual_one-individual_two)/(ranges(2,:)-ranges(1,:))).^2));
end

function [sharing_fitness] = fitness_sharing_niching(population, fitness, ranges, sigma_share)
    % Applies the fitness sharing mechanism in which: 
    % 1) The population is sorted in ascending order of loss funtion value
    % (for minimization problems).
    % 2) The first solution in the solutions set is considered as the
    % species center. Then, a normalized euclidean distance is calculated
    % by using the center and the i-th individual parameter values. 
    % 3) If the distance between the individuals is lower than the sigma
    % share value, then the individual fitness is punished to favor that 
    % the individual is discarded during the optimization process
    
    % Sort the original population. 
    [~, sort_idxs] = sort(fitness, 'ascend');
    P = population(sort_idxs, :);
    % The sahring fitness values are equal to the original fitness at the
    % first step. 
    sharing_fitness = fitness;
    
    % While population is not empty, select the first individual as the
    % species center, calculate its distance to the rest of individuals. 
    % If the distance value is lower than the sigma share, punish the
    % individual fitness (never the center one). 
    while ~isempty(P)
        if size(P, 1) == 1
            P(1) = [];
        else
            % The center is always the first individual because the 
            % population is sorted and the most similar individual to 
            % every poulation center is removed through the algorithm 
            % execution. 
            center_id = 1;
            ids_to_remove = [center_id];
            for i = 2:(size(P, 1)-1)
                distance = euclidean_distance(P(center_id,:), P(i,:), ranges);
                % Punish the individuals whose distance to the center is
                % lower than the sigma share value. Also note the
                % identifiers of the individuals to remove (because they
                % have been punished yet respecting to their closest
                % center).
                if distance < sigma_share
                    sharing_fitness(sort_idxs(i)) = sharing_fitness(sort_idxs(i)) ./ (1 - (distance / sigma_share));
                    ids_to_remove = [ids_to_remove, i];
                end
            end
            % Remove the individuals from population and from the sorted
            % indexes. 
            P(ids_to_remove,:) = [];
            sort_idxs(ids_to_remove) = [];
        end
    end
end