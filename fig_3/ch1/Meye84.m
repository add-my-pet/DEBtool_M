%% fig:Chyd
%% bib:Meye84
%% out:Meye84

itt = [32.98757047 -3.394823128;
       33.54588165 -3.730757037;
       34.12264786 -4.057620684;
       34.71175126 -4.481983805;
       35.32530648 -4.916139778];

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'Meye84.ps'

%% gset nokey;
nrregr_options('report',0);
p = nrregr('linear_Ap',[1 1]',itt);
nrregr_options('report',1);
shregr_options('xlabel','10^4 T^-1, K^-1');
shregr_options('ylabel','- ln egg dev. time, d');
shregr('linear_Ap',p,itt)