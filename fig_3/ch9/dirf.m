%% fig:dirf
%% out: dflotka,dfmonod,dfmarr,dfdroop,dfdeb

global xr jXm Yg g ld

%% parameter settings
  xr = 10; % conc substrate in the feed
  Yg = .85;% yield of biomass on substrate
  jXm = 3; % max spec uptake rate
  g = 1;   % investment ratio
  ld = .1; % scaled length at division

xy_lotka = [1/(Yg * jXm); xr * Yg - 1/ jXm];
x_lotka = xy_lotka(1) * (.1:.2:1.9)'; 
y_lotka = xy_lotka(2) * (.1:.2:1.9)'; 
y0_lotka = [xy_lotka(1), 0; xy_lotka(1), 2 * xy_lotka(2)];
x = xy_lotka(1) * linspace(.1, 2, 100)';
x0_lotka = [x, (xr - x) ./ (jXm * x)];
df_lotka = dirfield('dlotka', x_lotka, y_lotka, .003);
	    
f = 1/(jXm * Yg); xy_monod = [f/(1-f); (xr - f/(1-f))/(jXm *f)];
x_monod = xy_monod(1) * (.1:.2:1.9)'; 
y_monod = xy_monod(2) * (.1:.2:1.9)'; 
y0_monod = [xy_monod(1), 0; xy_monod(1), 2 * xy_monod(2)];
x = xy_monod(1) * linspace(.1, 2, 100)';
x0_monod = [x, (xr - x) ./ (jXm * x ./ (1 + x))];
df_monod = dirfield('dmonod', x_monod, y_monod, .005);


f = ld + 1/(jXm * Yg); xy_marr = [f/(1-f); (xr - f/(1-f))/(jXm *f)];
x_marr = xy_marr(1) * (.1:.2:1.9)'; 
y_marr = xy_marr(2) * (.1:.2:1.9)'; 
y0_marr = [xy_marr(1), 0; xy_marr(1), 2 * xy_marr(2)];
x = xy_marr(1) * linspace(.1, 2, 100)';
x0_marr = [x, (xr - x) ./ (jXm * x ./ (1 + x))];
df_marr = dirfield('dmarr', x_marr, y_marr, .01);


f = g /(jXm * Yg * g - 1); xy_droop = [f/(1-f); (xr - f/(1-f))/(jXm *f)];
x_droop = xy_droop(1) * (.1:.2:1.9)'; 
y_droop = xy_droop(2) * (.1:.2:1.9)'; 
y0_droop = [xy_droop(1), 0; xy_droop(1), 2 * xy_droop(2)];
x = xy_droop(1) * linspace(.1, 2, 100)';
x0_droop = [x, (xr - x) ./ (jXm * x ./ (1 + x))];
df_droop = dirfield('ddroop', x_droop, y_droop, .02);


f = (jXm * Yg * g * ld + g) / (jXm * Yg * g - 1);  
xy_deb = [f/(1-f); (xr - f/(1-f))/(jXm *f)];
x_deb = xy_deb(1) * (.1:.2:1.9)'; 
y_deb = xy_deb(2) * (.1:.2:1.9)'; 
y0_deb = [xy_deb(1), 0; xy_deb(1), 2 * xy_deb(2)];
x = xy_deb(1) * linspace(.1, 2, 100)';
x0_deb = [x, (xr - x) ./ (jXm * x ./ (1 + x))];
df_deb = dirfield('ddeb', x_deb, y_deb, .05);

subplot(2,3,1);
plot_vector(df_lotka, '-r');
plot(y0_lotka(:,1), y0_lotka(:,2), '-b', ...
     x0_lotka(:,1), x0_lotka(:,2), '-b', ...
    [0, xy_lotka(1)], xy_lotka([2 2]), '-k')
title('Lotka-Volterra')
%% set xtics .2
%% set ytics 5
axis([0, .784 0 16.333])
%% set label 'x_0' at .39, - 1 center
%% set label 'y_0' at -.08, 8.2 center

subplot(2,3,2);
plot_vector(df_monod, '-r')
plot(y0_monod(:,1), y0_monod(:,2), '-b', ...
     x0_monod(:,1), x0_monod(:,2), '-b', ...
    [0, xy_monod(1)], xy_monod([2 2]), '-k')
title('Monod')
%% set xtics .3
%% set ytics 5
axis([0:1.29 0 15.9])
%% set label 'x_0' at .645, - .8 center
%% set label 'y_0' at -.1, 7.95 center

subplot(2,3,3);
plot_vector(df_marr, '-r')
plot(y0_marr(:,1), y0_marr(:,2), '-b', ... 
     x0_marr(:,1), x0_marr(:,2), '-b', ...
    [0, xy_marr(1)], xy_marr([2 2]), '-k')
title('Marr-Pirt')
%% set xtics .4
%% set ytics 4
axis([0 1.94 0 12.23]);
%% set label 'x_0' at .97, - .6 center
%% set label 'y_0' at -.12, 6.12 center

subplot(2,3,5);
plot_vector(df_droop, '-r')
plot(y0_droop(:,1), y0_droop(:,2), '-b', ...
     x0_droop(:,1), x0_droop(:,2), '-b', ...
    [0, xy_droop(1)], xy_droop([2 2]), '-k')
title('Droop')
%% set xtics .8
%% set ytics 3;
axis([0 3.64 0 8.45])
%% set label 'x_0' at 1.82, - .35 center
%% set label 'y_0' at -.26, 4.23 center

subplot(2,3,6);
plot_vector(df_deb, '-r')
plot(y0_deb(:,1), y0_deb(:,2), '-b', ...
     x0_deb(:,1), x0_deb(:,2), '-b', ...
    [0, xy_deb(1)], xy_deb([2 2]), '-k')
title('DEB')
%% set xtics 2
%% set ytics 1
axis([0 8.51 0 4.73])
%% set label 'x_0' at 4.25, - .22 center
%% set label 'y_0' at -1.05, 2.37 center
