function xy =  surv (z,z0)
  %  created at 2002/04/19 by Bas Kooijman
  %
  %% Description
  %  calculates coordinates of the survivor function
  %
  %% Input
  %  z: n-vector with i.i.d. non-negative random trials
  %  z0: scalar with minimum value of possible trial
  %
  %% Output
  %  xy: (2n,2) or (1+2n,2)-matrix with coordinates
  %
  %% Remarks
  %   cf surv_chi the survivor probability of the Chi-square distribution
  %
  %% Example of use
  %  survi_chi(2, [.6 .8 .9]) or survi_chi(2,surv_chi(2, [3 4 6.5]))
  
  %% Code

  z = sort(z(:)); % first make a column vector of input matrix
  n = length(z);  % number of random trials
  y = (n:-1:1)/n; 
  y = reshape([y;y], 2*n, 1);
  x = reshape([z,z]',2*n, 1);
  if exist('z0')==1
    xy = [[z0;x], [y;0]];   % for random variables on (z0, infty)
  else
    xy =[x, [y(2:2*n);0]]; % for random variables on (-infty, infty)
  end

  %% plot(xy(:,1), xy(:,2),'g'); %% this is how you plot the survivor function