function vi = boundConstraint (vi, pop, lu, par_best)

% if the boundary constraint is violated, set the value to be the middle
% of the previous value and the bound
%
% Version: 1.1   Date: 11/20/2007
% Written by Jingqiao Zhang, jingqiao@gmail.com

[NP, D] = size(pop);  % the population size and the problem's dimension

%% check the lower bound
xl = repmat(lu(1, :), NP, 1);
xbest = repmat(par_best(1, :), NP, 1);
pos = vi < xl;
vi(pos) = xbest(pos) + pop(pos) / 2;
%vi(pos) = (pop(pos) + xl(pos)) / 2;
%vi(pos) = xl(pos);
%% check the upper bound
xu = repmat(lu(2, :), NP, 1);
pos = vi > xu;
vi(pos) = xbest(pos) + pop(pos) / 2;
%vi(pos) = (pop(pos) + xu(pos)) / 2;
%vi(pos) = xu(pos);