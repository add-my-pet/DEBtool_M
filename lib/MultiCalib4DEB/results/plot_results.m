%% plot_results
% Computes model predictions and plots results from calibration data 

%%
function plot_results(result_mmea, mode)
% created 2021 by Juan Francisco Robles
% Edited 2021/06/02 (fix by Bas Kooijman) by Juan Francisco Robles
%% Syntax
% <../plot_results.m *plot_results*>(result, txtPar, data, auxData, metaData, txtData, weights) 

%% Description
% Computes model predictions and handles them (by plotting, saving or publishing)
%
% Input
% 
% * result: the set of solutions returned by the multimodal
%                  calibration algorithm
% * txtPar: structure with information on parameters
% * data: structure with data for species
% * auxData: structure with auxilliairy data that is required to compute predictions of data (e.g. temperature, food.). 
%   auxData is unpacked in predict and the user needs to construct predictions accordingly.
% * metaData: structure with information on the entry
% * txtData: structure with information on the data
% * weights: structure with weights for each data set
% * chart mode: the option which defines the chart to plot

%% Remarks
% Depending on <calibration_options.html *calibration_options*> settings:
% writes to results_my_pet.html, plots to screen, writes to report_my_pet.html and shows in browser
% Plots the values for the best estimation predictions to screen (A) - option 'Basic' -, 
% the results for the best estimation (B) - option 'Basic' -, 
% a plot which joins all the solutions set in a single plot where the best estimation is 
% compared with the rest of solutions (C) - option 'Set' -, or performs 
% both operations (D) - option 'Complete' -. 
% If the save_results from <calibration_options.html*calibration_options*> settings
% is activated, then the plots from (B), (C), or/and (D) are saved. 
%% Example of use
%  plot_results('result_Clarias_Gariepinus_mmea', 'Set')

  global pets save_results % Global variables
  
  % Get the species name
  my_pet = strsplit(result_mmea,'_'); my_pet = [my_pet{2}, '_', my_pet{3}];
  pets = {my_pet}; % required for running nm
  
  % Load the results
  load(result_mmea);
  
  % Get the pet's data (some from results) 
  txtPar = result.final.solutionSet.txtPar; 
  data = result.final.solutionSet.data; 
  metaData = result.final.solutionSet.metaData;
  auxData = result.final.solutionSet.auxData;
  txtData = result.final.solutionSet.txtData;
  weights = result.final.solutionSet.weights; 
  
  fig_counter = 1; 
  if strcmp(mode, 'Basic') % Plots only prediction results to screen. 
     plotResulValues(result.final, txtPar, data, auxData, metaData, txtData, weights, pets);
  elseif strcmp(mode, 'Best') % Plots best prediction result to screen. 
     plotResultImage(result.final, data, auxData, metaData, txtData, weights, pets, save_results, fig_counter);
  elseif strcmp(mode, 'Set') % Plots set predictions to screen. 
     plotResultsSet(result.final, data, auxData, metaData, txtData, weights, pets, save_results, fig_counter);
  else % Plots prediction values, best prediction plot, and predictions set to screen. 
     plotResulValues(result.final, txtPar, data, auxData, metaData, txtData, weights, pets);
     plotResultImage(result.final, data, auxData, metaData, txtData, weights, pets, save_results, fig_counter);
     fig_counter = fig_counter + 1;
     plotResultsSet(result.final, data, auxData, metaData, txtData, weights, pets, save_results, fig_counter);
  end
   
end

%% Saves results in PNG
function savePNG(title, pets, fig_counter)
   graphnm = ['results_', pets{1}, '_', title];
   figure(fig_counter)  
   eval(['print -dpng ', graphnm,'.png']);
end

%% Saves results report in HTML
function saveResultsHTML(par, metaPar, txtPar, metaData)
  prt_report_my_pet({par, metaPar, txtPar, metaData},[])  % edit by Bas Kooijman, 
end

%% Calculates the predictions from solution's data
function [prdData, metaPar, data2plot, univarX, parPets] =  calculatePrediction(par, metaPar, data, auxData, weights, pets)
   
   n_pets = length(pets);
   parPets = parGrp2Pets(par); % convert parameter structure of group of pets to cell string for each pet

   % get (mean) relative errors and symmetric mean squared errors
   weightsMRE = weights;  % define a weights structure with weight 1 for every data point and 0 for the pseudodata 
   for i = 1:n_pets    
      if isfield(weights.(pets{i}), 'psd')
         psdSets = fields(weights.(pets{i}).psd);
         for j = 1:length(psdSets)
           weightsMRE.(pets{i}).psd.(psdSets{j}) = zeros(length(weightsMRE.(pets{i}).psd.(psdSets{j})), 1);
         end
      end
      [metaPar.(pets{i}).MRE, metaPar.(pets{i}).RE, info] = mre_st(['predict_', pets{i}], parPets.(pets{i}), data.(pets{i}), auxData.(pets{i}), weightsMRE.(pets{i}));
      [metaPar.(pets{i}).SMSE, metaPar.(pets{i}).SSE] = smse_st(['predict_', pets{i}], parPets.(pets{i}), data.(pets{i}), auxData.(pets{i}), weightsMRE.(pets{i}));
      if info == 0
         error('One parameter set did not pass the customized filters in the predict file')
      end
      clear('dataTemp', 'auxDataTemp', 'weightsMRETemp');
   end
   
   data2plot = data;

   univarX = {}; 
   for i = 1:n_pets
      st = data2plot.(pets{i}); 
      [nm, nst] = fieldnmnst_st(st);
      for j = 1:nst  % replace univariate data by plot data 
        fieldsInCells = textscan(nm{j},'%s','Delimiter','.');
        varData = getfield(st, fieldsInCells{1}{:});   % scaler, vector or matrix with data in field nm{i}
        k = size(varData, 2);  
        if k == 2 
          auxDataFields = fields(auxData.(pets{i}));
          dataCode = fieldsInCells{1}{:};
          univarAuxData = {};
          for ii = 1:length(auxDataFields) % add to univarAuxData all auxData for the data set that has length > 1
            if isfield(auxData.(pets{i}).(auxDataFields{ii}), dataCode) && length(auxData.(pets{i}).(auxDataFields{ii}).(dataCode)) > 1
              univarAuxData{end + 1} = auxDataFields{ii};
            end
          end
          aux = getfield(st, fieldsInCells{1}{:});
          dataVec = aux(:,1); 
          if isempty(univarAuxData) % if there is no univariate auxiliary data the axis can have 100 points otherwise it will have the same points as in data 
            xAxis = linspace(min(dataVec), max(dataVec), 100)';
            univarX = setfield(univarX, fieldsInCells{1}{:}, 'dft');
          else
            xAxis = dataVec;
            univarX = setfield(univarX, fieldsInCells{1}{:}, 'usr');
          end
          st = setfield(st, fieldsInCells{1}{:}, xAxis);
        end
      end
      data2plot.(pets{i}) = st;
   end

   prdData = predict_pets(par, data2plot, auxData);
end


%% Plots results into screen.
function plotResultImage(result, data, auxData, ~, txtData, weights, pets, save_results, fig_counter)

   n_pets = length(pets);
   % Get the best solution index from data. 
   best_index = find(result.solutionsParameters(:,1)==min(result.solutionsParameters(:,1)));
   par = result.solutionSet.(['solution_',num2str(best_index)]).par;
   metaPar = result.solutionSet.(['solution_',num2str(best_index)]).metaPar;
   metaData = result.solutionSet.metaData;
   txtPar = result.solutionSet.txtPar;

   close all % to avoid saving figures generated prior the current run
   
   % Calculate prediction.
   [prdData, metaPar, data2plot, univarX] = calculatePrediction(par, metaPar, data, auxData, weights, pets);
   
   counter_fig = 0;

   for i = 1:n_pets
   if exist(['custom_results_', pets{i}, '.m'], 'file')
     feval(['custom_results_', pets{i}], par, metaPar, data.(pets{i}), txtData.(pets{i}), auxData.(pets{i}));
   else
     st = data.(pets{i}); 
     [nm, nst] = fieldnmnst_st(st);
     counter_filenm = 0;
     for j = 1:nst
       fieldsInCells = textscan(nm{j},'%s','Delimiter','.');
       var = getfield(st, fieldsInCells{1}{:});   % scaler, vector or matrix with data in field nm{i}
       k = size(var, 2);
       if k == 2 
         if isfield(metaData.(pets{1}), 'grp') % branch to start working on grouped graphs
           plotColours4AllSets = listOfPlotColours4UpTo13Sets;
           maxGroupColourSize = length(plotColours4AllSets) + 1;
           grpSet1st = cellfun(@(v) v(1), metaData.(pets{1}).grp.sets);
           allSetsInGroup = horzcat(metaData.(pets{1}).grp.sets{:});
           if sum(strcmp(grpSet1st, nm{j})) 
             sets2plot = metaData.(pets{1}).grp.sets{strcmp(grpSet1st, nm{j})};
             n_sets2plot = length(sets2plot); % actually: # of data sets in set j
             if length(sets2plot) < maxGroupColourSize  % choosing the right set of colours depending on the number of sets to plot
               plotColours = plotColours4AllSets{max(1,n_sets2plot - 1)}; 
             else
               plotColours = plotColours4AllSets{4};
             end
             figure; counter_fig = counter_fig + 1; counter_filenm = counter_filenm + 1; 
             hold on;
             set(gca,'Fontsize',10); 
             set(gcf,'PaperPositionMode','manual');
             set(gcf,'PaperUnits','points'); 
             set(gcf,'PaperPosition',[0 0 350 250]);%left bottom width height
             legend = cell(0,2);
             for ii = 1: n_sets2plot
               xData = st.(sets2plot{ii})(:,1); 
               yData = st.(sets2plot{ii})(:,2);
               xPred = data2plot.(pets{i}).(sets2plot{ii})(:,1); 
               yPred = prdData.(pets{i}).(sets2plot{ii});
               if n_sets2plot == 1
                 plot(xPred, yPred,'Color', plotColours{2}, 'linewidth', 2)
                 plot(xData, yData, '.', 'Color', plotColours{1}, 'Markersize',15)
               else
                 plot(xPred, yPred, xData, yData, '.', 'Color', plotColours{mod(ii, maxGroupColourSize)}, 'Markersize',15, 'linewidth', 2)
                 legend = [legend; {{'.', 15, 2, plotColours{mod(ii, maxGroupColourSize)}, plotColours{mod(ii, maxGroupColourSize)}}, sets2plot{ii}}];
               end
               xlabel([txtData.(pets{i}).label.(nm{j}){1}, ', ', txtData.(pets{i}).units.(nm{j}){1}]);
               ylabel([txtData.(pets{i}).label.(nm{j}){2}, ', ', txtData.(pets{i}).units.(nm{j}){2}]);
             end
             if isfield(metaData.(pets{1}).grp, 'comment')
               txt = metaData.(pets{1}).grp.comment{strcmp(grpSet1st, nm{j})}; 
             else
               txt = ['Result', pets{i}];
             end
             title(txt); 

           elseif sum(strcmp(allSetsInGroup, nm{j})) == 0
             figure; counter_fig = counter_fig + 1;  counter_filenm = counter_filenm + 1; 
             set(gca,'Fontsize',15); 
             set(gcf,'PaperPositionMode','manual');
             set(gcf,'PaperUnits','points'); 
             set(gcf,'PaperPosition',[0 0 350 250]);%left bottom width height
             xData = st.(nm{j})(:,1); 
             yData = st.(nm{j})(:,2);
             xPred = data2plot.(pets{i}).(nm{j})(:,1); 
             yPred = prdData.(pets{i}).(nm{j});
             plot(xPred, yPred, 'b', xData, yData, '.r', 'Markersize',15, 'linewidth', 2)
             xlabel([txtData.(pets{i}).label.(nm{j}){1}, ', ', txtData.(pets{i}).units.(nm{j}){1}]);
             ylabel([txtData.(pets{i}).label.(nm{j}){2}, ', ', txtData.(pets{i}).units.(nm{j}){2}]);   
             title(txtData.(pets{i}).bibkey.(nm{j}));
           end

         else
           figure; counter_fig = counter_fig + 1;  counter_filenm = counter_filenm + 1; 
           set(gca,'Fontsize',15); 
           set(gcf,'PaperPositionMode','manual');
           set(gcf,'PaperUnits','points'); 
           set(gcf,'PaperPosition',[0 0 350 250]);%left bottom width height
           xData = var(:,1); 
           yData = var(:,2);
           aux = getfield(data2plot.(pets{i}), fieldsInCells{1}{:});
           xPred = aux(:,1);
           yPred = getfield(prdData.(pets{i}), fieldsInCells{1}{:});
           if strcmp(getfield(univarX, fieldsInCells{1}{:}), 'dft')
             plot(xPred, yPred, 'b', xData, yData, '.r', 'Markersize',15, 'linewidth', 2)
           elseif strcmp(getfield(univarX, fieldsInCells{1}{:}), 'usr')
             plot(xPred, yPred, '.b', xData, yData, '.r', 'Markersize',15, 'linestyle', 'none')
           end
           if length(fieldsInCells{1}) == 1
             aux = txtData.(pets{i});
           else
             aux = txtData.(pets{i}).(fieldsInCells{1}{1});
           end
           xlabel([aux.label.(fieldsInCells{1}{end}){1}, ', ', aux.units.(fieldsInCells{1}{end}){1}]);
           ylabel([aux.label.(fieldsInCells{1}{end}){2}, ', ', aux.units.(fieldsInCells{1}{end}){2}]);
           title(['Best Estimation (solution #', num2str(best_index), ')'])
         end
       end
     end
   end 
   end
   if save_results  % save graphs to .png
     savePNG('Best_Result', pets, fig_counter);
     saveResultsHTML(par, metaPar, txtPar, metaData.(pets{1}));
   end
end

%% Results set plot. 
function plotResultsSet(result, data, auxData, metaData, txtData, weights, pets, save_results, fig_counter)
  % Get the number of pets from data. 
  n_pets = length(pets);
  % Get the number of solutions and the best solution index from data. 
  f_names = fieldnames(result.solutionSet);
  num_solutions = sum(contains(f_names, 'solution_'));
  best_index = find(result.solutionsParameters(:,1)==min(result.solutionsParameters(:,1)));
  if length(best_index) > 1
      best_index = best_index(1);
  end
  if fig_counter == 1
   close all % to avoid saving figures generated prior the current run
  end
  
  % Prepare the figure and its settings. 
  figure;
  set(gca,'Fontsize',15); 
  set(gcf,'PaperPositionMode','manual');
  set(gcf,'PaperUnits','points'); 
  set(gcf,'PaperPosition',[0 0 350 250]);%left bottom width height
  plot_best = false;
  
  % Start holding the plots. 
  hold on;
  
  % The plot follows the same schema: 
  % - First, the solutions (without the best one) are plotted by using
  % their predicted values in grey color. 
  % - Then, the best solution prediction is plotted in black. 
  % - Finally, the real values from data are pinted by using points in blue
  % color. 
  for sol = 1:num_solutions
      % Leave the best solution plot for the last step. 
      if sol == num_solutions
         plot_best = true; % Activating the best solution plot. 
         par = result.solutionSet.(['solution_',num2str(best_index)]).par;
         metaPar = result.solutionSet.(['solution_',num2str(best_index)]).metaPar;
      else % For solutions which are different from the best one. 
         if sol == best_index % Skip the best solution index.  
           sol = sol+1;
         end
         par = result.solutionSet.(['solution_',num2str(sol)]).par;
         metaPar = result.solutionSet.(['solution_',num2str(sol)]).metaPar;
      end
      
      % Calculate prediction. 
      [prdData, metaPar, data2plot, univarX] = calculatePrediction(par, metaPar, data, auxData, weights, pets);
      
      for i = 1:n_pets
         if exist(['custom_results_', pets{i}, '.m'], 'file')
            feval(['custom_results_', pets{i}], par, metaPar, data.(pets{i}), txtData.(pets{i}), auxData.(pets{i}));
         else
         st = data.(pets{i}); 
         [nm, nst] = fieldnmnst_st(st);
         for j = 1:nst
            fieldsInCells = textscan(nm{j},'%s','Delimiter','.');
            var = getfield(st, fieldsInCells{1}{:});   % scaler, vector or matrix with data in field nm{i}
            k = size(var, 2);
            if k == 2 
               xData = var(:,1); 
               yData = var(:,2);
               aux = getfield(data2plot.(pets{i}), fieldsInCells{1}{:});
               xPred = aux(:,1);
               yPred = getfield(prdData.(pets{i}), fieldsInCells{1}{:});
            if strcmp(getfield(univarX, fieldsInCells{1}{:}), 'dft')
               if ~plot_best
                  plotData = plot(xPred, yPred,'LineWidth', 1, 'LineStyle', '-'); 
                  plotData.Color = [0.5, 0.5, 0.5, 0.5];
               else
                  pBest = plot(xPred, yPred, 'black', xData, yData, '.b', 'Markersize',5, 'LineWidth', 1); 
                  lgd = legend(pBest, {'predicted', 'observed'}, 'Location', 'northwest');
                  lgd.FontSize = 10;
               end
            elseif strcmp(getfield(univarX, fieldsInCells{1}{:}), 'usr')
               plot(xPred, yPred, '.b', xData, yData, '.r', 'Markersize',15, 'linestyle', 'none')
            end
            if length(fieldsInCells{1}) == 1
               aux = txtData.(pets{i});
            else
               aux = txtData.(pets{i}).(fieldsInCells{1}{1});
            end
            xlabel([aux.label.(fieldsInCells{1}{end}){1}, ', ', aux.units.(fieldsInCells{1}{end}){1}]);
            ylabel([aux.label.(fieldsInCells{1}{end}){2}, ', ', aux.units.(fieldsInCells{1}{end}){2}]);
            title(['Set Estimation (', num2str(num_solutions), ' solutions)']);
            end
         end
         end 
      end
  end
  % Print the error values (MRE and SMSE) in the south-east part of the
  % plot. 
  ylim=get(gca,'ylim');
  xlim=get(gca,'xlim');
  % Error test. 
  error_test = ['  MRE = ', ..., 
     num2str(round(result.solutionSet.(['solution_',num2str(best_index)]).metaPar.MRE, 5)), ...,
     '\nSMSE = ', ..., 
     num2str(round(result.solutionSet.(['solution_',num2str(best_index)]).metaPar.SMSE, 5)), ..., 
     ' \n'];
  % Set tests. 
  text(xlim(2)-90,ylim(1)+20, sprintf(error_test));
  % Stop holding graphs. 
  hold off;
  
  if save_results  % save graphs to .png
    savePNG('Set_Results', pets, fig_counter);
  end
end

%% Plots the result vales (such as MRE, SMSE, and parameter values on screen
function plotResulValues(result, txtPar, data, auxData, metaData, txtData, weights, pets)
   n_pets = length(pets);
   % Get the best solution index from data.
   best_index = find(result.solutionsParameters(:,1)==min(result.solutionsParameters(:,1)));
   par = result.solutionSet.(['solution_',num2str(best_index)]).par; 
   metaPar = result.solutionSet.(['solution_',num2str(best_index)]).metaPar;
   
   % Calculate prediction. 
   [prdData, metaPar, ~, ~, parPets] = calculatePrediction(par, metaPar, data, auxData, weights, pets);
   
   for i = 1:n_pets
      fprintf([pets{i}, ' \n']); % print the species name
      if isfield(metaData.(pets{i}), 'COMPLETE')
        fprintf('COMPLETE = %3.1f \n', metaData.(pets{i}).COMPLETE)
      end
      fprintf('MRE = %8.3f \n', metaPar.(pets{i}).MRE)
      fprintf('SMSE = %8.3f \n\n', metaPar.(pets{i}).SMSE)
      
      fprintf('\n');
      printprd_st(data.(pets{i}), txtData.(pets{i}), prdData.(pets{i}), metaPar.(pets{i}).RE);
      
      currentPar = parPets.(pets{i});
      free = currentPar.free;  
      corePar = rmfield_wtxt(currentPar,'free'); coreTxtPar.units = txtPar.units; coreTxtPar.label = txtPar.label;
      [parFields, nbParFields] = fieldnmnst_st(corePar);
      % we need to make a small addition so that it recognised if one of the chemical parameters was released and then print that to the screen
      for j = 1:nbParFields
        if  ~isempty(strfind(parFields{j},'n_')) || ~isempty(strfind(parFields{j},'mu_')) || ~isempty(strfind(parFields{j},'d_'))
          corePar          = rmfield_wtxt(corePar, parFields{j});
          coreTxtPar.units = rmfield_wtxt(coreTxtPar.units, parFields{j});
          coreTxtPar.label = rmfield_wtxt(coreTxtPar.label, parFields{j});
          free  = rmfield_wtxt(free, parFields{j});
        end
      end
      parFreenm = fields(free);
      for j = 1:length(parFreenm)
        if length(free.(parFreenm{j})) ~= 1
          free.(parFreenm{j}) = free.(parFreenm{j})(i);
        end
      end
      corePar.free = free;
      printpar_st(corePar,coreTxtPar);
      fprintf('\n')
    end
end

function plotColours4AllSets = listOfPlotColours4UpTo13Sets
    % colours (in rgb) follow lava-scheme: from white (high), via red and blue, to black (low)
    % for 2 colours, this amounts to red and blue, e.g. for female and male, respectively

  plotColours4AllSets = { ...
    {[1, 0, 0], [0, 0, 1]}, ...
    {[1, 0, 0], [1, 0, 1], [0, 0, 1]}, ...
    {[1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, 0]}, ...
    {[1, .5, .5], [1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, 0]}, ...
    {[1, .5, .5], [1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, .5], [0, 0, 0]}, ...
    {[1, .75, .75], [1, .5, .5], [1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, .5], [0, 0, 0]}, ...
    {[1, .75, .75], [1, .5, .5], [1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, .5], [0, 0, .25], [0, 0, 0]}, ...
    {[1, .75, .75], [1, .5, .5], [1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, .75], [0, 0, .5], [0, 0, .25], [0, 0, 0]}, ...
    {[1, .75, .75], [1, .5, .5], [1, .25, .25], [1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, .75], [0, 0, .5], [0, 0, .25], [0, 0, 0]}, ...
    {[1, .75, .75], [1, .5, .5], [1, .25, .25], [1, 0, 0], [1, 0, .5], [1, 0, 1], [0, 0, 1], [0, 0, .75], [0, 0, .5], [0, 0, .25], [0, 0, 0]}, ...
    {[1, .75, .75], [1, .5, .5], [1, .25, .25], [1, 0, 0], [1, 0, .5], [1, 0, 1], [.5, 0, 1],  [0, 0, 1], [0, 0, .75], [0, 0, .5], [0, 0, .25], [0, 0, 0]}, ...
    {[1, .75, .75], [1, .5, .5], [1, .25, .25], [1, 0, 0], [1, 0, .5], [1, 0, .75], [1, 0, 1], [.5, 0, 1],  [0, 0, 1], [0, 0, .75], [0, 0, .5], [0, 0, .25], [0, 0, 0]}, ...
    };

end