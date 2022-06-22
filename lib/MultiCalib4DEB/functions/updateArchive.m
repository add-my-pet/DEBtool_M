function result = updateArchive(result, pop, funvalue)
% Update the archive with input solutions
%   Step 1: Add new solution to the archive
%   Step 2: Remove duplicate elements
%   Step 3: If necessary, randomly remove some solutions to maintain the archive size
%
% Version: 1.1   Date: 2008/04/02
% Written by Jingqiao Zhang (jingqiao@gmail.com)

format long; 

if result.numSolutions == 0, return; end
if size(pop, 1) ~= size(funvalue,1), error('check it'); end

% Method 2: Remove duplicate elements
popAll = [result.solutionsParameters; pop ];
funvalues = [result.lossFunctionValues; funvalue ];
[~, IX]= unique(popAll, 'rows');

if length(IX) < size(popAll, 1) % There exist some duplicate solutions
   popAll = popAll(IX, :);
   funvalues = funvalues(IX, :);
end

if size(popAll, 1) <= result.numSolutions   % add all new individuals
   result.solutionsParameters = popAll;
   result.lossFunctionValues = funvalues;
else                % randomly remove some solutions
   rndpos = randperm(size(popAll, 1)); % equivelent to "randperm";
   rndpos = rndpos(1 : result.numSolutions);
  
   result.solutionsParameters = popAll(rndpos, :);
   result.lossFunctionValues = funvalues(rndpos, :);
end