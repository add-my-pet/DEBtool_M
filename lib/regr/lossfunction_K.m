%% lossfunction_K
% loss function 

%%
function [lf] = lossfunction_K(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/08/23 by Goncalo Marques
  
  %% Syntax 
  % [lf] = <../lossfunction_K.m *lossfunction_K*>(func, par, data, auxData, weights, psdtrue)
  
  %% Description
  % Calculates the loss function
  %   w' ((d - f)^2/ mean_d^2 + (1/d - 1/f)^2 * mean_d^2)
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

  lf = weights' * ((data - prdData).^2 ./ meanData.^2 + (1./data - 1./prdData).^2 .* meanData.^2);
  