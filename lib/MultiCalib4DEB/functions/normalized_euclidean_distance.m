function [ distance ] = normalized_euclidean_distance( individual_one, individual_two)
% NORMALIZED_EUCLIDEAN_DISTANCE Calculates the normalized euclidean distance 
% between two solutions vectors
%
% The method uses the minimum and maximum ranges defined for
% each calibration parameter to normalize the final distance value.
% This consideration allows obtaining accurate distances between
% individuals while restricting the distance to the calibration
% parameters domain.

%% Euclidean distance calculation

distance = sum((individual_one - individual_two).^2 ./ (individual_one.^2 + individual_two.^2));

end

