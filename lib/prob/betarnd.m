%% betarnd
% generates random trials from a beta distribution

function x = betarnd(alpha,beta,r,c)
  % created 2023/02/20 by Bas Kooijman
  
  %% Syntax
  % x = <../betarnd.m *betarnd*> (alpha,beta,r,c)

  %% Description
  % generates random trials from the beta distribution:
  %    pdf(x)=x^(alpha-1)(1-x)^(beta-1)/ B(alpha, beta); 
  %
  % Input:
  %
  % * alpha: scalar with scale parameter
  % * beta: scalar with scale parameter
  % * r: optional scalar with number of rows of output (default 1)
  % * c: optional scalar with number of columns of output (default 1)
  %
  % Output:
  %
  % * x: (r,c)-matrix with random trials from a beta distribution
  
  %% Remarks
  % estimate parameters of the beta distribution with betaML;
  % dim(alpha) = 0 and dim(beta) = 0.
  
  %% Example of use
  % betarnd(2,4,5,6)

  if ~exist('r','var')
    r = 1;
  end
  if ~exist('c','var')
    c = 1;
  end

  % Generate gamma-distributed random values, and transform to beta-distributed ones
  X = gammarnd(1,alpha,r,c); Y = gammarnd(1,beta,r,c); x = X ./ (X + Y); 

  
end