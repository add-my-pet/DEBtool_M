par = [1; .1; .01];
t = [1; 5; 10];
LC50_t = lc50(par, t);
par_0 = lc503([t, LC50_t], par);
par_1 = lt503([LC50_t, t], par);

[par, par_0, par_1]