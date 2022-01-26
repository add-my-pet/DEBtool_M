%% lossfunction_su
% loss function "symetric unbounded"

%%
function lf = lossfunction_su(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/08/23 by Goncalo Marques, modified 2022/01/25 by Bas Kooijman
  
  %% Syntax 
  % lf = <../lossfunction_su.m *lossfunction_su*>(func, par, data, auxData, weights, psdtrue)
  
  %% Description
  % Calculates the loss function
  %   w' ((d - p)^2 (1/ mean_d^2 + 1/ mean_p^2))
  % multiplicative symmetric unbounded 
  %
  % Input
  %
  % * data: vector with data
  % * meanData: vector with mean value of data per set
  % * prdData: vector with predictions
  % * meanPrdData: vector with mean value of predictions per set
  % * weights: vector with weights for the data
  %  
  % Output
  %
  % * lf: loss function value

  sel = ~isnan(data);
  lf = weights(sel)' * ((data(sel) - prdData(sel)).^2 .*(1./ meanData(sel).^2 + 1./ meanPrdData(sel).^2));
  