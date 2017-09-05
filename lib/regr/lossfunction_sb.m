%% lossfunction_sb
% loss function "symetric bounded"

%%
function [lf] = lossfunction_sb(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/06/06 by Goncalo Marques
  
  %% Syntax 
  % [lf] = <../lossfunction_sb.m *lossfunction_sb*>(func, par, data, auxData, weights, psdtrue)
  
  %% Description
  % Calculates the loss function
  %   w' (d - f)^2/ (mean_d^2 + mean_f^2)
  % multiplicative symmetric bounded 
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

  lf = weights' * ((data - prdData).^2 ./ (meanData.^2 + meanPrdData.^2));
  