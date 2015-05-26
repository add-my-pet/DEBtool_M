%% fig:Rich58
%% bib:Rich58
%% out:Rich58

%% O2 consumption for Daphnia pulex at 20C

%% length (mm) and respiration (mul/h) data
O2 = [0.646 0.0262;
      0.642 0.0276;
      0.642 0.0231;
      0.745 0.0284;
      0.85  0.0457;
      0.978 0.0352;
      1.011 0.0631;
      1.19  0.063;
      1.077 0.0674;
      1.11  0.0875;
      1.318 0.103;
      1.31  0.0937;
      1.445 0.1419;
      1.48  0.0913; 
      1.42  0.1229;
      1.56  0.1261;
      1.513 0.1345;
      1.52  0.1592;
      1.62  0.1638;
      1.74  0.2024;
      1.682 0.2021;
      1.71  0.1747;
      1.75  0.211;
      1.75  0.2186;
      1.74  0.1835;
      1.775 0.215;
      1.82  0.2186;
      1.871 0.2212;
      1.85  0.2568];


nrregr_options('report',0);
presp = nrregr('resp',[0.03; 0.02],O2); % get parameters of DEB model
[cov,cor,sd] = pregr('resp',presp,O2);  % get standard deviation
fprintf('DEB model for respiration JO2 = a L^2 + b L^3 \n');
par_txt = {'a ';'b'}; printpar(par_txt, presp, sd); % present result

pallo = nrregr('allo',[0.05; 2.44],O2); % get parameter of allometric model
[cov,cor,sd] = pregr('allo',pallo,O2);  % get standard deviation
fprintf('allometric model for respiration JO2 = a L^b \n');
par_txt = {'a ';'b'}; printpar(par_txt, pallo, sd); % present result
nrregr_options('report',1);

%% get model fits
L = linspace(0,1.9,100)'; % set length values
Oresp = resp(presp,L);    % get respiration for DEB model
Oallo = allo(pallo,L);    % get respiration for allometric model

%% gset term postscript color solid  'Times-Roman' 35
%% gset output 'Rich58.ps'

plot(L, Oresp, '-g', L, Oallo, '-r', O2(:,1), O2(:,2), '.k');
legend('DEB model', 'allometric model');
xlabel ('length, mm'); ylabel('O2 consumption, mul/h');