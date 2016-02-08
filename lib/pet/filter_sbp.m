%% filter_sbp
% filters for allowable parameters of standard DEB model without acceleration; growth ceasing at puberty
% same at std model

function [filter, flag] = filter_sbp(p)
[filter, flag] = filter_std(p);