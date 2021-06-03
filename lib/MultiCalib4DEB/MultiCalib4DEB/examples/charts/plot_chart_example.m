global pets 

% The pet to calibrate
pets = {'Clarias_gariepinus'};
% Check pet consistence
check_my_pet(pets);

% Get pet data
[data, auxData, metaData, txtData, weights] = mydata_pets;

% Load the solution set (example for Clarias Gariepinus). 
load('solutionSet_Clarias_gariepinus_20-Apr-2021_14:28:20.mat');

% Plot the chart!
plot_chart(solutions_set, 'density_hm', {'f_tW';'z'}, false, 20);