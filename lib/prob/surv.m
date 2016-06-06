%% surv
% calculates coordinates of the survivor function for plotting

%%
function xy =  surv (z,z0)
  % created at 2002/04/19 by Bas Kooijman

  %% Syntax
  % xy = <../surv.m *surv*> (z,z0)

  %% Description
  % Calculates coordinates of the survivor function for plotting
  %
  % Input
  %
  % * z: n-vector with i.i.d. non-negative random trials
  % * z0: scalar with minimum value of possible trial
  %
  % Output:
  %
  % * xy: (2n,2) or (1+2n,2)-matrix with coordinates
  
  %% Remarks
  % cf surv_chi the survivor probability of the Chi-square distribution
  
  %% Example of use
  % xy = surv([3 8 2],); or xy = surv(randn(10)); or xy = surv(rand(5)).
  % Plot it with plot(xy(:,1),xy(:,2),'g'). 
  
  z = sort(z(:)); % first make a column vector of input matrix
  n = length(z);  % number of random trials
  y = (n:-1:1)/n; 
  y = reshape([y;y], 2*n, 1);
  x = reshape([z,z]',2*n, 1);
  if exist('z0','var')
    xy = [[z0;x], [y;0]];   % for random variables on (z0, infty)
  else
    xy =[x, [y(2:2*n);0]]; % for random variables on (-infty, infty)
  end
  
  %% plot(xy(:,1), xy(:,2),'g'); %% this is how you plot the survivor function