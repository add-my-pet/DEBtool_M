%% char_sb
% characteristic value based on minimazation of loss function F_sb
%%

function [val, info] = char_sb(data)
% created 2021/07/12 by Bas Kooijman

%% Syntax
% [val, info] = <../char_sb.m *char_sb*> (data) 

%% Description
% computes a characteristic value based on minimazation of loss function F_sb.
% Loss function F_sb is defined as F_sb = (val - data).^2 ./ (val.^2 + data.^2)' * weights.
% The minimum is found from d/d val F_sb = 0
%
% Input:
%
% * data: (n,1 or 2)-array of data values with optional weights in second column (default ones)
%
% Output:
%
% * val: characteritic value (i.e. a kind of mean or median)
% * info: scalar with success (1) or failure (0) 

%% Example of use
% x=randN(10); [mean(x) median(x) char_sb(x) char_su(x)]

  % weights
  if size(data,2) == 2
    weights = data{:,2}; data = data(:,1); 
  else % size(data,2) == 1
    weights = ones(length(data),1);
  end
  
  if all(data == 0)
    val = 0; return
  end
      
  val = data' * weights/ sum(weights); % initial value (= weighted mean)
  dFsb = @(val, data, weights) ((val - data)./(val^2 + data.^2) - val * (val - data).^2./(val^2 + data.^2).^2)' * weights;
  [val, ~, info] = fzero(@(val) dFsb(val, data, weights), val); % characteristic value
  info = (info == 1);

