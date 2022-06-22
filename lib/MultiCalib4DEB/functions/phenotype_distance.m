function [ distance ] = phenotype_distance( individual_one, individual_two )
% PHENOTYPE_DISTANCE Calculates the distance between the phenotypes  
% (fitness values) of two solutions
%
% The method uses the Euclidean distance to calculate the distance between
% the phenotypes of two individuals. 

%% Genotype distance calculation based on Eculidean distance

distance = sum((individual_one(:) - individual_two(:)).^2 ./ (individual_one(:).^2 + individual_two(:).^2));

end

