%% lossfunction_SMAE
% loss function "Symmetric Mean Absolute Error"

%%
function lf = lossfunction_SMAE(data, meanData, prdData, meanPrdData, weights)
  % created: 2022/01/19 by Bas Kooijman, modified 2022/01/25 by Bas Kooijman
  
  %% Syntax 
  % lf = <../lossfunction_SMAE.m *lossfunction_SMAE*>(data, prdData, weights)
  
  %% Description
  % Calculates the loss function: Symmetric Mean Absolute Error
  %   2 w' (|d - p|)/ (|d| + |p|)
  %
  % Input
  %
  % * data: vector with (dependent) data
  % * meanData: vector with mean value of data per set 
  % * prdData: vector with predictions
  % * meanPrdData: vector with mean value of predictions per set
  % * weights: vector with weights for the data
  %  
  % Output
  %
  % * lf: loss function value
  
  %% Remarks
  % Inputs meanData and meanPrdData are not used; 
  % only there for consistency with other lossfunctions

  sel = ~isnan(data);
  lf = 2 * weights(sel)' * (abs(data(sel) - prdData(sel)) ./ (abs(data(sel)) + abs(prdData(sel))));
  