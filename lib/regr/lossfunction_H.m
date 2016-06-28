%% lossfunction_H
% loss function 

%%
function [lf] = lossfunction_H(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/06/06 by Goncalo Marques
  
  %% Syntax 
  % [lf] = <../lossfunction_H.m *lossfunction_H*>(func, par, data, auxData, weights, psdtrue)
  
  %% Description
  % Calculates the loss function
  %   w' sqrt((d - f)^2/ (mean_d^2 + mean_f^2))
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

  F = ((data - prdData).^2 ./ (meanData.^2 + meanPrdData.^2));
  G = F./ (1 - F);
  lf = weights' * (G.^(1/2));
  