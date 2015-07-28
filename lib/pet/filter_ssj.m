%% filter_ssj
% filters for allowable parameters of the ssj model 

%%
function [filter flag] = filter_ssj(par, chem)

[filter flag] = filter_std(par, chem);
