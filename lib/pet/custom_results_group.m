%% custom_results_group
% presents results of univariate data graphically in a customized way for a multi-species case

%%
function custom_results_group(parGrp, metaPar, data, txtData, auxData)
% created by Bas Kooijman 2019/03/11
  
  %% Syntax
  % <../custom_results_group.m *custom_results_group*>(parGrp, metaPar, txtData, data, auxData)
  
  %% Description
  % presents customized results of univariate data in multispecies-plots
  %
  % Inputs:
  %
  % * parGrp: structure with parameters ar specified in the pars_init_grp.m file
  % * metaPar: structure with field T_ref for reference temperature
  % * txt_data: text vector for the presentation of results
  % * data: structure with data
  % * auxData: structure with temperature data and potential food data
  
  %% Remarks
  % if a file with this name is present in the directory of the group, it will suppress other graphical output
  
  % convert all inputs to structures, where the first field names are the pets (ignorging auxData) 
  parGrp = rmfield(parGrp,'free'); par = parGrp2Pets(parGrp); pets = fieldnames(par); n_pets = length(pets);
  %model = metaPar.model; cov_rules = metaPar.cov_rules; metaPar = rmfield(metaPar, {'model','cov_rules'});

  parFlds = fieldnames(parGrp); n_parFlds = length(parFlds); shareTxt = 'share: '; diffTxt = 'diff: ';
  for i = 1:n_parFlds
    if strcmp(parFlds{i}, 'd_X')
      break
    end
    if length(parGrp.(parFlds{i})) == 1
      shareTxt = [shareTxt, parFlds{i}, ', ']; 
    else
      diffTxt = [diffTxt, parFlds{i}, ', '];
    end
  end
  shareTxt(end - 0:1) = ''; diffTxt(end - 0:1) = '';
   
   
  close all % remove existing figures, else you get more and more if you retry
  figure % figure to show results of uni-variate data
  hold on % prepare for multiple plots in one figure

  t = linspace(0, 255, 100)';   % set independent variable for predictions (knowing that this applies to all tL-plots)
  colors = {[1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, 0]}; % colors for pet 1,.,4

  for i = 1:n_pets
    tWi = data.(pets{i}).tW;
    plot(tWi(:,1), tWi(:,2), '.', 'color', colors{i}, 'Markersize', 15);
    data.(pets{i}).tW = t;
    eval(['prdDatai = predict_', pets{i}, '(par.(pets{i}), data.(pets{i}), auxData.(pets{i}));']);
    tWi = prdDatai.tW;
    plot(t, tWi, '-', 'color', colors{i}, 'linewidth', 2);
  end 
 
  title('Data for CC, HH, CH, HC');
  text(10,900, shareTxt, 'Interpreter', 'none')
  text(10,850, diffTxt, 'Interpreter', 'none')
  xlabel([txtData.(pets{1}).label.tW{1}, ', ', txtData.(pets{i}).units.tW{1}]);
  ylabel([txtData.(pets{1}).label.tW{2}, ', ', txtData.(pets{i}).units.tW{2}]);   
  set(gca,'Fontsize',12, 'Box', 'on')
 
  print -dpng results_group.png
