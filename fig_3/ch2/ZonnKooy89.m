%% fig:ZonnKooy89
%% bib:ZonnKooy89
%% out:ZonnKooy89

%% food intake (cm^2/d) as function of length (cm) for Lymnaea stagnalis

LG = [3.3250  39.0001;
   3.2900  28.4000;
   3.3133  23.8001;
   3.1500  31.4001;
   3.4183  41.1001;
   3.3367  26.9000;
   2.7067  24.4001;
   2.7650  17.3000;
   2.8350  23.3001;
   2.7183  15.4001;
   2.6483  18.7000;
   2.7883  18.7000;
   2.2050  23.3001;
   2.2283  15.1000;
   2.1933  18.9001;
   2.2867  20.0000;
   2.2283  13.5001;
   2.2167  12.7001;
   1.7033  14.0001;
   1.6917  11.0000;
   1.7150  10.8001;
   1.6333  13.6001;
   1.7150  15.4001;
   1.6217  11.9000;
   1.0150   4.1000;
   1.1083   4.8000;
   1.0150   2.7000;
   1.1317   6.1000;
   1.0033   7.3001;
   1.0500   5.0000];


%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'ZonnKooy89.ps'

nrregr_options('default')
p = nrregr('feeding', 3, LG)
%% gset nokey
shregr_options('default')
shregr_options('xlabel', 'length, cm')
shregr_options('ylabel', 'food intake rate, cm^2/d')
shregr('feeding', p, LG);
