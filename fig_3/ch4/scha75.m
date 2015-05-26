%% fig:scha75
%% bib:Scha75,Hane97
%% out:scha751,scha752, scha753,scha754

%% Saccharomyces cerevisae in glucose-limited chemostat

nHW = [0.028631066 1.673258777 150;
       0.04927338  1.643877342 150;
       0.098953411 1.681429035 150;
       0.148301257 1.682255544 150;
       0.248516442 1.693317932 200;
       0.319247827 1.514017338 150];

nOW = [0.028631066 0.637564929 150;
       0.04927338  0.612849559 150;
       0.098953411 0.631137437 150;
       0.148301257 0.629352318 150;
       0.248516442 0.606820067 150;
       0.319247827 0.608696561 200];

nNW = [0.028631066 0.083701532 150;
       0.04927338  0.08848828  150;
       0.098953411 0.09365027  150;
       0.148301257 0.106974726 150;
       0.248516442 0.155791427 150;
       0.319247827 0.186674814 200];

GLU = [0.129712773 0.169552099 1;
       0.150034479 0.359426419 1;
       0.204560647 0.598246423 1;
       0.229160973 1.159456572 1;
       0.248023558 1.614774852 1;
       0.259253159 2.144848725 1;
       0.310974359 8.433960199 1;
       0.319311731 11.03523065 1];

XXX = [0.028631066 26.36433589 0;
       0.04927338  25.98769074 0;
       0.098953411 26.41129664 0;
       0.148301257 26.57846189 0;
       0.248516442 26.93001998 0;
       0.319247827 27.22801023 0];

bio = [0.030270553 2.913813678 40;
       0.0607348   2.933820853 20;
       0.099905242 2.997053301 20;
       0.130661087 2.923327954 30;
       0.150298995 2.965026707 30;
       0.229073943 2.825118677 30;
       0.249252484 2.864814995 30;
       0.26902064  2.596167065 30;
       0.311809043 1.936686012 30;
       0.318822322 1.769276645 30];

ETH = [0.029051643 9.445347881 1;
       0.058021624 9.452877973 1;
       0.150474736 9.422989428 1;
       0.249545875 8.787130917 1;
       0.271558518 7.645379428 1;
       0.310462991 5.968858252 1;
       0.32030374  5.545789358 1];

GLY = [0.028619858 2.282372561 4;
       0.099651583 2.513115286 4;
       0.149555489 2.56984049  4;
       0.269414959 2.331456039 4;
       0.309583445 1.86293209  4];

PYR = [0.029287044 0.529509468 1;
       0.037864961 0.486634139 1;
       0.049432479 5.518358418 1;
       0.068672754 7.779195095 1;
       0.098095275 10.78511483 1;
       0.148746878 11.94864817 1;
       0.229079619 39.12946432 1;
       0.269941608 44.54124394 1;
       0.319884693 32.70465504 1];

co2 = [0.028905072 3.528270093 1;
       0.060648855 6.350077304 1;
       0.100510253 10.19351058 1;
       0.150594197 16.63117013 1;
       0.25042708  25.00899183 1;
       0.307692489 32.03048498 1;
       0.318836319 32.43687808 1];

glu = [0.030395705 1.705912332 1;
       0.060342477 3.449928281 1;
       0.100629649 5.73133809  1;
       0.150880848 8.349324784 1;
       0.24950812  13.88484757 1;
       0.260265917 15.17377237 1;
       0.310972884 17.84544111 1;
       0.318648405 18.99695645 1];
       
eth = [0.100327025 7.733654856 1;
       0.151059973 10.75410911 1;
       0.270025682 20.04622814 1;
       0.310660515 22.14295515 1];

hm = [0.34 0.34 1000]; % max throughput rate
%% first element is not functional, but included
%%   because the fitting routines require an xyw format

%% specification of expected values

%% Parameter values
nHE = 1.55; nOE = 0.572; nNE = 0.205; % chemical indices of reserve
nHV = 1.70; nOV = 0.637; nNV = 0.071; % chemical indices of structure
kE =  0.461; % h^-1, reserve turnover rate
kM =  0.003; % h^-1, maintenance rate coefficient
yVE = 1.206; % -, yield of structure on reserve
yXE = 10.28; % -, yield of substrate on reserve
g = 0.385;   % -, energy investment ratio
K = 1.79;    % g/l, saturation constant for glucose
Xr = 30;     % g/l, glucose conc in the feed
zeA = 8.047 ; zeD = 3.019 ; zeG = 0.336;   % ethanol prod couplers
zgA = 7.398 ; zgD = 2.711 ; zgG = 0.972;   % glycerol prod couplers
zpA = 0.0313; zpD = 0.0062; zpG = -0.0365; % pyruvate prod couplers
%% pack parameters and assign fix
par = [nHE 1; nOE 1; nNE 1; nHV 1; nOV 1; nNV 1; ...
       Xr 0; K 0; kE 1; kM 1; yVE 1; yXE 1; g 0; ...
       zeA 1; zeD 1; zeG 1; zgA 1; zgD 1; zgG 1; zpA 1; zpD 1; zpG 1]; 

%% re-estimate parameter values
p = nrregr ('sacc', par, nHW, nOW, nNW, GLU, bio, ETH, GLY, PYR, ...
 	    co2, glu, eth, hm); % get new pars
[cov, cor, sd] = pregr('sacc', p, nHW, nOW, nNW, GLU, bio, ...
 		       ETH, GLY, PYR, co2, glu, eth, hm); % get sd

par_txt = {'nHE '; 'nOE'; 'nNE'; 'nHV'; 'nOV'; 'nNV'; ...
	   'Xr'; 'K'; 'kE'; 'kM'; 'yVE'; 'yXE'; 'g'; ...
	   'zeA'; 'zeD'; 'zeG'; 'zgA'; 'zgD'; 'zgG'; ...
	   'zpA'; 'zpD'; 'zpG'}; % set parameter text
printpar(par_txt, p(:,1), sd); % display results

%% present max throughput rate
[enHW, enOW, enNW, eGLU, ebio, eETH, eGLY, ePYR, ...
 eco2, eglu, eeth, ehm] = ...
    sacc (p(:,1), nHW, nOW, nNW, GLU, bio, ETH, GLY, PYR, co2, glu, eth, hm);
fprintf(['max throughput rate ', num2str(ehm),' h^-1 \n']);

%% prepare for graphs
r = linspace(1e-3, ehm - 1e-4, 100)';
[enHW, enOW, enNW, eGLU, ebio, eETH, eGLY, ePYR, ...
 eco2, eglu, eeth, ehm] =  ...
    sacc (p(:,1), r, r, r, r, r, r, r, r, r, r, r, r);

%% gset term postscript color solid  'Times-Roman' 35
%% gset nokey;
%% multiplot(2,2)

subplot(2,2,1);
%% gset output 'scha751.ps'
plot(nHW(:,1), nHW(:,2), 'ob', nOW(:,1), nOW(:,2), 'og', ...
     nNW(:,1), nNW(:,2), 'or', ...
     r, enHW, 'b', r, enOW, 'g', r, enNW, 'r')
xlabel('throughput rate, 1/h')
ylabel('chemical indices')

subplot(2,2,2);
%% gset output 'scha752.ps'
plot(GLU(:,1), GLU(:,2), 'om', bio(:,1), bio(:,2), 'og', ...
     r(1:97), eGLU(1:97), 'm', r, ebio, 'g')
xlabel('throughput rate, 1/h')
ylabel('glucose, weight, g/l')

subplot(2,2,3);
%% gset output 'scha753.ps'
plot(GLY(:,1), GLY(:,2), 'og', ETH(:,1), ETH(:,2), 'ob', ...
     PYR(:,1), PYR(:,2)/5, 'or', ...
     r, eGLY, 'g', r, eETH, 'b', r, ePYR/5, 'r')
xlabel('throughput rate, 1/h')
ylabel('glycerol, ethanol, g/l, pyruvate/5, mg/l')

subplot(2,2,4);
%% gset output 'scha754.ps'
plot(co2(:,1), co2(:,2), 'ok', eth(:,1), eth(:,2), 'ob', ...
     glu(:,1), glu(:,2), 'om', ...
     r, eco2, 'k', r, eeth, 'b', r, eglu, 'm')
xlabel('throughput rate, 1/h')
ylabel('spec prod/cons, mM/gh')

%% multiplot(0,0)
