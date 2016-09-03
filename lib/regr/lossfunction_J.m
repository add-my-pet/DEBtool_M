%% lossfunction_J
% loss function 

%%
function [lf] = lossfunction_J(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/08/23 by Goncalo Marques
  
  %% Syntax 
  % [lf] = <../lossfunction_J.m *lossfunction_J*>(func, par, data, auxData, weights, psdtrue)
  
  %% Description
  % Calculates the loss function
  %   w' ((d - f)^2 (1/ mean_d^2 + 1/ mean_f^2))
  %
  % Input
  %
  % * data: vector with data
  % * meanData: vector with mean value of data per set
  % * prdData: vectod with predictions
  % * meanPrdData: vector with mean value of predictions per set
  % * weights: vector with weights for the data
  %  
  % Output
  %
  % * lf: loss function value

  lf = weights' * ((data - prdData).^2 .*(1./ meanData.^2 + 1./ meanPrdData.^2));
  