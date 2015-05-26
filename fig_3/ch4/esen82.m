%% fig:esen82
%% bib:EsenRoel82,EsenRoel83
%% out:esen82a,esen82b,esen82c

%% Klebsiella aerogenes on glycerol = C_3 H_8 O_3 at 35C
%%   nHX = 8/3; nOX = 1; nNX = 0 chemical indices of substrate
%%   Xr = 10 g glycerol/l = 0.326 C-M glycerol; pH = 6.8
%% V1-morph: 1 reserve - 1 structure; kappa = 1
%% chemostat equilibria: throughput rate h = specific growth rate r

%% Parameter values
nHE = 1.66; nOE = 0.422; nNE = 0.312; % chemical indices of reserve
nHV = 1.64; nOV = 0.379; nNV = 0.198; % chemical indices of structure
kE =  2.11 ; % h^-1, reserve turnover rate
kM =  0.021; % h^-1, maintenance rate coefficient
yVE = 0.904; % yield of structure on reserve (1.135 in DEB book)
yXE = 1.345; % yield of substrate on reserve (1.490 in DEB book)
g = 1;       % energy investment ratio

%% pack parameters
par = [nHE, nOE, nNE, nHV, nOV, nNV, kE, kM, yVE, yXE, g]'; 

%% chemical indices of biomass
%%   throughput rate (h^-1), rel abundance
nHW =  [0.71   1.639705;
        0.63   1.638079;
        0.54   1.651329;
        0.41   1.649564;
        0.32   1.621994;
        0.16   1.642865;
        0.067  1.639765;
        0.035  1.641484];

nOW = [0.71   0.408444;
       0.63   0.391815;
       0.54   0.396840;
       0.41   0.434169;
       0.32   0.398719;
       0.16   0.381458;
       0.067  0.378186;
       0.035  0.359498];

nNW = [0.71   0.243735;
       0.63   0.253228;
       0.54   0.252830;
       0.41   0.227683;
       0.32   0.208643;
       0.16   0.202237;
       0.067  0.203147;
       0.035  0.206957];

%% gset nokey
%% plot (nHW(:,1), nHW(:,2), "ok", ...
%%       nNW(:,1), nNW(:,2), "ob", ...
%%       nOW(:,1), nOW(:,2), "og"); % check data graphically

%% yield of biomass on substrate
%%   throughput rate (h^-1), yield of dryweight mol/mol
YWX = [0.034749  0.459702;
       0.034445  0.389786;
       0.034257  0.355986;
       0.066309  0.532367;
       0.068374  0.575995;
       0.083319  0.604830;
       0.098947  0.586780;
       0.113728  0.584549;
       0.160211  0.607881;
       0.204909  0.627382;
       0.226262  0.629226;
       0.229852  0.620394;
       0.232527  0.612867;
       0.325045  0.655647;
       0.327487  0.636507;
       0.339030  0.658579;
       0.420259  0.677789;
       0.429811  0.647746;
       0.533683  0.677224;
       0.554426  0.687653;
       0.633499  0.687620;
       0.647673  0.694582;
       0.711023  0.696700;
       0.710814  0.690510;
       0.722615  0.682230;
       0.764453  0.681817];

%% plot (YWX(:,1), YWX(:,2), "ok"); % check data graphically

%% specific O2 consumption rate
%%   throughput rate (h^-1), spec consumption rate mol/mol.h
O2 = [0.034736  0.059632;
      0.034746  0.061738;
      0.036623  0.065246;
      0.064656  0.077861;
      0.064669  0.082071;
      0.064680  0.084177;
      0.092730  0.102057;
      0.109553  0.110820;
      0.158162  0.137812;
      0.198408  0.174283;
      0.226427  0.183041;
      0.226469  0.194619;
      0.231151  0.199528;
      0.318989  0.240183;
      0.320866  0.242639;
      0.324640  0.254567;
      0.324654  0.258075;
      0.415290  0.298730;
      0.418095  0.301183;
      0.529380  0.375513;
      0.545268  0.383573;
      0.640552  0.419664;
      0.630332  0.431599;
      0.714413  0.465240;
      0.714424  0.467696;
      0.732261  0.498563;
      0.761328  0.538899];

%% specific CO2 production  rate
%%   throughput rate (h^-1), spec production rate mol/mol.h
CO2 = [0.035630  0.048403;
       0.035633  0.049808;
       0.035643  0.052613;
       0.066464  0.062773;
       0.065546  0.066983;
       0.095428  0.074687;
       0.116926  0.086255;
       0.163628  0.102371;
       0.201042  0.130070;
       0.223457  0.137426;
       0.223471  0.140937;
       0.223481  0.144095;
       0.319673  0.173517;
       0.316885  0.176325;
       0.323447  0.185095;
       0.322526  0.187551;
       0.414039  0.213115;
       0.421501  0.213113;
       0.530827  0.263230;
       0.547637  0.268485;
       0.641934  0.289839;
       0.629834  0.297564;
       0.709178  0.311908;
       0.709188  0.314716;
       0.727043  0.349795;
       0.762559  0.368020];

%% plot (O2(:,1),  O2(:,2), "og", CO2(:,1), CO2(:,2), "ok"); % check data

%% with hm \simeq rm for small K
rm = 1.052; % h^-1, max specific growth rate as observed by Esener

%% specification of expected values
%% gset term postscript color solid  "Times-Roman" 30
%% gset output "esen82.ps"

shregr_options('default');
shregr_options('xlabel', 1, 'growth rate, h^-1');
shregr_options('xlabel', 2, 'growth rate, h^-1');
shregr_options('xlabel', 3, 'growth rate, h^-1');
shregr_options('xlabel', 4, 'growth rate, h^-1');
shregr_options('xlabel', 5, 'growth rate, h^-1');
shregr_options('xlabel', 6, 'growth rate, h^-1');
shregr_options('ylabel', 1, 'nHW');
shregr_options('ylabel', 2, 'nOW');
shregr_options('ylabel', 3, 'nNW');
shregr_options('ylabel', 4, 'YWX');
shregr_options('ylabel', 5, 'JO2/MW');
shregr_options('ylabel', 6, 'JCO2/MW');

%% show graphs of data and model predictions; don't plot rm
%% clg; shregr_options('all_in_one', 1); shregr_options('dataset', [1 2 3]);
%% clg; shregr_options('all_in_one', 1); shregr_options('dataset', 4);
%% clg; shregr_options('all_in_one', 1); shregr_options('dataset', [5 6]);
shregr ('kleb', par, nHW, nOW, nNW, YWX, O2, CO2);

%% present max spec growth rate
[enHW, enOW, enNW, eYWX, eO2, eCO2, erm] = ...
    kleb (par(:,1), nHW, nOW, nNW, YWX, O2, CO2, rm);
fprintf(['max spec growth rate ', num2str(erm),' h^-1 \n']);

return; % end of script file

%% re-estimate parameter values  
par = [par, [1;1;1; 1;1;1; 0;0;1;1; 0]]; % fix some parameters
rm = [rm, 10]; % weigh some data different from 1
p = nmregr ('kleb', par, nHW, nOW, nNW, YWX, O2, CO2, rm); % get new pars
[cov, cor, sd] = pregr('kleb', p, nHW, nOW, nNW, YWX, O2, CO2, rm);
							   % get sd
par_txt = {'nHE '; 'nOE'; 'nNE'; 'nHV'; 'nOV'; 'nNV'; ...
	   'kE'; 'kM'; 'yVE'; 'yXE'; 'g'}; % set parameter text
printpar(par_txt, p(:,1), sd); % display results

%% present max spec growth rate
[enHW, enOW, enNW, eYWX, eO2, eCO2, erm] = ...
    kleb (p(:,1), nHW, nOW, nNW, YWX, O2, CO2, rm);
fprintf(['max spec growth rate ', num2str(erm),' h^-1 \n']);

%% re-plot model predictions
shregr ('kleb', p, nHW, nOW, nNW, YWX, O2, CO2)
