%% pca2
% prinple component anamysis for univariate data

%%
function [slope, y_LH] = pca2(data, xlim, trans)
  % created: 2019/09/22 by Bas Kooijman
  
  %% Syntax 
  % [slope, y_LH] = <../PC2.m *pca2*>(data, xlim, trans)
  
  %% Description
  % Calculates principle components for univariate data
  %
  % Input
  %
  % * data: (n,2) array with data
  % * xlim: low and high boundaries of x-range
  % * trans: optional (2,1) array with booleans for log10 transformation (default [0;0])
  %  
  % Output
  %
  % * slope: scalar with slope
  % * y_LH: (2,1) array with y-values at xlim for first principle component
  
  %% Remarks
  % If trans(1) is true, xlim relates to the log10-transformed values
  % if trans(2) is true, y_LH relates to the log10-transformed values
  
  if ~exist('trans','var')
    trans = [0; 0];
  end
    
  data = data(~isnan(data(:,2)),:);
  if trans(1)
    data(:,1) = log10(data(:,1));
  end
  if trans(2)
    data(:,2) = log10(data(:,2));
  end
  
  M = mean(data); % mean x, y  
  coeff = pca(data); % eigen vectors in columns
  slope = coeff(2,1)/ coeff(1,1);
  y_LH = M(2) + (xlim(:) - M(1)) * slope;
  
  