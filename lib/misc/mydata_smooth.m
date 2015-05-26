%% example of the use of smoothing functions:
%%   interpolation, roots, extremes, integration, derivation, second derivation

%% set data for period 365 d
  ty = [...
    0.00000     9.66;
   30.41667     9.06;
   60.83333    28.86;
   91.25000    70.21;
  121.66667    50.62;
  152.08333    37.87;
  182.50000    37.36;
  212.91667    38.82;
  243.33333    35.34;
  273.75000    38.73;
  304.16667    32.81;
  334.58333    16.85;
  365.00000     9.66];

t = linspace(0,365,100)'; % time points for evaluation
fr = 38; % function value to solve x from f(x) = fr

%% spline1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fs1, dfs1] = spline1(t, ty); % function values and derivative
ifs1 = ispline1(t, ty); % integration

ts1_fr = rspline1(ty,0,0,fr); % roots of f(x) = fr;
[ts1_min, ts1_max] = espline1(ty); % extremes

%% spline, here natural spline. Can also be clamped %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fs, dfs, ddfs] = spline(t, ty); % function values and derivatives
ifs = ispline(t, ty); % integration

%ts_fr = rspline(ty,[],[],fr); % roots of f(x) = fr;
%[ts_min, ts_max] = espline(ty); % extremes
ts_fr = 0; ts_min = 0; ts_max = 0;

%% fnfourier for periodic functions; derivative at start and end period are equal %%%%%%%%%%%%

%% get Fourier coefficients with 4 terms, s0 1 + 2 * 4 = 9 pars
p = get_fourier(365, 4, ty); % 365 = period (days), 

ff = fnfourier(t, p);  % function values
dff = dfnfourier(t,p); % derivative
ddff = ddfnfourier(t,p); % second derivative
iff = ifnfourier(t,p);  % integral

%tf_fr = rfnfourier(p,fr); % roots for f(t) = fr;
%[tf_min, tf_max] = efnfourier(p); % extremes
tf_fr = 0; tf_min = 0; tf_max = 0;

%% plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2,3,1)
plot(ty(:,1), ty(:,2), '*k', t, fs1, 'b', ...
    [0;365], [fr;fr], 'm', ts1_fr, fr + 0 * ts1_fr, 'om', ...
    ts1_min(:,1), ts1_min(:,2), '+b', ts1_max(:,1), ts1_max(:,2),'+r')
xlabel('independent var')
ylabel('dependent var')
title('first order spline')

subplot(2,3,2)
plot(ty(:,1), ty(:,2), '*k', t, fs, 'r', ...
    [0;365], [fr;fr], 'm', ts_fr, fr + 0 * ts_fr, 'om', ...
    ts_min(:,1), ts_min(:,2), '+b', ts_max(:,1), ts_max(:,2),'+r')
xlabel('independent var')
ylabel('dependent var')
title('cubic spline')

subplot(2,3,3)
plot(ty(:,1), ty(:,2), '*k', t, ff, 'g', ...
    [0;365], [fr;fr], 'm', tf_fr, fr + 0 * tf_fr, 'om', ...
    tf_min(:,1), tf_min(:,2), '+b', tf_max(:,1), tf_max(:,2),'+r')
xlabel('independent var')
ylabel('dependent var')
title('Fourier series')

subplot(2,3,4)
plot(t, ifs1, 'b', t, ifs, 'r', t, iff,'g')
xlabel('independent var')
ylabel('integrated')

subplot(2,3,5)
plot(t, dfs1, 'b', t, dfs, 'r', t, dff, 'g')
xlabel('independent var')
ylabel('derivative')

subplot(2,3,6)
plot([0; 365], [0;0], 'b', t, ddfs, 'r', t, ddff, 'g')
xlabel('independent var')
ylabel('second deribative')


