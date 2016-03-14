%% cummax
% cumulative maxima of a sequence of numbers

%%
function xmax = cummax(x)
  % created at 2010/03/31 by Bas Kooijman
  
  %% Syntax
  % xmax = <../cummax.m *cummax*>(x)
  
  %% Description
  % computes cumulative maxima of a sequence of numbers
  %
  % Input
  %
  % * x: n-vector
  %
  % Output:
  %
  % * xmax: n-vector with cumulative maxima of x

  %% Example 
  % cummax([1 3 6 4 7 6])

  n = length(x); xmax = x;
  for i = 2:n
    xmax(i) = max(x(i), xmax(i-1));
  end
