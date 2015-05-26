%% fig:PostSche89
%% bib:PostSche89,PostVerd89,Verd92,Hane97
%% out:post1,post2,post3,post4

%% Saccharomyces cerevisiae in glucose-limited chemostat
%% Eq given in the legends

GLU = [0.102 0.07777777778 1;
       0.154 0.07777777778 1;
       0.204 0.1           1;
       0.28  0.1111111111  1;
       0.303 0.1555555556  1;
       0.329 0.1388888889  1;
       0.342 0.1833333333  1;
       0.359 0.1444444444  1;
       0.382 0.07222222222 1;
       0.398 0.4666666667  1;
       0.411 1.461111111   1;
       0.421 1.655555556   1;
       0.442 3.622222222   1;
       0.45  5.483333333   1;
       0.469 11.43888889   1;
       0.48  19.58333333   1];
       
bio = [0.049 7.594 1;
       0.101 7.593 1;
       0.153 7.517 1;
       0.202 7.467 1;
       0.252 7.4   1;
       0.278 7.42  1;
       0.306 7.415 1;
       0.328 7.436 1;
       0.343 7.309 1;
       0.367 7.066 1;
       0.385 7.054 1;
       0.392 3.54  1;
       0.402 3.15  1;
       0.416 2.71  1;
       0.436 2.466 1;
       0.446 2.498 1;
       0.454 2.215 1;
       0.472 2.129 1;
       0.484 1.896 1];
       
co2 = [0.049 1.029  1;
       0.1   2.592  1;
       0.152 3.949  1;
       0.198 5.104  1;
       0.248 6.256  1;
       0.275 7.14   1;
       0.301 7.859  1;
       0.324 9.241  1;
       0.339 10.095 1;
       0.361 10.198 1;
       0.379 11.255 1;
       0.388 17.77  1;
       0.397 20.28  1;
       0.41  22.744 1;
       0.429 24.791 1;
       0.438 29.943 1;
       0.448 30.058 1;
       0.467 28.719 1;
       0.477 31.022 1];
       
o2 =  [0.049 0.864  1;
       0.1   2.18   1;
       0.153 3.412  1;
       0.199 4.69   1;
       0.248 5.926  1;
       0.274 6.067  1;
       0.3   6.91   1;
       0.325 9.034  1;
       0.34  9.64   1;
       0.362 9.661  1;
       0.398 9.174  1;
       0.411 9.162  1;
       0.432 9.515  1;
       0.442 9.382  1;
       0.449 10.118 1;
       0.468 10.39  1;
       0.479 10.587 1];

P1 = [0.382 0.729 1;
      0.389 21.91 1;
      0.399 49.766 1;
      0.403 58.5 1;
      0.419 68.862 1;
      0.439 69.481 1;
      0.439 76.985 1;
      0.451 74.323 1;
      0.451 69.127 1;
      0.469 62.741 1;
      0.479 56.454 1];

P2 = [0.38  0.073  1;
      0.388 16.552 1;
      0.399 19.169 1;
      0.405 18.332 1;
      0.42  20.529 1;
      0.439 15.048 1;
      0.451 12.799 1];

P3 = [0.299 0.043  1;
      0.323 0.239  1;
      0.338 0.213  1;
      0.378 0.914  1;
      0.387 1.585  1;
      0.398 2.133  1;
      0.419 3.095  1;
      0.438 3.307  1;
      0.451 3.208  1;
      0.45  3.111  1;
      0.468 2.614  1;
      0.479 1.981  1];

P4 = [0.104 0.237  1;
      0.149 0.179  1;
      0.2   0.178  1;
      0.254 0.256  1;
      0.3   0.35   1;
      0.327 0.416  1;
      0.379 0.495  1;
      0.403 0.807  1;
      0.421 1.3    1;
      0.441 1.883  1;
      0.473 2.343  1;
      0.484 2.663  1];

P5 = [0.326 0.001  1;
      0.339 0.01   1;
      0.357 0.02   1;
      0.379 0.047  1;
      0.39  0.075  1;
      0.402 0.066  1;
      0.401 0.363  1;
      0.41  0.304  1;
      0.42  0.357  1;
      0.438 0.403  1;
      0.448 0.431  1;
      0.471 0.306  1;
      0.481 0.341  1];

hm = [0.45  0.492  100];
%% first element is not functional, but included
%%   because the fitting routines require an xyw format

%% specification of expected values

%% Parameter values
nHE = 1.70; nOE = 0.62; nNE = 0.23; % chemical indices of reserve
nHV = 1.75; nOV = 0.61; nNV = 0.14; % chemical indices of structure
kE =  0.54;   % h^-1, reserve turnover rate
kM =  0.003;  % h^-1, maintenance rate coefficient
yEV = 0.78;   % -, yield of reserve on structure
yEX = 0.51;   % -, yield of reserve on glucose by carriers 1
kapA = .187;  % -, yEX * kapA = yEX for carriers 2
jXAm1 = 145*2.16; % mM (M h)^-1, max spec uptake by carriers 1
jXAm2 = 145*81;   % mM (M h)^-1, max spec uptake by carriers 2
er = 0.7;     % -, error in acetaldehyde to repair C balance in data
g = 0.05;     % -, energy investment ratio
K1 = 0.1;     % mM, saturation constant for glucose
K2 = 40;      % mM, saturation constant for glucose
Xr = 83.3;    % mM, glucose conc in the feed
z1A1 = 0; z1A2 = 145*3*55 ;  z1D = 0; z1G = 0; % ethanol prod couplers
z2A1 = 0; z2A2 = 145*2*43;   z2D = 0; z2G = 0; % acetaldehyde prod couplers
z3A1 = 0; z3A2 = 145*3*2.35; z3D = 0; z3G = 0; % acetic acid prod couplers
z4A1 = 0; z4A2 = 145*2*2.47; z4D = 0; z4G = 0; % glycerol prod couplers
z5A1 = 0; z5A2 = 145*3*0.34; z5D = 0; z5G = 0; % pyruvic acid prod couplers
%% pack parameters and assign fix
par = [nHE 0; nOE 0; nNE 0; ...
       nHV 0; nOV 0; nNV 0; ...
       Xr 0; K1 0; K2 0; ...
       kE 1; kM 0; er 1; ...
       yEV 1; yEX 1; kapA 1; ...
       jXAm1 1; jXAm2 1; g 1; ...
       z1A1 0; z1A2 1; z1D 0; z1G 0; ...
       z2A1 0; z2A2 1; z2D 0; z2G 0; ...
       z3A1 0; z3A2 1; z3D 0; z3G 0; ...
       z4A1 0; z4A2 1; z4D 0; z4G 0; ...
       z5A1 0; z5A2 1; z5D 0; z5G 0]; 

%% re-estimate parameter values
nmregr_options('max_step_number',20000)
nmregr_options('max_fun_evals',20000)
p = nmregr ('saccp', par, GLU, bio, o2, co2, P1, P2, P3, P4, P5, hm); 

%% get sd
[cov, cor, sd] = pregr('saccp', p, GLU, bio, o2, co2, P1, P2, P3, P4, P5, hm); 

par_txt = {'nHE'; 'nOE'; 'nNE'; ...
	   'nHV'; 'nOV'; 'nNV'; ...
	   'Xr'; 'K1'; 'K2'; ...
	   'kE'; 'kM';'er'; ...
	   'yEV'; 'yEX'; 'kapA'; ...
	   'jXAm1'; 'jXAm2'; 'g';  ...
	   'z1A1'; 'z1A2'; 'z1D'; 'z1G'; ...
	   'z2A1'; 'z2A2'; 'z2D'; 'z2G'; ...
	   'z3A1'; 'z3A2'; 'z3D'; 'z3G'; ...
	   'z4A1'; 'z4A2'; 'z4D'; 'z4G'; ...
	   'z5A1'; 'z5A2'; 'z5D'; 'z5G'}; % set parameter text
printpar(par_txt, p(:,1), sd); % display results

%% present max throughput rate
[eGLU, ebio, eo2, eco2, eP1, eP2, eP3, eP4, eP5, ehm] =  ...
    saccp (p(:,1), GLU, bio, o2, co2, P1, P2, P3, P4, P5, hm);
fprintf(['max throughput rate ', num2str(ehm),' h^-1 \n']);

%% prepare for graphs
r = linspace(1e-3, ehm - 1e-4, 100)';
[eGLU, ebio, eo2, eco2, eP1, eP2, eP3, eP4, eP5, ehm] = ...
    saccp (p(:,1), r, r, r, r, r, r, r, r, r, 1);

%% gset term postscript color solid  'Times-Roman' 35

subplot(2,3,1);
%% gset output 'PostSche89a.ps'
plot(GLU(:,1), GLU(:,2), '.m', r, min(20,eGLU), 'm')
xlabel('throughput rate, 1/h')
ylabel('glucose conc (mM)')

subplot(2,3,2); 
%% gset output 'PostSche89b.ps'
plot(bio(:,1), bio(:,2), '.g', r, ebio, 'g')
xlabel('throughput rate, 1/h')
ylabel('biomass density (g/l)')

subplot(2,3,3); 
%% gset output 'PostSche89c.ps'
plot(r, min(35,eo2), 'g', r, min(35,eco2), 'k', ...
     o2(:,1), o2(:,2), '.g', co2(:,1), co2(:,2), '.k')
legend('O2', 'CO2', 'Location', 'NorthWest')
xlabel('throughput rate, 1/h')
ylabel('CO2-prod, O2-cons rate, mmol/g')

subplot(2,3,4); 
%% gset output 'PostSche89d1.ps'
plot(r, eP1, 'g', r, eP2, 'b', ...
     P1(:,1), P1(:,2), '.g', P2(:,1), P2(:,2), '.b')
legend('ethanol', 'acetaldehyde', 'Location', 'NorthWest')
xlabel('throughput rate, 1/h')
ylabel('product concentration, mM')

subplot(2,3,5);
%% gset output 'PostSche89d2.ps'
plot(r, eP3, 'm' , r, eP4, 'r', ...
    P3(:,1), P3(:,2), '.m', P4(:,1), P4(:,2), '.r')
legend('acetic acid', 'glycerol', 'Location', 'NorthWest')
xlabel('throughput rate, 1/h')
ylabel('product concentration, mM')

subplot(2,3,6);
%% gset output 'PostSche89d3.ps'
plot(r, eP5, 'c', P5(:,1), P5(:,2), '.c')
legend('pyruvic acid','Location', 'NorthWest')
xlabel('throughput rate, 1/h')
ylabel('product concentration, mM')