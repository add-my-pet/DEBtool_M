%% plot_solution
% Plots solutions from data

%%
function plot_solution(par, metaPar, data, auxData, metaData, txtData)
% created 2020/11/30 by Juan Francisco Robles

%% Syntax
% <../plot_solution.m *plot_solution*>(par, metaPar, data, auxData, metaData, weights) 

%% Description
% Plotes model predictions from calibration solutions
%
% Input
% 
% * par: structure with parameters of species
% * metaPar: structure with information on metaparameters
% * data: structure with data for species
% * auxData: structure with auxilliairy data that is required to compute predictions of data (e.g. temperature, food.). 
%   auxData is unpacked in predict and the user needs to construct predictions accordingly.
% * metaData: structure with information on the entry
% * txtData: structure with information on the data

%% Remarks
% Depending on <estim_options.html *estim_options*> settings:
% writes to results_my_pet.mat and/or results_my_pet.html, 
% plots to screen
% writes to report_my_pet.html and shows in browser
% Plots use lava-colour scheme; from high to low: white, red, blue, black.
% In grp-plots, colours are assigned from high to low.
% Since the standard colour for females is red, and for males blue, compose set with females first, then males.

global pets 

n_pets = length(pets);
data2plot = data;
close all % to avoid saving figures generated prior the current run
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
        if isfield(metaData, 'grp') % branch to start working on grouped graphs
          plotColours4AllSets = listOfPlotColours4UpTo13Sets;
          maxGroupColourSize = length(plotColours4AllSets) + 1;
          grpSet1st = cellfun(@(v) v(1), metaData.grp.sets);
          allSetsInGroup = horzcat(metaData.grp.sets{:});
          if sum(strcmp(grpSet1st, nm{j})) 
            sets2plot = metaData.grp.sets{strcmp(grpSet1st, nm{j})};
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
            txt = metaData.grp.comment{strcmp(grpSet1st, nm{j})}; 
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
            aux = txtData;
          else
            aux = txtData.(fieldsInCells{1}{1});
          end
          xlabel([aux.(pets{i}).label.(fieldsInCells{1}{end}){1}, ', ', aux.(pets{i}).units.(fieldsInCells{1}{end}){1}]);
          ylabel([aux.(pets{i}).label.(fieldsInCells{1}{end}){2}, ', ', aux.(pets{i}).units.(fieldsInCells{1}{end}){2}]);
          title(aux.(pets{i}).bibkey.(fieldsInCells{1}{end}));
        end
      end
    end
  end 
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