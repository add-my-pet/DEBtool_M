%% mydata_fsolve

[x, val, info] = fsolve('tryout', 100, .3)


[x, val, info] = fzero('tryout', 100, [], .3)