%% fig:BlaxHunt82
%% bib:BlaxHunt82
%% out:BlaxHunt82

%% puberty length as function of ultimate length in clupoid fishes

%% Clupea
cl = [38.780  28.500;
  36.376  27.972;
  31.678  24.260;
  30.247  24.291;
  29.862  24.335;
  29.679  23.498;
  29.333  23.079;
  27.306  21.168];
  
%% Brevoortia
br = [32.899  26.828];


%% Sprattus
sp = [16.2938  13.3880;
  15.8288  11.6797;
  15.0250  10.8917;
  12.8450   9.3398];

%% Sardinops
Sa =  [30.224  22.348;
  31.214  19.020;
  27.269  19.640];


%% Sardina
sa = [20.470  14.650;
  21.137  15.316;
  20.470  15.316;
  21.137  14.650;
  20.470  14.650;
  19.774  14.179;
  20.441  14.846;
  19.774  14.846;
  20.441  14.179;
  19.774  14.179;
  19.002  14.196;
  19.669  14.863;
  19.002  14.863;
  19.669  14.196;
  19.002  14.196;
  18.274  12.446;
  18.941  13.113;
  18.274  13.113;
  18.941  12.446;
  18.274  12.446];

%% Sardinella
sA = [31.586  22.034;
  28.514  16.567;
  26.766  17.399;
  26.344  17.989;
  25.521  17.913];

%% Engraulis
en = [20.1843  13.5865;
  16.8958  14.0738;
  16.7917   9.7978;
  16.6778  10.7485;
  16.2380  11.6115;
  15.2692  11.2062;
  15.4463  10.8112;
  15.2620   9.8908];

%% Centengraulis
ce = [15.630  13.734];

%% Stolephorus
st =  [7.3380  3.6808];

nrregr_options('report',0)
p = nrregr('propto',1,[cl;br;sp;Sa;sa;sA;en;ce;st]);
l = [0 40]'; L = propto(p,l);
nrregr_options('report',1)

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'BlaxHunt82.ps'

plot(cl(:,1), cl(:,2), '.r', br(:,1), br(:,2), '.g', ...
     sp(:,1), sp(:,2), '.b', Sa(:,1), Sa(:,2), '.m', ...
     Sa(:,1), Sa(:,2), '.c', sA(:,1), sA(:,2), '.y', ...
     en(:,1), en(:,2), '.k', ce(:,1), ce(:,2), '+r', ...
     st(:,1), st(:,2), '+g', l, L, '-r')
legend('Clupea', 'Brevoortia', 'Sprattus', 'Sardinops', 'Sardina', 'Sardinella', ...
    'Engraulis', 'Centengraulis', 'Stolephorus', 2);
title('length at puberty among clupoid fish')
xlabel('maximum length')
ylabel('length at puberty')
