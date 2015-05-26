%% fig:Droo74a
%% bib:Droo74
%% out:Droo74a,Droo74b

%% spec growth rate as function of cell quota for PO4 and vit B12
%%  in  Pavlova lutheri

%% r m_PO4 m_B12
data = [0.633 0.916 39     ;
	0.65  0.733 38.5   ;
	0.724 0.93  45.7   ;
	0.752 0.967 43.8   ;
	0.8   1.26  58.5   ;
	0.855 1.47  67     ;
	0.162 0.44  19.4   ;
	0.175 0.433 21.8   ;
	0.694 5.16   5.14  ;
	0.719 4.93   6.1   ;
	0.774 5.87   7.21  ;
	0.754 5.21   6.03  ;
	0.862 6.39   7.63  ;
	0.871 6.92   7.88  ;
	0.858 5.83   8.48  ;
	0.211 3.39   2.95  ;
	0.219 3.25   3.05  ;
	0.458 0.664  8.81  ;
	0.452 0.695  8.58  ;
	0.459 0.584  8.38  ;
	0.475 0.637  7.74  ;
	0.591 0.803 10.4   ;
	0.587 0.815 11.2   ;
	0.586 0.818 10.8   ;
	0.704 0.917 12.6   ;
	0.709 1.06  15     ;
	0.705 1.04  12.5   ;
	0.644 1.02  13.6   ;
	0.116 0.496  6.21  ;
	0.123 0.398  5.08  ;
	0.559 1.17   5.35  ;
	0.546 1.11   4.65  ;
	0.572 0.965  4.5   ;
	0.531 1.17   5.38  ;
	0.518 1.18   4.92  ;
	0.644 1.21   5.35  ;
	0.643 1.26   5.84  ;
	0.642 1.36   5.74  ;
	0.729 1.16   5.76  ;
	0.76  1.86   8.18  ;
	0.763 1.76   7.76  ;
	0.73  1.43   7.58  ;
	0.14  0.713  2.88  ;
	0.134 0.626  2.63  ];

%% reformat data into xyw for use in fit routines
%% they want to have weight coefficients in column 3
DATA = [data(:,[2 1]), ones(44,1), data(:,3)];

%% parameters:
kP = 1.19;    % 1/d, reserve PO4 turnover
kB = 1.22;    % 1/d, reserve B12 turnover
kMP = 0.0079; % 1/d, maintenance rate coeff from EP
kMB = 0.135;  % 1/d, maintenance rate coeff from EB
yPV = 0.39;   % fmol/cell, yield of P on V
yBV = 2.35;   % mol/cell, yield of B on V
%% pack parameters and assign fix
p = [kP 1; kB 0; kMP 1; kMB 1; yPV 1; yBV 1];

%% re-estimate parameter values
nrregr_options('report', 1);
p = nmregr ('growth', p, DATA);  
nrregr_options('report', 1);

%% get sd
[cov, cor, sd, ssq] = pregr('growth', p, DATA);  
ssq

%% set parameter text and present values and sd's
par_txt = {'kP'; 'kB'; 'kMP'; 'kMB'; 'yPV'; 'yBV'}; 
printpar(par_txt, p(:,1), sd); % display results

%% expected growth rates
er = max(0,growth(p(:,1),DATA));

%% gset term postscript color solid  'Times-Roman' 35
hold on;
for i= 1:44
  if data(i,1) > er(i)
    plot3(data([i; i],2), data([i; i],3), [data(i,1); er(i)], '-r');
  else
    plot3(data([i; i],2), data([i; i],3), [data(i,1); er(i)], '-b');
  end
  plot3(data(i, 2), data(i, 3), data(i, 1), '.k');
  plot3(data([i; i],2), data([i; i],3), [min(data(i, 1), er(i)); 0], '-y');
end
MP = linspace(0, 7,100)'; mP = linspace(0, 7,10)';
MB = linspace(0,70,100)'; mB = linspace(0,70,10)';
m = ones(100,1);
for i = 1:10
  %% note that 'growth' does not use columns 2 and 3
  mb = mB(i) * m; D = [MP, mb, max(0,growth(p(:,1), [MP, mb, mb, mb]))];
  plot3(D(:,1), D(:,2), D(:,3), '-m');
  mp = mP(i) * m; D = [mp, MB, max(0,growth(p(:,1), [mp, MB, MB, MB]))];
  plot3(D(:,1), D(:,2), D(:,3), '-m');
end
title('spec growth rate as function of cell quota');
grid on
rotate3d

fprintf('hit a key to proceed \n'); pause;

clf;

plot(data(:,1), er, '.g', [0;1], [0;1], '-r');
xlabel('observed growth rate, 1/d')
ylabel('expected growth rate, 1/d')
