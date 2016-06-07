%% lossfunction_E
% loss function 

%%
function [lf] = lossfunction_E(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/06/06 by Goncalo Marques
  
  %% Syntax 
  % [lf] = <../lossfunction_E.m *lossfunction_E*>(func, par, data, auxData, weights, psdtrue)
  
  %% Description
  % Calculates the loss function
  %   w' (d - f)^2 / mean_d^2
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

  lf = weights' * ((data - prdData)./ meanData).^2;
  