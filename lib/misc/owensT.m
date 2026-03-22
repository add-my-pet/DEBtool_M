%% owensT(h, a)
% Calculates Owen's T function

%%
function T = owensT(h, a)
  % created 2026/03/20 by Bas Kooijman
  
  %% Syntax
  % T = <../owensT.m *owensT*> (h, a)

  %% Description
  %  Calculates Owen's T function
  %
  % Input:
  %
  % * h: (n,1)-vector with arguments
  % * a: scalar with parameter
  %
  % Output:
  %
  % * T: (n,1)-vector owens T function values
  
  %% Example of use
  % owensT(1:3, .5)

  n = length(h); T = NaN(n,1);
  for i = 1:n
    integrand = @(x) exp(-0.5 * (h(i)^2) * (1 + x.^2)) ./ (1 + x.^2);
    T(i) = integral(integrand, 0, a)/ (2 * pi);
  end
end
