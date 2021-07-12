%% char_su
% characteristic value based on minimazation of loss function F_su
%%

function val = char_su(data)
% created 2021/07/12 by Bas Kooijman

%% Syntax
% val = <../char_su.m *char_su*> (data) 

%% Description
% computes a characteristic value based on minimazation of loss function F_su.
% Loss function F_su is defined as F_Su = (val - data).^2 ./ (val.^2 + data.^2)' * weights.
% The minimum is found from d/d val F_su = 0
%
% Input:
%
% * data: (n,1 or 2)-array of data values with optional weights in second column (default ones)
%
% Output:
%
% * val: characteritic value (i.e. a kind of mean or median)

%% Example of use
% x=normrnd(12,10,[10,1]); [mean(x) median(x) char_su(x)]

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
  dFsu = @(val, data, weights) ((val - data)./(val^2 + data.^2) - val * (val - data).^2./(val^2 + data.^2).^2)' * weights;
  val = fzero(@(val) dFsu(val, data, weights), val); % characteristic value

