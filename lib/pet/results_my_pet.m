%% results_my_pet
% presents results of univariate data graphically

%%
function results_my_pet(txt_par, par, chem, metapar, txt_data, data)
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/04/12

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
  subplot(1,2,1)
  plot(t, EL, 'g', tL(:,1), tL(:,2), '.r', 'markersize', 20, 'linewidth', 4)
  set(gca, 'Fontsize', 15, 'Box', 'on')
  xlabel('time since birth, d')
  ylabel('snout-to-vent length, cm')
  %print -dpng results_my_pet_01.png
  
  subplot(1,2,2)
  plot(L, EW, 'g', LW(:,1), LW(:,2), '.r', 'markersize', 20, 'linewidth', 4)
  set(gca, 'Fontsize', 15, 'Box', 'on')
  xlabel('snout-to-vent length, cm')
  ylabel('wet weight, g')
  %print -dpng results_my_pet_02.png
