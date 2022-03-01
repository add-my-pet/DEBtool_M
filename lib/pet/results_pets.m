%% results_pets
% Computes model predictions and handles them

%%
function results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights)
% created  2015/01/17 by Goncalo Marques, 
% modified 2015/03/21 by Bas Kooijman, 2015/03/30 by Goncalo Marques, 
% modified 2015/04/01 by Bas Kooijman, 
% modified 2015/04/14, 2015/04/27, 2015/05/05  by Goncalo Marques, 
% modified 2015/07/30 by Starrlight Augustine, 2015/08/01 by Goncalo Marques,
% modified 2015/08/25 by Dina Lika, 
% modified 2018/05/21, 2018/08/21, 2019/03/02, 2019/04/08, 2019/07/27 by Bas Kooijman
% modified 2019/08/30, 2019/11/12, 2019/12/20 by Nina Marn
% modified 2020/10/27, 2021/01/16, 2022/01/25 by Bas Kooijman

%% Syntax
% <../results_pets.m *results_pets*>(par, metaPar, txtPar, data, auxData, metaData, txtData, weights) 

%% Description
% Computes model predictions and handles them (by plotting, saving or publishing).
% All input structures have the species name as first field, which is done by estim_pars.
% The user composes these structures via the mydata_my_pet and pars_init_my_pet files, 
% where the first field directly relates to the variables.
% This function also requires a working predict_my_pet.
%
% Input
% 
% * par: structure with parameters of species
% * metaPar: structure with information on metaparameters
% * txtPar: structure with information on parameters
% * data: structure with data for species
% * auxData: structure with auxilliairy data that is required to compute predictions of data (e.g. temperature, food.). 
%   auxData is unpacked in predict and the user needs to construct predictions accordingly.
% * metaData: structure with information on the entry
% * txtData: structure with information on the data
% * weights: structure with weights for each data set

%% Remarks
% Depending on <estim_options.html *estim_options*> settings:
% writes to results_my_pet.mat and/or results_my_pet_i.png and/or my_pet_res.html and/or report_my_pet.html and/or my_pet_pop.html;  
% writes and/or plots to screen.
%
% Plots use lava-colour scheme; from high to low: white, red, blue, black.
% In grp-plots, colours are assigned from high to low.
% Since the standard colour for females is red, and for males blue, compose set with females first, then males.
%
% Bi-variate data requires field auxData.treat.(name-of-data-set) with a 2-cell string: 
% the first element 0 for no interpolation, 1 for mesh, 2 for surface;
% the second element is a cell-string of a length equal to the number of values for the second independent variable.
% (So one minus the number of columns of (name-of-data-set); the first column is the first independent variable).
% If the second element of treat is numeric, there must be a field txtData.units.treat.(name-of-data-set).
% If no interpolation is used, the legend is plotted in a separate figure.
%
% If output options -5/5 or 6 are used, and comparison species are included in the traits-table. 
% Function clade is used to identify a few most related species, unless global refPets is defined in the run-file with names to species to compare with.
%
% In the case of multiple species, par and metaPar have the species names as first field, but not so for a single species
% 
% For curators: 
% my_pet_res.html is written in the directory entries, and deleted by run_collection, which writes another file with that name in directory entries_web.

  global pets refPets results_output dataSet_nFig
  
  % dataSet_nFig is a (n,2)-cell array with names of data sets in col 1, and 2-char txt with figure-number in col 2; 
  % If fig nFig has a legend, this element is not a string, but a cell-string of length 2, where nFig_legend is added
  % This is used in prt_results_my_pet and prt_report_AmPtox
  
  n_pets = length(pets); dataSet_nFig = cell(0,2);
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
    [metaPar.(pets{i}).SMAE, metaPar.(pets{i}).SAE] = smae_st(['predict_', pets{i}], parPets.(pets{i}), data.(pets{i}), auxData.(pets{i}), weightsMRE.(pets{i}));
    [metaPar.(pets{i}).SMSE, metaPar.(pets{i}).SSE] = smse_st(['predict_', pets{i}], parPets.(pets{i}), data.(pets{i}), auxData.(pets{i}), weightsMRE.(pets{i}));
    if info == 0
      error('One parameter set did not pass the customized filters in the predict file')
    end
    clear('dataTemp', 'auxDataTemp', 'weightsMRETemp');
  end
  
  if n_pets > 1 % MRE, SMAE, SMSE, lossf and cv are used in addCV to report in addCV.html, which is why they are added to metaPar here
    %prdData = feval('predict_pets', par, data, auxData);
    prdData = predict_pets(par, data, auxData);
    metaPar.lossf = lossfun(data, prdData, weights); % this does not include contributions from the augmented term or pseudo-data
    MRE = 0; SMAE = 0; SMSE = 0;  % append MRE, SMAE and SMSE to metaPar as means over all pets
    for i = 1 : n_pets
      MRE = MRE + metaPar.(pets{i}).MRE; 
      SMAE = SMAE + metaPar.(pets{i}).SMAE; 
      SMSE = SMSE + metaPar.(pets{i}).SMSE;
    end
    metaPar.MRE = MRE/ n_pets; metaPar.SMAE = SMAE/ n_pets; metaPar.SMSE = SMSE/ n_pets;
    % append cv's to metaPar.cv, similar to metaPar.weights
    flds = fields(metaPar.weights); n_pars = length(flds);
    for j = 1 : n_pars
      metaPar.cv.(flds{j}) = var(par.(flds{j}))^0.5/ mean(par.(flds{j}));
    end        
  end
   
  if ~results_output == 0 % plot figures
    txt0 = '0'; % text to prepend to figure counter if counter < 10 (for intuitive listing sequence in the directory)
    data2plot = data; % with pets as first field names
    close all % to avoid saving figures generated prior the current run
    for i = 1:n_pets % scan pets
      st = data2plot.(pets{i}); if isfield(st,'psd'); st = rmfield(st,'psd'); end
      [nm, nst] = fieldnmnst_st(st);
      for j = 1:nst  % replace univariate data by plot data 
        fieldsInCells = textscan(nm{j},'%s','Delimiter','.');
        varData = getfield(st, fieldsInCells{1}{:});   % scalar, vector or matrix with data in field nm{j}
        k = size(varData, 2);
        if k == 1
          st = rmfield(st,nm{j}); % remove zero-variate data from structure
        else % k > 1: uni- or bi-variate data set
          auxDataFields = fields(auxData.(pets{i}));
          dataCode = fieldsInCells{1}{:};
          univarAuxData = {};
          for ii = 1:length(auxDataFields) % add to univarAuxData all auxData for the data set that has length > 1
            if isfield(auxData.(pets{i}), 'treat') && isfield(auxData.(pets{i}).treat, dataCode) && auxData.(pets{i}).treat.(dataCode){1} == 0
              univarAuxData{end + 1} = auxDataFields{ii};
            end
          end
          aux = getfield(st, fieldsInCells{1}{:});
          dataVec = aux(:,1); 
          if isfield(auxData.(pets{i}), 'treat') && isfield(auxData.(pets{i}).treat, dataCode) && auxData.(pets{i}).treat.(dataCode){1} == 0
            % if auxData.(pets{i}).treat is specified for this dataCode and equals 1, interpolation is allowed
            xAxis = dataVec;
          else
            n_x = 100; xAxis = linspace(min(dataVec), max(dataVec), n_x)';
          end
          st = setfield(st, fieldsInCells{1}{:}, xAxis);
        end
      end % end of scan data sets of pets{i}
      data2plot.(pets{i}) = st;
    end % end of scan pets
    
    
    prdData = predict_pets(par, data, auxData); % data prediction
    prdData_x = predict_pets(par, data2plot, auxData); % data prediction with xAxis
    counter_fig = 0;
    
    path =  which('custom_results_group.m');
    if ~isempty(path) && ~isempty(strfind(path, pwd))
      custom_results_group(par, metaPar, data, txtData, auxData);
    else
      for i = 1:n_pets
        if exist(['custom_results_', pets{i}, '.m'], 'file')
          feval(['custom_results_', pets{i}], par, metaPar, data.(pets{i}), txtData.(pets{i}), auxData.(pets{i}));
        else
          st = data.(pets{i}); % structure with field names of all data sets (zero-, uni-, bi-, psd)
          [nm, nst] = fieldnmnst_st(data2plot.(pets{i})); % field names of uni- and bi-variate data sets
          allSetsInGroup = {};
          if isfield(metaData.(pets{i}), 'grp') % first working on grouped graphs
            grpSets =  metaData.(pets{i}).grp.sets; n_grpSets = length(grpSets);
            for ii = 1:n_grpSets % scan the group-sets
              figure; counter_fig = counter_fig + 1; legend = cell(0,2);
              nFig = [txt0(counter_fig < 10), num2str(counter_fig)]; 
              hold on;
              set(gca,'Fontsize',10); 
              set(gcf,'PaperPositionMode','manual');
              set(gcf,'PaperUnits','points'); 
              set(gcf,'PaperPosition',[0 0 350 250]); % left bottom width height
              nms = metaData.(pets{i}).grp.sets{ii}; n_nms = length(nms); % names of data sets in group set ii
              allSetsInGroup = [allSetsInGroup, nms];  
              plotColours4AllSets = listOfPlotColours4UpTo13Sets;
              maxGroupColourSize = length(plotColours4AllSets) + 1;
              for jj = 1:n_nms % scan names of data sets in group set ii 
                if length(n_nms) < maxGroupColourSize  % choosing the right set of colours depending on the number of sets to plot
                  plotColours = plotColours4AllSets{max(1,n_nms - 1)}; 
                else
                  plotColours = plotColours4AllSets{4};
                end
                xData = st.(nms{jj})(:,1); 
                yData = st.(nms{jj})(:,2);
                xPred = data2plot.(pets{i}).(nms{jj})(:,1); 
                yPred = prdData_x.(pets{i}).(nms{jj});
                if n_nms == 1
                  if isfield(auxData.(pets{i}), 'treat') && isfield(auxData.(pets{i}).treat, nms{jj}) && auxData.(pets{i}).treat.(nms{jj}){1} == 0
                    plot(xPred, yPred, 'o', 'Color',plotColours{2}, 'Markersize',3)
                  else
                    plot(xPred, yPred,'Color',plotColours{2}, 'linewidth',2)
                  end
                  plot(xData, yData, '.', 'Color',plotColours{1}, 'Markersize',15)
                else % more than 1 data set in group set ii
                  if isfield(auxData.(pets{i}), 'treat') && isfield(auxData.(pets{i}).treat, nms{jj}) && auxData.(pets{i}).treat.(nms{jj}){1} == 0
                    plot(xPred, yPred, 'o', 'Color',plotColours{mod(jj, maxGroupColourSize)}, 'Markersize',3)
                  else
                    plot(xPred, yPred, 'Color',plotColours{mod(jj, maxGroupColourSize)}, 'linewidth',2)
                  end
                  plot(xData, yData, '.', 'Color',plotColours{mod(jj, maxGroupColourSize)}, 'Markersize',15)
                  if length(txtData.(pets{i}).label.(nms{jj})) == 3
                    legend = [legend; {{'.', 15, 2, plotColours{mod(jj, maxGroupColourSize)}, plotColours{mod(jj, maxGroupColourSize)}}, txtData.(pets{i}).label.(nms{jj}){3}}];
                  else
                    legend = [legend; {{'.', 15, 2, plotColours{mod(jj, maxGroupColourSize)}, plotColours{mod(jj, maxGroupColourSize)}}, nms{jj}}];
                  end 
                end
                dataSet_nFig = [dataSet_nFig; {nms{jj}, {nFig, [nFig,'_legend']}}];
              end
              % xlabels and ylabels of all data sets in a group set should be the same
              xlabel([txtData.(pets{i}).label.(nms{1}){1}, ', ', txtData.(pets{i}).units.(nms{1}){1}]);
              ylabel([txtData.(pets{i}).label.(nms{1}){2}, ', ', txtData.(pets{i}).units.(nms{1}){2}]);
              try
                title(['\it',metaData.(pets{i}).grp.title{ii}], 'FontSize',15, 'FontWeight','normal'); 
              catch
                title(''); 
              end
              if abs(results_output) >= 3
                plotNm = ['results_', pets{i}, '_', nFig];
                print(plotNm, '-dpng')
              end
              if n_nms > 1
                plotNm = ['results_', pets{i}, '_', nFig];
                LEGEND.([plotNm, '_legend']) = legend; 
              end % end of grouped plots
            end
          end % end of all grp plots   
          nm = setdiff(nm, allSetsInGroup); nst = length(nm); % remove all nms that were already in grp plot
          
          for j = 1:nst % now plot non-grouped plots
            fieldsInCells = textscan(nm{j},'%s','Delimiter','.');
            Var = getfield(st, fieldsInCells{1}{:});   % scalar, vector or matrix with data in field nm{i}
            k = size(Var, 2);
            figure; counter_fig = counter_fig + 1; hold on
            nFig = [txt0(counter_fig < 10), num2str(counter_fig)]; 
            set(gca,'Fontsize',15); 
            set(gcf,'PaperPositionMode','manual');
            set(gcf,'PaperUnits','points'); 
            set(gcf,'PaperPosition',[0 0 350 250]);%left bottom width height

            if k == 2 % uni-variate data set
              xData = Var(:,1); 
              yData = Var(:,2);
              aux = getfield(data2plot.(pets{i}), fieldsInCells{1}{:});
              xPred = aux(:,1);
              yPred = getfield(prdData_x.(pets{i}), fieldsInCells{1}{:});
              if isfield(auxData.(pets{i}), 'treat') && isfield(auxData.(pets{i}).treat, nm{j}) && auxData.(pets{i}).treat.(nm{j}){1} == 0
                plot(xPred,yPred, 'ob', 'Markersize',3)
              else 
                try
                  plot(xPred,yPred, 'b', 'linewidth',2)
                catch
                  keyboard;
                end
              end
              plot(xData,yData, '.r', 'Markersize',15)
              if length(fieldsInCells{1}) == 1
                aux = txtData.(pets{i});
              else
                aux = txtData.(pets{i}).(fieldsInCells{1}{1});
              end
              xlabel([aux.label.(fieldsInCells{1}{end}){1}, ', ', aux.units.(fieldsInCells{1}{end}){1}]);
              ylabel([aux.label.(fieldsInCells{1}{end}){2}, ', ', aux.units.(fieldsInCells{1}{end}){2}]);
              dataSet_nFig = [dataSet_nFig; {nm{j}, nFig}];
              try
                title(['\it',aux.title.(fieldsInCells{1}{end})], 'FontSize',15, 'FontWeight','normal');
              catch
                title('');
              end
              if abs(results_output) >= 3 
                plotNm = ['results_', pets{i}, '_', nFig, '.png'];
                print(plotNm, '-dpng')
              end
            
            else % bi-variate data
              if ~isfield(auxData.(pets{i}), 'treat') || ~isfield(auxData.(pets{i}).treat,nm{j}) || ~k == 1+length(auxData.(pets{i}).treat.(nm{j}){2}) % number of values to 2nd variable needs to match nuber of columns
                fprintf('Warning from results_pets: bi-variate data %s is found, but the length of field "auxData.treat.%s{2}" does not match the number of independent variables\n', nm{j}, nm{j});
                return
              end
              aux =  auxData.(pets{i});
              treat = aux.treat.(nm{j}); % 2-cell string, 2nd element values of 2nd independent variable, might be non-numeric
              hold on;
              %
              if treat{1} == 0 % do not interpolate 1st and 2nd independent var and plot markers
                plotColours4AllSets = listOfPlotColours4UpTo13Sets;
                maxGroupColourSize = length(plotColours4AllSets) + 1;
                n_sets2plot = size(st.(nm{j}),2) - 1; % # of data sets in nm{j}
                if n_sets2plot < maxGroupColourSize  % choosing the right set of colours depending on the number of sets to plot
                  plotColours = plotColours4AllSets{max(1,n_sets2plot - 1)}; 
                else
                  plotColours = plotColours4AllSets{4};
                end
                legend = cell(0,2);
                yPred = predict_pets(par, data, auxData); yPred = yPred.(pets{i}).(nm{j});
                for ii = 1: n_sets2plot
                  xData = st.(nm{j})(:,1); 
                  yData = st.(nm{j})(:,1+ii);
                  xPred = st.(nm{j})(:,1); 
                  if n_sets2plot == 1
                    plot(xPred, yPred, 'o', 'Color', plotColours{1}, 'Markersize', 3)
                    plot(xData, yData, '.', 'Color', plotColours{1}, 'Markersize',15)
                  else
                    plot(xPred, yPred(:,ii), 'o', 'Color',plotColours{mod(ii, maxGroupColourSize)}, 'Markersize',3)
                    plot(xData, yData, '.', 'Color',plotColours{mod(ii, maxGroupColourSize)}, 'Markersize',15)
                    if isnumeric(treat{2}); txt_ii = [num2str(treat{2}(ii)), ' ', txtData.(pets{i}).units.treat.(nm{j})]; else;  txt_ii = treat{2}(ii); end
                    legend = [legend; {{'.', 15, 2, plotColours{mod(ii, maxGroupColourSize)}, plotColours{mod(ii, maxGroupColourSize)}}, txt_ii}];
                  end
                end
                xlabel([txtData.(pets{i}).label.(nm{j}){1}, ', ', txtData.(pets{i}).units.(nm{j}){1}]);
                ylabel([txtData.(pets{i}).label.(nm{j}){2}, ', ', txtData.(pets{i}).units.(nm{j}){2}]);
                dataSet_nFig = [dataSet_nFig; {nm{j}, {nFig, [nFig,'_legend']}}];
                try
                  title(['\it',txtData.(pets{i}).title.(nm{j})], 'FontSize',15, 'FontWeight','normal');
                catch
                  title('')
                end
                plotNm = ['results_', pets{i}, '_', nFig];
                LEGEND.([plotNm,'_legend']) = legend; 
                LEGENDlabel.([plotNm,'_legend']) = txtData.(pets{i}).label.treat.(nm{j});  
                if abs(results_output) >= 3
                  plotNm = ['results_', pets{i}, '_', nFig, '.png'];
                  print(plotNm, '-dpng');
                end
                  
              elseif treat{1} == 1 % do not interpolate 2nd independent var and plot curves
                plotColours4AllSets = listOfPlotColours4UpTo13Sets;
                maxGroupColourSize = length(plotColours4AllSets) + 1;
                n_sets2plot = size(st.(nm{j}),2) - 1; % # of data sets in nm{j}
                if n_sets2plot < maxGroupColourSize  % choosing the right set of colours depending on the number of sets to plot
                  plotColours = plotColours4AllSets{max(1,n_sets2plot - 1)}; 
                else
                  plotColours = plotColours4AllSets{4};
                end
                legend = cell(0,2);
                for ii = 1: n_sets2plot
                  xData = st.(nm{j})(:,1); 
                  yData = st.(nm{j})(:,1+ii);
                  xPred = data2plot.(pets{i}).(nm{j})(:,1); 
                  yPred = prdData_x.(pets{i}).(nm{j})(:,ii);
                  if n_sets2plot == 1
                    plot(xPred, yPred,'Color', plotColours{2}, 'linewidth', 2)
                    plot(xData, yData, '.', 'Color', plotColours{1}, 'Markersize',15)
                  else
                    plot(xPred, yPred, 'Color', plotColours{mod(ii, maxGroupColourSize)}, 'linewidth', 2)
                    plot(xData, yData, '.', 'Color', plotColours{mod(ii, maxGroupColourSize)}, 'Markersize', 15)
                    if isnumeric(treat{2}); txt_ii = [num2str(treat{2}(ii)), ' ', txtData.(pets{i}).units.treat.(nm{j})]; else;  txt_ii = treat{2}(ii); end
                    legend = [legend; {{'.', 15, 2, plotColours{mod(ii, maxGroupColourSize)}, plotColours{mod(ii, maxGroupColourSize)}}, txt_ii}];
                  end
                end
                xlabel([txtData.(pets{i}).label.(nm{j}){1}, ', ', txtData.(pets{i}).units.(nm{j}){1}]);
                ylabel([txtData.(pets{i}).label.(nm{j}){2}, ', ', txtData.(pets{i}).units.(nm{j}){2}]);
                dataSet_nFig = [dataSet_nFig; {nm{j}, {nFig, [nFig,'_legend']}}];
                try
                  title(['\it',txtData.(pets{i}).title.(nm{j})], 'FontSize',15, 'FontWeight','normal');
                catch
                  title('');
                end
                plotNm = ['results_', pets{i}, '_', nFig];
                LEGEND.([plotNm,'_legend']) = legend; 
                LEGENDlabel.([plotNm,'_legend']) = txtData.(pets{i}).label.treat.(nm{j});
                if abs(results_output) >= 3
                  plotNm = ['results_', pets{i}, '_', nFig, '.png'];
                  print(plotNm, '-dpng');
                end
                 
              elseif treat{1} > 1 % interpolate 2nd independent var and plot mesh or surface
                zData = data.(pets{i}).(nm{j}); xData = zData(:,1); zData(:,1) = []; yData = treat{2};
                nX = length(xData); % number of values for 1st independent var
                zPred = predict_pets(par, data, auxData); zPred = zPred.(pets{i}).(nm{j});
                plotColours = {[1 0 0], [0 0 1]}; % red, blue, light & dark magenta
                n_y = 100; yAxis = linspace(min(treat{2}), max(treat{2}), n_y)'; 
                auxData.(pets{i}).treat.(nm{j}) = {treat{1}, yAxis}; 
                prdData_y = predict_pets(par, data, auxData); % data prediction with yAxis
                prdX = prdData_x.(pets{i}).(nm{j}); prdY = prdData_y.(pets{i}).(nm{j}); 
                %
                if treat{1} == 2 % plot mesh
                  plot3(xAxis(:,ones(1,k-1)), ones(n_x,1)*yData', prdX, 'Color',plotColours{2}) 
                  plot3(ones(n_y,1)*xData' , yAxis(:,ones(1,nX)), prdY', 'Color',plotColours{2})
                else % treat{1} == 3 % plot surface; condition n_x = n_y must apply
                  x = [xAxis(:,ones(1,k-1)),ones(n_y,1)*xData']; y = [ones(n_x,1)*yData', yAxis(:,ones(1,nX))]; z = [prdX, prdY'];
                  surf(x,y,z, 'AlphaData',gradient(z), 'FaceAlpha',0.1, 'FaceColor',plotColours{2})
                end
                % plot connections of points to mesh & points
                for ii = 1:k-1  % scan y-values
                  for jj = 1:nX % scan x-values
                    plot3([xData(jj);xData(jj)], [yData(ii);yData(ii)], [zPred(jj,ii);zData(jj,ii)], 'Color', plotColours{1+(zData(jj,ii)<zPred(jj,ii))})
                    plot3(xData(jj), yData(ii), zData(jj,ii), '.', 'Color',plotColours{1}, 'Markersize',15)
                  end
                end
                xlabel([txtData.(pets{i}).label.(nm{j}){1}, ', ', txtData.(pets{i}).units.(nm{j}){1}]);
                ylabel([txtData.(pets{i}).label.treat.(nm{j}), ', ', txtData.(pets{i}).units.treat.(nm{j})]);
                zlabel([txtData.(pets{i}).label.(nm{j}){2}, ', ', txtData.(pets{i}).units.(nm{j}){2}]);
                dataSet_nFig = [dataSet_nFig; {nm{j}, nFig}];
                try
                  title(['\it',txtData.(pets{i}).title.(nm{j})], 'FontSize',15, 'FontWeight','normal');
                catch
                  title('');
                end
                view([-5,-10,-5]);
                ax = gca;
                ax.BoxStyle = 'full';
                box on
                if abs(results_output) >= 3
                  plotNm = ['results_', pets{i}, '_', nFig, '.png'];
                  print(plotNm, '-dpng');
                end
              end
            end 
          end
          
          if exist('LEGEND','var') % plot legend
            nms = fields(LEGEND); n_nms = length(nms);
            for j=1:n_nms
              if exist('treat','var')
                shlegend(LEGEND.(nms{j}), [], [], LEGENDlabel.(nms{j}));
              else
                shlegend(LEGEND.(nms{j}));
              end     
              if abs(results_output) >= 3 % print legend
                print(nms{j}, '-dpng');
              end
            end      
          end    
        end
      end             
    end
  end       
  
 
  for i = 1:n_pets 
    if n_pets == 1
      metaPar.(pets{1}).model = metaPar.model; % only field pet{1} will be saved in .mat
    else
      metaPar.(pets{i}).model = metaPar.model{i}; 
    end
  end

  switch results_output % the results_output controlled saving of figures is done above
    case 0  % only saving to .mat, no figures plotted
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
      else
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
      end
    case 1  % no saving to .mat, no saving to png, print to html
      prt_results_my_pet(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); 
%       else
%         save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
      end
    case -1 % no saving to .mat, no saving to png, print to screen
      prt_results2screen(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); 
%       else
%         save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
      end
    case 2  % save to .mat, no saving to png, print to html
      prt_results_my_pet(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
      else
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
      end
    case -2  % save to .mat, no saving to png, print to screen
      prt_results2screen(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
      else
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
      end
    case 3  % save to .mat, save to png, print to html
      prt_results_my_pet(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
      else
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
      end
    case -3  % save to .mat, save to png, print to screen
      prt_results2screen(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
      else
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
      end
    case 4  % save to .mat, save to png, print to html, implied traits to html
      prt_results_my_pet(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
        prt_report_my_pet({parPets.(pets{1}), metaPar, txtPar, metaData}, []);
      else  
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
        prt_report_my_pet({parPets, metaPar, txtPar, metaData}, []);
      end    
    case -4  % save to .mat, save to png, print to screen, implied traits to html
      prt_results2screen(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
        prt_report_my_pet({parPets.(pets{1}), metaPar, txtPar, metaData}, []);
      else
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
        prt_report_my_pet({parPets, metaPar, txtPar, metaData}, []);
      end
    case 5 % save to .mat, save to png, print to html, implied traits to html, including related species
      prt_results_my_pet(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
        if isempty(refPets)
          prt_report_my_pet({parPets.(pets{1}), metaPar, txtPar, metaData}, clade(metaData.species))
        else
          prt_report_my_pet({parPets.(pets{1}), metaPar, txtPar, metaData}, refPets)  
        end
      else
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
        if isempty(refPets)
          prt_report_my_pet({parPets, metaPar, txtPar, metaData}, clade(fieldnames(metaData))) 
        else
          prt_report_my_pet({parPets, metaPar, txtPar, metaData}, refPets) 
        end
      end
    case -5 % save to .mat, save to png, print to screen, implied properties to html, including related species
      prt_results2screen(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
        if isempty(refPets)
          prt_report_my_pet({parPets.(pets{1}), metaPar, txtPar, metaData}, clade(metaData.species))  
        else
          prt_report_my_pet({parPets.(pets{1}), metaPar, txtPar, metaData}, refPets) 
        end
      else
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
        prt_report_my_pet({parPets, metaPar, txtPar, metaData}, clade(fieldnames(metaData)))  
      end
    case 6 % save to .mat, save to png, print to html, implied traits to html, including related species, population traits to html
      prt_results_my_pet(parPets, metaPar, txtPar, data, metaData, txtData, prdData);
      if n_pets == 1
        metaData = metaData.(pets{1}); metaPar = metaPar.(pets{1}); save(['results_', pets{1}, '.mat'], 'par', 'txtPar', 'metaPar', 'metaData');
        if isempty(refPets)
          prt_report_my_pet({parPets.(pets{1}), metaPar, txtPar, metaData}, clade(metaData.species))  
        else
          prt_report_my_pet({parPets.(pets{1}), metaPar, txtPar, metaData}, refPets) 
        end
        prt_my_pet_pop({metaData, metaPar, par}, [], '0.5'); % my_pet_pop.html, assuming that reprodCode is 'O'
      else
        save('results_group.mat', 'par', 'txtPar', 'metaPar', 'metaData');
        if isempty(refPets)
          prt_report_my_pet({parPets, metaPar, txtPar, metaData}, clade(fieldnames(metaData)))
        else
          prt_report_my_pet({parPets, metaPar, txtPar, metaData}, refPets)
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
    %{[1, .75, .75], [1, .5, .5], [1, .25, .25], [1, 0, 0], [1, 0, .5], [1, 0, .75], [1, 0, 1], [.5, 0, 1],  [0, 0, 1], [0, 0, .75], [0, 0, .5], [0, 0, .25], [0, 0, 0], [0.1, 0.1, 0.1]}, ...
    % <-- note to self : No problem with me as long as the lava-colour coding is respected: from white (high) to black (low), via red and blue. Notice that you can have more than 13 sets, but some will then have the same colours.

% Function DEBtool_M/lib.misc/real2color.m assigns colors in the lava-colour coding scheme, with a facility to work around the problem that colour white might be hard to see :-). Perhaps this function can be called with with any number larger than 13. Function shcolor_lava show the colour-strip with values for colours.
    };

end
