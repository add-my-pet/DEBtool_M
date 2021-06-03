%% plot_chart
% Plots charts results from user options.  
function plot_chart( solutions_set, chart_type, selected_parameters, save_chart, solution_index)
% created 2021 by Juan Francisco Robles

%% Syntax
% <../plot_results.m *plot_results*>(solutions_set, chart_type, selected_parameters, save_chart, solution_index) 

%% Description
% Computes model predictions and handles them (by plotting, saving or publishing)
%
% Input
% 
% * solutions_set: the set of solutions returned by the multimodal
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
  
  parnames = solutions_set.parnames;

  if isempty(selected_parameters)
     fprintf('There are not parameters for plotting soutions.');
     fprintf('Please, enter an array containing two values in %s \n.', num2str(parnames));
     fprintf('Remember that the supported format for the array of values in {value_one; value_tow}.');
     return; 
  elseif isempty(find(strcmp(parnames,selected_parameters(1)), 1))
     fprintf('Parameter %s does not exist in the calibrated parameter set. \n', selected_parameters(1));
     fprintf('The calibrated parameter names are the following: %s \n', num2str(selected_parameters(1)));
     return;
  elseif isempty(find(strcmp(parnames,selected_parameters(2)), 1))
     fprintf('Parameter %s does not exist in the calibrated parameter set. \n', selected_parameters(2));
     fprintf('The calibrated parameter names are the following: %s \n', num2str(selected_parameters(2)));
     return;
  else
     % Get the parameter indexes. 
     first_param_index = find(strcmp(solutions_set.parnames, selected_parameters(1)));
     second_param_index = find(strcmp(solutions_set.parnames, selected_parameters(2)));
     
     fig_counter = 1; 
     if strcmp(chart_type, 'density_hm') % Plots a density heatmap for two variables. 
        density_heatmap(solutions_set.pop(:,first_param_index), solutions_set.pop(:,second_param_index), ..., 
           solutions_set.parnames(first_param_index), solutions_set.parnames(second_param_index));
        if save_chart
           savePNG('Density_Heat_Map', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     elseif strcmp(chart_type, 'density_hm_scatter') % Plots a density heatmap for two variables together with 
                                                     % an scatter plot. 
        density_heatmap(solutions_set.pop(:,first_param_index), solutions_set.pop(:,second_param_index), ..., 
           solutions_set.parnames(first_param_index), solutions_set.parnames(second_param_index), solutions_set.funvalues);
        if save_chart
           savePNG('Density_Heat_Map_Scatter', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     elseif strcmp(chart_type, 'scatter') % Plots an scatter plot for two variables.  
        scatter_plot(solutions_set.pop(:,first_param_index), solutions_set.pop(:,second_param_index), ... ,
           solutions_set.funvalues, solutions_set.parnames(first_param_index), ..., 
           solutions_set.parnames(second_param_index));
        if save_chart
           savePNG('Scatter', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     elseif strcmp(chart_type, 'weighted_scatter') % Plots an scatter plot for two variables, weighting 
                                                   % each parameter combination with their fitness values.  
        scatter_plot(solutions_set.pop(:,first_param_index), solutions_set.pop(:,second_param_index), ... ,
           solutions_set.funvalues, solutions_set.parnames(first_param_index), ..., 
           solutions_set.parnames(second_param_index), 1);
        if save_chart
           savePNG('Weighted_Scatter', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     elseif strcmp(chart_type, 'density_scatter') % Plots an scatter plot for two variables, weighting 
                                                   % each parameter combination with their fitness values.  
        scatter_plot(solutions_set.pop(:,first_param_index), solutions_set.pop(:,second_param_index), ... ,
           solutions_set.funvalues, solutions_set.parnames(first_param_index), ..., 
           solutions_set.parnames(second_param_index), 2);
        if save_chart
           savePNG('Weighted_Scatter', pets, fig_counter);
           fig_counter = fig_counter + 1;
        end
     else % plot simple solution
        solution_index = join(['solution_', num2str(solution_index)]);
        plot_solution(solutions_set.results.(solution_index).par, solutions_set.results.(solution_index).metaPar, ..., 
           solutions_set.results.data, solutions_set.results.auxData, solutions_set.results.metaData, ..., 
           solutions_set.results.txtData);
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

