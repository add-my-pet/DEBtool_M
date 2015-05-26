%% fig:Muld88
%% bib:Muld88
%% out:Muld88

%% Batch culture of Escherichia coli and potassium conc

tOD = [9.50 17.294;
       9.25  17.032;
       9.00  17.571;
       8.75  16.309;
       8.50  15.532;
       8.25  16.905;
       8.00  16.036;
       7.75  15.486;
       7.50  15.495;
       7.25  15.743;
       7.00  15.434;
       6.75  15.369;
       6.50  14.795;
       6.25  14.198;
       6.00  13.258;
       5.75  12.663;
       5.50  12.249;
       5.25  12.148;
       5.00  11.733;
       4.75  10.850;
       4.50  10.526;
       4.25   9.599;
       4.00   9.184;
       3.75   8.406;
       3.50   7.356;
       3.25   5.626;
       3.00   4.484;
       2.75   3.662;
       2.50   2.990;
       2.00   1.496;
       1.75   1.278;
       1.50   1.046;
       1.25   0.904;
       1.00   0.748;
       0.75   0.682;
       0.50   0.616;
       0.25   0.565;
       0.00   0.470];


tK = [9.512  0.000;
      8.733  0.000;
      7.482  0.000;
      6.247  0.000;
      4.965  0.000;
      3.706  0.000;
      3.218  0.000;
      2.968  0.124;
      2.745  0.212;
      2.449  0.332;
      1.974  0.480;
      1.199  0.582;
      1.683  0.619;
      1.430  0.699;
      0.416  0.761;
      0.921  0.809;
      0.015  0.800];

tOD = [tOD, .05 * ones(length(tOD),1)]; % small weight coefficients

par_txt = {'initial nutrient conc'; 'initial biomass density'; ...
	   'max spec uptake rate'; 'energy investment ratio'; ...
	   'reserve turnover rate'};
p = [.825 1; .657 1; .125 1; .426 1; .925 1];
p = nrregr('expologist', p, tOD, tK);
[cor cov sd ssq] = pregr('expologist', p, tOD, tK);
printpar(par_txt, p, sd);

t = linspace(0, 10, 100)';
[OD K] = expologist(p(:,1), t, t);

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'muld88.ps'

hold on
[AX, H1, H2] = plotyy(t, OD, t, K);
set(get(AX(1), 'YLabel'), 'String', 'extinction at 540 nm');
set(get(AX(2), 'YLabel'), 'String', 'potassium concentration, mM');
set(H1, 'Color', 'g'); set(H2, 'Color', 'r')
legend('E. coli', 'potassium', 4)
[AX, H3, H4] = plotyy(tOD(:,1), tOD(:,2), tK(:,1), tK(:,2)); 
set(H3, 'LineStyle', 'none'); set(H3, 'Marker', '.'); set(H3, 'Color', 'g');
set(H4, 'LineStyle', 'none'); set(H4, 'Marker', '.'); set(H4, 'Color', 'r');
xlabel('time, h')
