%% plot_chart
% Plots charts results from user options.  
function plot_chart(result_mmea, chart_type, selected_parameters, save_chart, solution_index)
% created 2021 by Juan Francisco Robles

%% Syntax
% <../plot_results.m *plot_results*>(result, chart_type, selected_parameters, save_chart, solution_index) 

%% Description
% Computes model predictions and handles them (by plotting, saving or publishing)
%
% Input
% 
% * results_mmea: the set of solutions returned by the multimodal
%                  calibration algorithm
% * chart_type: the type of chart to plot
% * selected_parameters: the pair of parameters to plot
% * save_chart: to save the plots which have been generated 
%   solution_index: the solution index (for simple prediction plot)

%% Remarks
% The charts options for chart_type variable are: 
% - (1) Desity heat map - option 'density_hm' - Distribution of best solutions in the
%       2-dimensions search space formed by parameters in selected_parameters.
% - (2) Desity heat map with scatter - option 'density_hm_scatter' - Distribution of 
%       best solutions in the 2-dimensions search space formed by parameters in selected_parameters.
%       together with the values for the parameters combination.
% - (3) Scatter plot - option 'scatter' - Values for parameters in selected_parameters.
% - (4) Weighted scatter plot - option 'weighted_scatter' - (3) with the parameter values 
%       in selected_parameters weighted by fitness value. 
% - (5) Simple prediction plot - option 'prediction'. 

  global pets
  
  % Get the species name
  my_pet = strsplit(result_mmea,'_'); my_pet = [my_pet{2}, '_', my_pet{3}];
  pets = {my_pet}; % required for running nm
  
  % Load the results
  load(result_mmea);
  
  % Get the parameter names
  parnames = result.parameterNames;

  if isempty(selected_parameters)
     fprintf('There are not parameters for plotting soutions.');
     fprintf('Please, enter an array containing two values in %s \n.', num2str(parnames));
     fprintf('Remember that the supported format for the array of values in {value_one; value_tow}.');
     return; 
  elseif isempty(find(strcmp(parnames,selected_parameters(1)), 1))
     fprintf('Parameter %s does not exist in the calibrated parameter set. \n', string(selected_parameters(1)));
     fprintf('The calibrated parameter names are the following: %s \n', string(selected_parameters(1)));
     return;
  elseif isempty(find(strcmp(parnames,selected_parameters(2)), 1))
     fprintf('Parameter %s does not exist in the calibrated parameter set. \n', string(selected_parameters(2)));
     fprintf('The calibrated parameter names are the following: %s \n', string(selected_parameters(2)));
     return;
  else
     % Get the parameter indexes. 
     first_param_index = find(strcmp(result.parameterNames, selected_parameters(1)));
     second_param_index = find(strcmp(result.parameterNames, selected_parameters(2)));
     
     fig_counter = 1; 
     if strcmp(chart_type, 'density_hm') % Plots a density heatmap for two variables. 
        density_heatmap(result.solutionsParameters(:,first_param_index), result.solutionsParameters(:,second_param_index), ..., 
           result.parameterNames(first_param_index), result.parameterNames(second_param_index));
        if save_chart
           savePNG('Density_Heat_Map', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     elseif strcmp(chart_type, 'density_hm_scatter') % Plots a density heatmap for two variables together with 
                                                     % an scatter plot. 
        density_heatmap(result.solutionsParameters(:,first_param_index), result.solutionsParameters(:,second_param_index), ..., 
           result.parameterNames(first_param_index), result.parameterNames(second_param_index), result.lossFunctionValues);
        if save_chart
           savePNG('Density_Heat_Map_Scatter', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     elseif strcmp(chart_type, 'scatter') % Plots an scatter plot for two variables.  
        scatter_plot(result.solutionsParameters(:,first_param_index), result.solutionsParameters(:,second_param_index), ... ,
           result.lossFunctionValues, result.parameterNames(first_param_index), ..., 
           result.parameterNames(second_param_index));
        if save_chart
           savePNG('Scatter', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     elseif strcmp(chart_type, 'weighted_scatter') % Plots an scatter plot for two variables, weighting 
                                                   % each parameter combination with their fitness values.  
        scatter_plot(result.solutionsParameters(:,first_param_index), result.solutionsParameters(:,second_param_index), ... ,
           result.lossFunctionValues, result.parameterNames(first_param_index), ..., 
           result.parameterNames(second_param_index), 1);
        if save_chart
           savePNG('Weighted_Scatter', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     elseif strcmp(chart_type, 'density_scatter') % Plots an scatter plot for two variables, weighting 
                                                   % each parameter combination with their fitness values.  
        scatter_plot(result.solutionsParameters(:,first_param_index), result.solutionsParameters(:,second_param_index), ... ,
           result.lossFunctionValues, result.parameterNames(first_param_index), ..., 
           result.parameterNames(second_param_index), 2);
        if save_chart
           savePNG('Weighted_Scatter', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     else % plot simple solution
        solution_index = join(['solution_', num2str(solution_index)]);
        plot_solution(result.solutionSet.(solution_index).par, result.solutionSet.(solution_index).metaPar, ..., 
           result.solutionSet.data, result.solutionSet.auxData, result.solutionSet.metaData, ..., 
           result.solutionSet.txtData);
        if save_chart
           savePNG(join(['Solution_', num2str(solution_index)]), pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     end
  end
  
end

%% Saves results in PNG
function savePNG(title, pets, fig_counter)
   graphnm = ['results_', pets{1}, '_', title];
   figure(fig_counter)  
   eval(['print -dpng ', graphnm,'.png']);
end

