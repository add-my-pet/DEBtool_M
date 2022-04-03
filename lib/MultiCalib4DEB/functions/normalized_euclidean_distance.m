function [ distance ] = normalized_euclidean_distance( individual_one, individual_two, ranges )
% NORMALIZED_EUCLIDEAN_DISTANCE Calculates the normalized euclidean distance 
% between two solutions vectors

%   The method uses the minimum and maximum ranges defined for
% each calibration parameter to normalize the final distance value.
% This consideration allows obtaining accurate distances between
% individuals while restricting the distance to the calibration
% parameters domain.

norm_ind_one = (individual_one-ranges(1,:))./(ranges(2,:)-ranges(1,:));
norm_ind_two = (individual_two-ranges(1,:))./(ranges(2,:)-ranges(1,:));
distance = sqrt(sum((norm_ind_one-norm_ind_two).^2));
%distance = sqrt(sum((((individual_one-individual_two)-ranges(1,:))/(ranges(2,:)-ranges(1,:))).^2));
%distance = 0.5*(std(individual_one-individual_two)^2) / (std(individual_one)^2+std(individual_two)^2);


end

