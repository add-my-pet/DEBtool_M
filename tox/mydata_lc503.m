%% Script: 
% get LC50 as function of time using paramter values and then estimates
% paramters  from the LC50 as function of time

par = [1; .1; .01]; % set parameters
par_txt = {'nec'; 'killing rate'; 'elimination rate'};

t = [1; 5; 10]; % set three time point
LC50_t = lc50(par, t); % lc50 as function of time
par_0 = lc503([t, LC50_t], par + .5);
par_1 = lt503([LC50_t, t], par + 1.5);

[ par, par_0, par_1]