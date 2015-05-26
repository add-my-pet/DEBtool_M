%% fig:Wint73
%% bib:Wint73
%% out:Wint73

%% filtration rate (l/h) as function of length (cm) for Mytilus edulis

LF = [5.654725  1.284000;
      4.653881  0.948000;
      3.653064  0.556000;
      3.302752  0.427001;
      2.652220  0.273002;
      2.151798  0.165000;
      1.651376  0.080998;
      0.850734  0.017001];

p = nrregr('feeding', .04, LF)

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'Wint73.ps'

%% gset nokey
shregr_options('default')
shregr_options('xlabel', 'length, cm')
shregr_options('ylabel', 'filtration rate, 1/h')
shregr('feeding', p, LF);
