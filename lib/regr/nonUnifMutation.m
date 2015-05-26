function [parent] = nonunifmutation(parent,bounds,Ops)
  %  Non uniform mutation changes one of the parameters of the parent
  %  based on a non-uniform probability distribution.  This Gaussian
  %  distribution starts wide, and narrows to a point distribution as the
  %  current generation approaches the maximum generation.
  % 
  %  function [newSol] = multiNonUnifMutation(parent,bounds,Ops)
  %  parent  - the first parent ( [solution string function value] )
  %  bounds  - the bounds matrix for the solution space
  %  Ops     - Options for nonUnifMutate[gen %NonUnifMutations maxGen b]

  %  C.R. Houck, J.Joines, and M.Kay. A genetic algorithm for function
  %  optimization: A Matlab implementation. ACM Transactions on Mathmatical
  %  Software, Submitted 1996. Modified by Bas Kooijman 2006/05/24

  cg = Ops(1); 				% Current Generation
  mg = Ops(3);                          % Maximum Number of Generations
  b = Ops(4);                           % Shape parameter
  df = bounds(:,2) - bounds(:,1); 	% Range of the variables
  numVar = size(bounds,1); 		% Get the number of variables
  %% Pick a variable to mutate randomly from 1 to number of vars
  mPoint = round(rand * (numVar - 1)) + 1;
  md = round(rand); 			% Choose a direction of mutation
  r = cg/ mg;
  if (r > 1)
    r = .99;
  end
  if md 			        % Mutate towards upper bound
    y = bounds(mPoint,2) - parent(mPoint);
    newValue = parent(mPoint) + y * (rand * (1 - r)) ^ b;
  else 					% Mutate towards lower bound
    y = parent(mPoint) - bounds(mPoint,1);
    newValue = parent(mPoint) - y * (rand * (1 - r)) ^ b;
  end
  parent(mPoint) = newValue; 		% Make the child


