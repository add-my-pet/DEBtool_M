function [ distance ] = normalized_euclidean_distance( individual_one, individual_two, ranges )
% NORMALIZED_EUCLIDEAN_DISTANCE Calculates the normalized euclidean distance 
% between two solutions vectors
%
% The method uses the minimum and maximum ranges defined for
% each calibration parameter to normalize the final distance value.
% This consideration allows obtaining accurate distances between
% individuals while restricting the distance to the calibration
% parameters domain.

%% Normalized Euclidean distance calculation

% Individual normalization.
%norm_ind_one = (individual_one-ranges(1,:))./(ranges(2,:)-ranges(1,:));
%norm_ind_two = (individual_two-ranges(1,:))./(ranges(2,:)-ranges(1,:));
% Distance calculation. A factor of 0.5 is applied to transform the
% distance value from its original range value of [0,2] to [0,1].
distance = sum((individual_one(:) - individual_two(:)).^2 ./ (individual_one(:).^2 + individual_two(:).^2));
%distance = 0.5 * norm(norm_ind_one-norm_ind_two);

end

