function N = surv_count(n,S)
  %  created 2005/10/26 by Bas Kooijman
  %
  %% Description
  %  Obtains Monte Carlo counts for the number of surviving subjects, 
  %    from specified numbers of subjects (for each of nc conditions) and survivor probabilities (for each condition and nt time points). 
  %
  %% Input
  %  S: (r,c)-matrix with survivor probabilities
  %      interpretation: obs. times across rows, conditions across cols
  %  n: scalar, or (1,c)-matrix with number of test subjects
  %
  %% Output
  %  N: (r,c)-matrix with number of surviving subjects
  %
  %% Example of use
  %  using function fomort of tox: surv_count(10, fomort([1e-6 .1 1 .1], [0:7]',[0:2:10]')) 
  
  %% Code
  F = 1 - S; [nr nc] = size(F);
  nn = length(n);
  if nn == 1 % generate equal numbers of initial subjects
    n = n(ones(1,nc));
  elseif nn ~= nc % numbers of subjects should match numbers of concentrations
    printf('sizes do not match \n');
    N = [];
    return
  end
  
  N = zeros(nr + 1, nc); % initiate counting of deaths
  for j = 1:nc % concentrations
    for i = 1:n(j) % number of subjects
      rnd = rand(1); % random probability
      index = 1 + sum(rnd > F(:,j)); % determine cell in counts
      N(index,j) = N(index,j) + 1; % add dead subject to cell
    end
  end
  N = n(ones(nr+1,1),:) - cumsum(N,1); % convert death to survivors
  N(nr+1,:) = [];