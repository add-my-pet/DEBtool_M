%% fig:KooyHare90
%% bib:NiimOliv89,OlivNiim88,KooyHare90
%% out:KooyHare90

%% BCs for PCB153 as function of body weight in aquatic organisms

bw=[0.65610   5.87506;
    3.15533   6.56110;
    3.38200   7.33445;
    3.52891   7.04611;
    3.52245   6.96567;
    1.20411   6.41498;
    1.50515   6.23553;
    0.95422   6.53148;
   -2.30104   5.17609;
   -1.30105   5.95424;
   -1.30105   5.77815];

p = [0.01 0; 4.6 1; 27.8 1];

nmregr_options('report',0);
p = nmregr('wBC', p, bw)
nmregr_options('report',1);

w = linspace(-2.5, 3.5, 100)';
eb = wBC(p(:,1), w);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'KooyHare90.ps'
plot(bw(:,1),bw(:,2),'.g', w, eb, 'r');
xlabel('10 log body wet weight, g');
ylabel('10 log BC');
