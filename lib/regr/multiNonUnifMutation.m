function [parent] = multinonunifmutation(parent,bounds,Ops)
  % Multi-Non uniform mutation changes all of the parameters of the parent
  % based on a non-uniform probability distribution.  This Gaussian
  % distribution starts wide, and narrows to a point distribution as the
  % current generation approaches the maximum generation.
  %
  % function [newSol] = multiNonUnifMutate(parent,bounds,Ops)
  % parent  - the first parent ( [solution string function value] )
  % bounds  - the bounds matrix for the solution space
  % Ops     - Options for multiNonUnifMutation 
  %          [gen %MultiNonUnifMutations maxGen b]

  % C.R. Houck, J.Joines, and M.Kay. A genetic algorithm for function optimization: 
  % A Matlab implementation. ACM Transactions on Mathmatical Software, Submitted 1996. 
  % Modified by Bas Kooijman 2006/05/24

  cg = Ops(1); 				      % Current Generation
  mg = Ops(3); 				      % Maximum Number of Generations
  b = Ops(4);                     % Shape parameter
  df = bounds(:,2) - bounds(:,1); % Range of the variables
  numVar = size(bounds,1); 		  % Get the number of variables
  % Now mutate that point
  md = round(rand(1,numVar));
  r = cg/ mg;
  if (r > 1)
    r = .99;
  end
  for i = 1:numVar
    if md(i)
      y = bounds(i,2) - parent(i);
      parent(i) = parent(i) + y * (rand * (1 - r)) ^ b;
    else
      y = parent(i) - bounds(i,1);
      parent(i) = parent(i) - y * (rand * (1 - r)) ^ b;
    end
  end
