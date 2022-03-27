global pets 

% The pet to calibrate
pets = {'Clarias_gariepinus'};
% Check pet consistence
check_my_pet(pets);

% Get pet data
[data, auxData, metaData, txtData, weights] = mydata_pets;

% Load the solution set (example for Clarias Gariepinus).
%load('solutionSet_Clarias_gariepinus_01-Jun-2021_22h19m52s.mat');
% Plot the chart!
plot_chart(result, 'density_hm_scatter', {'p_M';'E_Hp'}, false, 200);