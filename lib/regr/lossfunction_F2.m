%% lossfunction_F2
% loss function 

%%
function [lf] = lossfunction_F2(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/06/06 by Goncalo Marques
  
  %% Syntax 
  % [lf] = <../lossfunction_F.m *lossfunction_F*>(data, meanData, prdData, meanPrdData, weights)
  
  %% Description
  % Calculates the loss function
  %   w' (d - p)^2/ (mean_d^2 + mean_p^2)
  % 
  %
  % Input
  %
  % * data: n-vector with all data
  % * meanData: n-vector with mean value of data per set 
  % * prdData: n-vector with predictions
  % * meanPrdData: n-vector with mean value of predictions per set 
  % * weights: n-vector with weights for the data
  %  
  % Output
  %
  % * lf: loss function value

  lf = weights' * ((data - prdData).^2 ./ (meanData.^2 + meanPrdData.^2));
  