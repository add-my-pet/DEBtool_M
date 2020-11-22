%% fig:mYW
%% bib:Rutg90,MeijVers77,VersBras83,VersStou76,VersStou78,VersStou80
%% out:mYW

%% molar yield as a function of chemical potential in bacteria

%% Pseudomonas oxalaticus
%% bib:Rutg90
muY_Pa = [656.999583    0.558001;
  546.000000    0.569002;
  476.000000    0.505001;
  422.000833    0.406001;
  375.999167    0.385000;
  333.999167    0.390000;
  296.000833    0.280001;
  289.000833    0.238000;
  260.000417    0.220001;
  253.000417    0.162002;
  130.999167    0.086000];

%% Paracoccus denitrificans
%% bib:MeijVers77,VersBras83,VersStou76,VersStou78,VersStou80
muY_Pd = [691.99958    0.50723;
  511.00000    0.55108;
  511.00000    0.63377;
  430.00125    0.51614;
  430.00125    0.51614;
  375.99917    0.38409;
  375.99917    0.38799;
  375.99917    0.50535;
  338.00083    0.38982;
  253.00042    0.11755];

nrregr_options('report',0);
p = nrregr('linear_r', [0 0; 1 1], [muY_Pa; muY_Pd]);
[cov cor sd] = pregr('linear_r', p, [muY_Pa; muY_Pd]);
printpar({'prop constant'}, p(2,1), sd(2));
mu = [0 700]';
h = linear_r(p(:,1), mu);
nrregr_options('report',1);

%% gset term postscript color solid  'Times-Roman' 35
%% gset output 'mYW.ps'

plot(muY_Pa(:,1), muY_Pa(:,2), '.g', ...
     muY_Pd(:,1), muY_Pd(:,2), '.b', ...
     mu, h, '-r')
legend('Pseudomonas oxalaticus', 'Paracossus denitrificans');
xlabel('chem potential substrate, kJ/C-mol')
ylabel('yield Y_WX, C-mol/C-mol')
