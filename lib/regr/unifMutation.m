function [parent] = unifmutation(parent,bounds,Ops)
  % Uniform mutation changes one of the parameters of the parent
  % based on a uniform probability distribution.
  %
  % function [newSol] = multiNonUnifMutation(parent,bounds,Ops)
  % parent  - the first parent ( [solution string function value] )
  % bounds  - the bounds matrix for the solution space
  % Ops     - Options for uniformMutation [gen %UnifMutations]

  % Binary and Real-Valued Simulation Evolution for Matlab 
  % Copyright (C) 1996 C.R. Houck, J.A. Joines, M.G. Kay 
  %
  % C.R. Houck, J.Joines, and M.Kay. A genetic algorithm for function
  % optimization: A Matlab implementation. ACM Transactions on Mathmatical
  % Software, Submitted 1996. Modified by Bas Kooijman 2006/05/24

  df = bounds(:,2) - bounds(:,1); 	% Range of the variables
  numVar = size(bounds,1); 		% Get the number of variables 
  %% Pick a variable to mutate randomly from 1-number of vars
  mPoint = round(rand * (numVar-1)) + 1;
  newValue = bounds(mPoint,1)+rand * df(mPoint); %% Now mutate that point
  parent(mPoint) = newValue; 		% Make the child


