%  Created at 2002/02/15 by Bas Kooijman
% Toxic effects on growth; three modes of action
%    asgrowth: assimilation capacity
%    magrowth: maintenance costs
%    grgrowth: growth costs
%  Example of DEBtox:

t = 36; % d; exposure time
c = [0 0 5.6 10 18 32 56 100]'; % mug/l sodium pentachlorophenate
L = [1.408 1.412 1.392 1.391 1.332 1.285 1.074 0.958]; % cm, body length

shregr2_options('plotnr',2);
shregr2_options('xlabel','mug/l sodium pentachlorophenate');
shregr2_options('ylabel','body length, cm');

% effects via assimilation
par = [1.25 1  0 5; 286 1 1 500; 10 0 1e-4 300; 3.7 0 0 0;
       .01 0 0 0; 0.4 0 0 0; 1.0 0 0 0];
p_as = nrregr2('asgrowth',par,t,c,L);
par = [1.25 1  0 5; 286 1 0 1e7; 0 0 0 300; 3.7 0 0 0;
       .01 0 0 0; 0.4 0 0 0; 1.0 0 0 0];
p_asi = nrregr2('asigrowth',par,t,c,L);
par = [6 1  0 5; 1.1e4 1 0 1e7; 10 0 0 0; 3.7 0 0 0;
       .01 0 0 0; 0.4 0 0 0; 1.0 0 0 0];
p_as0 = nrregr2('as0growth',par,t,c,L);

shregr2('asgrowth',p_as,t,c,L);

C = linspace(0,100,50)';


plot(C,as0growth(p_as0(:,1),t,C), 'g', C,asigrowth(p_asi(:,1),t,C), 'm');
[cov cor sd] = pregr2('asgrowth',p_as,t,c,L);

% % effects via maintenance
% par = [9 1 .1 10; 44 1 1 50; 39 1 1 50; 3.7 0 0 0;.01 0 0 0;
%       0.4 0 0 0; 1.0 0 0 0];
% p = nmregr2('magrowth',par,t,c,L);
% shregr2('magrowth',par,t,c,L);
% [cov cor sd] = pregr2('magrowth',p,t,c,L);
% 
% % effects on growth directly
% par = [9.16 3.76 1 3.71 .1 0.001 0.4 1; 1 1 0 0 0 0 0 0]';
% p = nmregr2('grgrowth',par,t,c,L);
% shregr2('grgrowth',par,t,c,L);
% [cov cor sd] = pregr2('grgrowth',p,t,c,L);
