global pets 

% The pet to calibrate
pets = {'Clarias_gariepinus'};
% Check pet consistence
check_my_pet(pets);

% Get pet data
[data, auxData, metaData, txtData, weights] = mydata_pets;

% Load the solution set (example for Clarias Gariepinus). 
load('solutionSet_Clarias_gariepinus_20-Apr-2021_20:42:00.mat')

% Plot the solutions!
plot_results(solutions_set, ..., 
            solutions_set.results.txtPar, solutions_set.results.data, ...,
            solutions_set.results.auxData, metaData, ..., 
            solutions_set.results.txtData, weights, 'Set');