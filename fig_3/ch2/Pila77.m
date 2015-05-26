%% fig:Pila77
%% bib:Pila77
%% out:pila77

%% feeding (10^3 cells/d) at food density (10^5cell/ml) for Brachionus rubens

XF=[27.884846  15.715355;
  17.638087  14.983012;
  12.957514  14.277515;
   9.478496  13.564435;
   5.758434  12.389038;
   4.035515  11.534695;
   3.795570  11.225117;
   2.934598  10.421801;
   1.440036   8.055911;
   0.986251   7.102997;
   0.933431   6.820539;
   0.835721   6.606253;
   0.519047   5.844742;
   0.386205   5.449709;
   0.297644   4.901665;
   0.267758   4.658620;
   0.243848   4.455196;
   0.123327   3.341755;
   0.056479   2.629563;
   0.053308   2.137532];

nrregr_options('report',0)
p = [1.47; 15.97; 0.35];
p = nrregr('hyp_shift', p, XF);

par_txt = {'sat coeff';'max ingestion';'shift'};
[cor,cov,sd] = pregr('hyp_shift', p, XF);
printpar(par_txt, p);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'pila77.ps'

%% gset nokey
shregr_options('default')
shregr_options('xlabel', 'food density, 10^5 cell/ml')
shregr_options('ylabel', 'ingestion rate, 10^3 cells/d')
shregr('hyp_shift', p, XF);
