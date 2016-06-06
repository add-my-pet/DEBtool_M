%% lik2surv
% Translates values of -2 log lik ratio to survivor prob

%%
function s = lik2surv (l,nu)
  
  %% Syntax
  % s = <../lik2surv.m *lik2surv*> (l,nu)

  %% Description
  % Translates values of -2 log lik ratio to survivor prob on the assumption that 
  %  the lower and upper tail probabilities are equal and the log lik-values follow a (distorted) parabola.
  %  These ratio's must monotoneously decrease to zero, and then monotoneously increase. 
  %
  % Input
  %
  % * l: (n,1)-matrix with -2 log lik ratio values;
  %      one log lik value must be 0
  % * nu: scalar with degrees of freedom of Chi-square distribution
  %
  % Output:
  %
  % * s: (n,1)-matrix with values for survivor function
  
  %% Example of use
  % lik2surv([3 2 1 0 .3 .6 1 2]',1)
  
  s = surv_chi(l,nu);
  [lmin nm] = min(l);
  nl = length(l);
  s(nm:nl)  = 0.5 * (1 - s(nm:nl));
  s(1:nm-1) = 0.5 * (1 + s(1:nm-1));
