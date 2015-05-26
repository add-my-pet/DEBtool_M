%% fig:ForsWikl88
%% bib:ForsWikl88
%% out:ForsWikl88

%% pupal weight (mg) as function of dev time (d) in Pieris napi

aW = [18 112.1991;
      17 114.1223;
      16 115.9335;
      15 118.2218;
      14 119.6853;
      13 121.1226;
      12 122.3885;
      11 123.6231;
      10 124.8413;
       9 125.8188;
       8 126.3202;
       7 127.0213;
       6 127.6290;
       5 128.2817;
       4 128.7277;
       3 129.2747;
       2 129.7614;
       1 130.1888];

nrregr_options('report',0);
p = [130.5 7.4 10]';
p = nrregr('pupa', p, aW);
nrregr_options('report',1);

[cov cor sd] = pregr('pupa', p, aW);
par_txt = {'E_0';'V_0^(1/3) * 3/v'; '(3/v) * (kappa/[E_G])^(1/3)'};
printpar(par_txt,p,sd)

t = linspace(0,18,100)';
W = pupa(p, t);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'ForsWikl88.ps'

plot(aW(:,1), aW(:,2), '.g', t, W, 'r')
xlabel('time, d')
ylabel('pupal weight, mg')
