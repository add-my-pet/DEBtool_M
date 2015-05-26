%% fig:Bert_examples;
%% bib:BergLjun82,Pres57,Grev72,Rick68
%% out:berg82,pres57,grev72,rick68

%% Length as function of age for isomorphs at constant food

nmregr_options('report',0); % suppress output during parameter estimation

%% gset term postscript color solid 'Times-Roman' 35

%% gset nokey
%% multiplot(2,2); % initiate multiplotting

subplot (2,2,1);
%% gset output 'berg82.ps'
%% Saccharomyces carlsbergensis
%% age in h, diameter in mum
aL = [4.77073  4.45394;
      4.62966  4.48103;
      4.53233  4.47370;
      4.07933  4.45246;
      3.76588  4.41691;
      3.67304  4.37635;
      3.48362  4.37583;
      3.39220  4.32931;
      3.23752  4.25559;
      3.07494  4.27236;
      3.01647  4.29563;
      2.53023  4.22529;
      2.50664  4.27304;
      2.40331  4.20344;
      2.31951  4.19691;
      2.22409  4.14373;
      2.08570  4.06216;
      1.99926  4.04940;
      1.86964  4.13817;
      1.78595  4.00896;
      1.66655  3.92116;
      1.59561  3.73093;
      1.43468  3.59758;
      1.37297  3.41696;
      1.26697  3.32590;
      1.15402  3.11126;
      1.03217  2.81086;
      0.84641  2.51898;
      0.78166  2.30606;
      0.68701  1.86568;
      0.62557  1.71937;
      0.56523  1.61557;
      0.47496  1.21788;
      0.46160  1.17632;
      0.44681  1.15287];

nmregr_options('default')
par = nmregr('bert', [0 0; 4.4 1; .14 1], aL);  % get parameters, fix L_b
[cov, cor, sd] = pregr('bert', par, aL);         % get standard deviations
par_txt = {'birth length'; 'final length'; 'van Bert growth rate '};
fprintf('Saccharomyces data \n'); printpar(par_txt, par, sd);
%% L_b < 0, but age at 'birth' is not well determined

a = linspace(0,5,100)'; L = bert(par(:,1),a);  % set ages, get predictions
title('Saccharomyces carlsbergensis')
xlabel('age, h'); ylabel('diameter, mum');% label x- and y-axis
plot(aL(:,1), aL(:,2), '+k', a, L, 'g');  % plot data and model fit

subplot(2,2,2);
%% gset output 'pres57.ps'
%% Amoeba proteus
%% age in h, weight^1/3 in g^1/3
aL =  [24   2.2642;
       20   2.2616;
       16   2.2116;
       12   2.1409;
        8   2.0551;
        4   1.9248;
        0   1.7340];

par = nmregr('bert', [1.7; 2.3; .1], aL);
[cov, cor, sd] = pregr('bert', par, aL);         % get standard deviations
fprintf('Amoeba data \n'); printpar(par_txt, par, sd);
a = linspace(0, 25, 100)'; L = bert(par, a);
title('Amoeba proteus')
xlabel('age, h'); ylabel('weight^1/3, g^1/3');
plot(aL(:,1), aL(:,2), '+k', a, L, 'g');

subplot(2,2,3);
%% gset output 'grev72.ps'
%% Pleurobrachia pileus at 5C
%% age in d, length in mm
aL05 = [ 0  3.529223372;
	 1  3.332140751;
	 2  3.606329103;  
	 3  3.797265846; 
	 4  3.890129452;  
	 6  4.218931924;  
         7  4.549199136;  
	 8  4.664332079;  
	10  4.757858236; 
	12  5.131709175; 
	15  5.47632014;  
	16  5.706201544; 
	17  5.975949932];  

%% Pleurobrachia pileus at 10C
%% age in d, length in mm
aL10 = [ 1  3.387732051;
	 2  3.651692537;
	 3  3.801329535;  
	 4  4.14158939;   
	 5  4.517824148;  
	 6  4.557564493;  
	 7  4.89333956;   
	 8  5.088036945; 
	11  5.364264238; 
	12  5.608197715; 
	13  6.006895054; 
	14  6.331322923; 
	15  6.593002379; 
	16  6.727135793; 
	17  7.060842325]; 

%% Pleurobrachia pileus at 15C
%% age in d, length in mm
aL15 = [ 0  3.326243751;
	 3  4.426978652;
	 6  5.658210365; 
	 8  6.487293574;  
	10  7.345393217; 
	11  7.399684438; 
	12  7.613651341; 
	13  8.240050981; 
	14  8.682336814; 
	15  9.021758116; 
	17  9.449529485];  

%% Pleurobrachia pileus at 20C
%% age in d, length in mm
aL20 = [ 1  3.462919872;
	 2  4.413992179;  
	 3  5.019752488;  
	 4  5.894609245;  
	 5  6.715806286;  
	 6  7.758502023;  
	 7  8.305852089;  
	 9  9.19725777;   
	10  9.706511142; 
	11  10.23363631;  
	12  10.83036099;  
	13  11.10452897;  
	14  11.53530235;  
	15  11.72186605;  
	16  11.89040281;  
	17  12.31884525];   

par05 = nmregr('bert', [3.3; 65; .003], aL05); % get parameters for 05-set
[cov, cor, sd] = pregr('bert', par05, aL05);         % get standard deviations
fprintf('Pleurobrachia 5C data \n'); printpar(par_txt, par05, sd);
par10 = nmregr('bert', [3.2; 85.46; .0027], aL10); % get parameters for 10-set
[cov, cor, sd] = pregr('bert', par10, aL10);         % get standard deviations
fprintf('Pleurobrachia 10C data \n'); printpar(par_txt, par10, sd);
par15 = nmregr('bert', [3.3; 30; .016], aL15); % get parameters for 15-set
[cov, cor, sd] = pregr('bert', par15, aL15);         % get standard deviations
fprintf('Pleurobrachia 15C data \n'); printpar(par_txt, par15, sd);
par20 = nmregr('bert', [2.2; 15; .090], aL20); % get parameters for 20-set
[cov, cor, sd] = pregr('bert', par20, aL20);         % get standard deviations
fprintf('Pleurobrachia 20C data \n'); printpar(par_txt, par20, sd);
%% some data sets are so close to linear that L_i and r_B are not well fixed

a = linspace(0,17,100)'; L05 = bert(par05,a); % set ages and get predictions
L10 = bert(par10,a); L15 = bert(par15,a); L20 = bert(par20,a);
title('Pleurobrachia pileus')
xlabel('age, d'); ylabel('length, mm');       % label x- and y-axis
plot(aL05(:,1), aL05(:,2), '+b', a, L05, 'b', ...
     aL10(:,1), aL10(:,2), '+k', a, L10, 'k', ...
     aL15(:,1), aL15(:,2), '+g', a, L15, 'g', ...
     aL20(:,1), aL20(:,2), '+r', a, L20, 'r');

subplot(2,2,4);
%% gset output 'rick68.ps'
%% Toxostoma recurvirostre
%% age in d, weight^1/3 in g^1/3
aL = [ 1  1.559535244;
       2  1.720341648;  
       3  2.004391263;  
       4  2.195703724;  
       5  2.403261982;  
       6  2.57687546;   
       7  2.722775933;  
       8  2.866224885;  
       9  2.986774814; 
      10  3.078591137; 
      11  3.161224788; 
      12  3.152925135; 
      13  3.281260213; 
      14  3.27970085;  
      15  3.28167683]; 

par = nmregr('bert', [1.2; 3.7; .14], aL); % get parameters
[cov, cor, sd] = pregr('bert', par, aL);         % get standard deviations
fprintf('Toxostoma data \n'); printpar(par_txt, par, sd);
a = linspace(0,15,100)'; L = bert(par,a);  % set ages and get predictions
title('Toxostoma recurvirostre')
xlabel('age, d'); ylabel('weight^1/3, g^1/3'); % label x- and y-axis
plot(aL(:,1), aL(:,2), '+k', a, L, 'g');   % plot data and model fit 

%% multiplot(0,0);
nmregr_options('report', 1); % reset nrregr
