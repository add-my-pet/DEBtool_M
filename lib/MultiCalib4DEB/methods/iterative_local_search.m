function [ par, total_iter_count, best_fval ] = iterative_local_search( func, par, data, auxData, weights, filternm, period, best_fitness)
%ITERATIVE_LOCAL_SEARCH Iteratively runs a local search process
%   This funtion runs a local search process depending on: 
%   1) The step in which the local search process is launched:
%   1.1) At the beggining and through the calibration process (i.e.,
%   when refine_first and refine_running options are activated). The local 
%   search runs N times, where N is a random values in [1, 5]. If the
%   loss_function value does not improve, then the local search stops.
%   1.2) At the end of the calibration process (i.e., when refine_best
%   calibration option is activated). As 1.1, the local search runs until
%   the loss_function is no more improved but in this case, there is no
%   limit of N runs. 
%   2) The improvement in the loss_function quality (it is the case of the
%   1.2)).

% created 2021/09/27 by Juan Francisco Robles; 
% modified ...

max_runs = 1; % Maximum number of runs
best_fval = best_fitness; % The best fitness is equal to the received one

% Check when the local search is launched
if strcmp(period, 'beginning') || strcmp(period, 'running')
    if max_runs ~= 1
        num_runs = randi(max_runs); 
    else
        num_runs = max_runs;
    end
elseif strcmp(period, 'experimental')
    num_runs = 10;
else
    num_runs = 5;
end
    
% Stopping conditions  
improves = 1; 
runs_perf = 0;
total_iter_count = 0;

% Run the search
while(runs_perf < num_runs && improves)
    fprintf('Run %d of %d \n', runs_perf + 1, num_runs);
    fprintf('Prev loss function value %.4f \n', best_fval);
    [par, itercount, fval] = local_search(func, par, data, auxData, weights, filternm);
    total_iter_count = total_iter_count + itercount;
    if fval < best_fval
        fprintf('New loss function value %.4f \n', fval);
        best_fval = fval;
    else
        improves = 0;
    end
    runs_perf = runs_perf + 1;
end
end
