%% lossfunction_J2
% loss function 

%%
function [lf] = lossfunction_J2(data, meanData, prdData, meanPrdData, weights)
  % created: 2016/08/23 by Goncalo Marques
  
  %% Syntax 
  % [lf] = <../lossfunction_J2.m *lossfunction_J2*>(func, par, data, auxData, weights, psdtrue)
  
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
  
  nrPsd = 6;
  mreMin = 0.1;
  lfMin = 0.6;
  
  datawopsd = data(1:end-nrPsd);
  prdDatawopsd = prdData(1:end-nrPsd);
  meanDatawopsd = meanData(1:end-nrPsd);
  meanPrdDatawopsd = meanPrdData(1:end-nrPsd);
  weightswopsd = weights(1:end-nrPsd);

  lf = weightswopsd' * ((datawopsd - prdDatawopsd).^2 .*(1./ meanDatawopsd.^2 + 1./ meanPrdDatawopsd.^2));
  
  mre = weightswopsd' * (abs(prdDatawopsd - datawopsd)./ meanDatawopsd);
  mre = mre/ sum(weightswopsd);
  
%   if mre < mreMin
  if mre < mreMin
    psd = data(end-nrPsd+1:end); meanPsd = psd;
    prdPsd = prdData(end-nrPsd+1:end); meanPrdPsd = prdPsd;
    weightsPsd = weights(end-nrPsd+1:end);
    
    lfpsd = weightsPsd' * ((psd - prdPsd).^2 .*(1./ meanPsd.^2 + 1./ meanPrdPsd.^2));
%     lf = lf + (mreMin - mre) * lfpsd;
    lf = lf + (lfMin - lf) * lfpsd;
   end
  
  