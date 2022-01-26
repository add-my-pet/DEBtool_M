%% lossfunction_re
% loss function 

%%
function lf = lossfunction_re(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/06/06 by Goncalo Marques, , modified 2022/01/25 by Bas Kooijman
  
  %% Syntax 
  % lf = <../lossfunction_re.m *lossfunction_re*>(func, par, data, auxData, weights, psdtrue)
  
  %% Description
  % Calculates the loss function
  %   w' (d - f)^2 / mean_d^2
  % used in the classical paper of Lika et al. 2011
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

  sel = ~isnan(data);
  lf = weights(sel)' * ((data(sel) - prdData(sel))./ meanData(sel)).^2;
  