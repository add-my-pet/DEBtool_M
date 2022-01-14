% created at 2002/02/05 by Bas Kooijman
% script-file that illustrates the use of lc50

tc = [1 2 3 4 5 6 7; 50 30 20 15 12 10 9]';

p = nmregr('lc50',[9 0.3 0.5]', tc);
[cov, cor, sd] = pregr('lc50',p, tc);
[p, sd]
shregr('lc50',p,tc);