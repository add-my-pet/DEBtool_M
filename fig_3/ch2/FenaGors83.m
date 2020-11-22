%% fig:FenaGors83
%% bib:FenaGors83
%% out:FenaGors83,FenaGors83w

%% lengths and dry weight at age (d) of Oikopleura longicauda

%% age (d); true trunk length; total trunk length (mum); dry weight (mug)
aLRW = [7.20833  599.99958 1060.00034 45.01988;
	6.16668  559.99992  750.00294 18.97991;
	4.91667  500.00042  639.99925 12.12990;
	4.08335  450.00084  559.99992  7.93993;
	2.83333  370.00151  440.00092  4.89992;
	1.58332  290.00218  320.00193  2.52005;
	0.75000  219.99815  229.99807  1.02003;
	0.00000  119.99899  119.99899  0.40006];
aLRW(:,[2 3]) = .001 * aLRW(:,[2 3]); %% length im mm to avoid large numbers
%% unpack data
aLw  = [aLRW(:,[1 2]), 10 * [1 1 1 1 1 1 1 1]'];;
%% exclude first data point from fitting in R and W
aRw = [aLRW(:,[1 3]), [0 1 1 1 1 1 1 1]']; 
aWw = [aLRW(:,[1 4]), .01 * [0 1 1 1 1 1 1 1]']; 

nrregr_options('report',0);
p = [.15 1; .84 1; .14 1; 0.0001 1; 0.00049 1; 83 1; 629 1];
%% p = nrregr('bertLRW', p, aLw, aRw, aWw);
[cov cor sd ssq] = pregr('bertLRW', p, aLw, aRw, aWw);
nm = {'length at birth, Lb'; 'ultimate length, Li'; ...
      'von Bert growth rate rB'; ...
      'contrib of L^2 to repro'; 'contrib of L^3 to repro'; ...
      'contrib of soma to weight'; 'contrib of repro to weight'};
printpar(nm,p(:,1),sd);
a = linspace(0,7.5,100)';
[L Lt W] = bertLRW(p(:,1), a, a, a);
nrregr_options('report',1);

%% gset term postscript color solid 'Times-Roman' 35
%% multiplot(1,2)

subplot(1,2,1);
%% gset output 'FenaGors83.ps'
plot(a, L, '-g', a, Lt, '-r' , aLw(:,1), aLw(:,2), '.g', aRw(:,1), aRw(:,2), '.r');
legend('true trunc', 'total trunc');
xlabel('age, d');
ylabel('length, mm');

subplot(1,2,2);
%% gset output 'FenaGors83w.ps'
plot(aWw(:,1), aWw(:,2), '.g', a, W, 'r');
xlabel('age, d');
ylabel('dry weight, mug');

%% multiplot(0,0)