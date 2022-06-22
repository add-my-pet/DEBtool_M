function vi = boundConstraint (vi, pop, lu)

% if the boundary constraint is violated, set the value to be the middle
% of the previous value and the bound
%
% Version: 1.1   Date: 11/20/2007
% Written by Jingqiao Zhang, jingqiao@gmail.com

[NP, ~] = size(pop);  % the population size and the problem's dimension

%% check the lower bound
xl = repmat(lu(1, :), NP, 1);
pos = vi < xl;
% A random value between the difference between a parameter value and its
% its lower/upper bound is used to bound the constraint. 
% This mechanism is used to avoid havin always the same value for a
% parameter and to avoid unfeasible individuals when initialization ranges
% for calibration parameters are far from the initial (feasible) individual
% parameter values. 
vi(pos) = (pop(pos) + xl(pos)) / (rand() * (2.5 - 1.5) + 1.5);  

%% check the upper bound
xu = repmat(lu(2, :), NP, 1);
pos = vi > xu;
vi(pos) = (pop(pos) + xl(pos)) / (rand() * (2.5 - 1.5) + 1.5);