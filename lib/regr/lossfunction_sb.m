%% lossfunction_sb
% loss function "symmetric bounded"

%%
function lf = lossfunction_sb(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/06/06 by Goncalo Marques, modified 2022/01/25 by Bas Kooijman
  
  %% Syntax 
  % lf = <../lossfunction_sb.m *lossfunction_sb*>(data, meanData, prdData, meanPrdData, weights)
  
  %% Description
  % Calculates the loss function
  %   w' (d - f)^2/ (mean_d^2 + mean_f^2)
  % multiplicative symmetric bounded 
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

  sel = ~isnan(data);
  lf = weights(sel)' * ((data(sel) - prdData(sel)).^2 ./ (meanData(sel).^2 + meanPrdData(sel).^2));
  
  