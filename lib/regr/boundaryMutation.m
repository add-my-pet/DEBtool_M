function [parent] = boundarymutation(parent, bounds, Ops)
  %  Boundary Mutation changes one of the parameters of the parent and
  %  changes it randomly either to its upper or lower bound. 
  %  
  %  function [newSol] = boundaryMutation(parent, bounds, Ops)
  %  parent  - the first parent ( [solution string function value] ) 
  %  bounds  - the bounds matrix for the solution space 
  %  Ops     - Options for boundaryMutation [gen %BndMutations] 

  %  Binary and Real-Valued Simulation Evolution for Matlab  
  %  Copyright (C) 1996 C.R. Houck, J.A. Joines, M.G. Kay C.R. Houck, J.Joines, and M.Kay. 
  %  A genetic algorithm for function optimization: 
  %  A Matlab implementation. ACM Transactions on Mathmatical Software, Submitted 1996. 
  %  Modified by Bas Kooijman 2006/05/24

  numVar = size(bounds, 1); 		% Get the number of variables
  %  Pick a variable to mutate randomly from 1-number of vars 
  mPoint = round(rand * (numVar - 1)) + 1;
  b = round(rand) + 1; 			% Pick which bound to move to
  newValue = bounds(mPoint, b); 	% Now mutate that point
  parent(mPoint) = newValue; 		% Make the child



