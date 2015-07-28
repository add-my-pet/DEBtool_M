%% results_my_pet
% presents results of univariate data graphically

%%
function results_my_pet(txt_par, par, chem, metapar, txt_data, data)

  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/04/12
  % modified 07/07/2015 by starrlight
  
  %% Syntax
  % <../results_my_pet.m *results_my_pet*>(txt_par, par, chem, metapar, txt_data, data)
  
  %% Description
  % present customized results of univariate data
  %
  % * inputs 
  %
  % * txt_par: text vector for the presentation of results
  % * par: structure with parameters (see below)
  % * chem: structure with biochemical parameters
  % * metapar: structure with field T_ref for reference temperature
  % * txt_data: text vector for the presentation of results
  % * data: structure with data
  
  %% Remarks
  % Called from estim_pars and printmat
  
  % get predictions
  Prd_data = data;              % copy data to Prd_data
  t = linspace(0, 650, 100)';   % set independent variable
  L = linspace(0.8, 5.2, 100)'; % set independent variable
  Prd_data.tL = t; % overwrite independent variable in tL
  Prd_data.LW = L; % overwrite independent variable in LW
  % overwrite Prd_data to obtain dependent variables
  [Prd_data] = predict_my_pet(par, chem, metapar.T_ref, Prd_data);
  % unpack data & predictions
  tL     = data.tL;     % data points first set
  LW     = data.LW;     % data points second set
  EL     = Prd_data.tL; % predictions (dependent variable) first set
  EW     = Prd_data.LW; % predictions (dependent variable) second set

  close all % remove existing figures, else you get more and more if you retry

  figure % figure to show results of uni-variate data
  set(gca,'Fontsize',12, 'Box', 'on')
  set(gcf,'PaperPositionMode','manual');
  set(gcf,'PaperUnits','points'); 
  set(gcf,'PaperPosition',[0 0 300 180]);%left bottom width height
         
  plot(t, EL, 'g', tL(:,1), tL(:,2), '.r', 'markersize', 20, 'linewidth', 2)
  xlabel([txt_data.label.tL{1}, ', ', txt_data.units.tL{1}])
  ylabel([txt_data.label.tL{2}, ', ', txt_data.units.tL{2}])
  
print -dpng results_my_pet_01.png
  
  figure % figure to show results of uni-variate data
  set(gca,'Fontsize',12, 'Box', 'on')
  set(gcf,'PaperPositionMode','manual');
  set(gcf,'PaperUnits','points'); 
  set(gcf,'PaperPosition',[0 0 300 180]);%left bottom width height

  plot(L, EW, 'g', LW(:,1), LW(:,2), '.r', 'markersize', 20, 'linewidth', 2)
  xlabel([txt_data.label.LW{1}, ', ', txt_data.units.LW{1}])
  ylabel([txt_data.label.LW{2}, ', ', txt_data.units.LW{2}])
 
print -dpng results_my_pet_02.png
