%% fig:Came84
%% bib:Came84
%% out:Came84

%% Length as function of age with a shift in L_inf and r_B at a = 13

aL = [0.01822481473 0.5218074351;
      0.4242089731 0.6488752111;
      1.034256445 0.7218652059;
      1.526001851 0.805800039;
      2.004516996 0.9003477247;
      2.674061662 0.9298597829;
      3.06765134 0.9757793423;
      3.425067522 1.027858381;
      4.0782108 1.055656853;
      4.557175021 1.100900084;
      5.065986075 1.113618996;
      5.666501453 1.151684027;
      5.988062236 1.174998556;
      6.401327343 1.223659203;
      6.965856341 1.24734019;
      7.280859687 1.269626893;
      7.484314876 1.282315561;
      7.97646258 1.32208182;
      8.593513446 1.347137578;
      9.062655545 1.389298305;
      9.660146369 1.39894447;
      10.05387638 1.429456387;
      11.53739462 1.492945909;
      12.12825004 1.510124048;
      12.73202698 1.550586148;
      13.12261394 1.565690098;
      13.55248314 1.593808848;
      14.1002833 1.651727413;
      14.49391663 1.692853484;
      15.12367384 1.764818254;
      15.63571527 1.783358157;
      16.31816899 1.837523743;
      16.63313803 1.863576759;
      17.21425553 1.868427809;
      17.50639985 1.877016553;
      17.71981126 1.878064868];

aLi = [100 1.9 5]; % added to constrain the ultimate length 

%% par_txt = {'length at birth'; 'ult length for juv'; ...
%%	   'ult length for ad'; 'age at pubert'; ...
%%	   'von Bert growth for juv'; 'von Bert growth for ad'};
par_txt = {'length at birth'; 'ult length for juv'; ...
	   'ult length for ad'; 'age at pubert'; ...
	   'von Bert growth for juv'; 'von Bert growth for ad'};

p = [.58 1; 1.77 1; 1.90 1; 13 1; .123 0; .285 1];
p = nmregr('bert_pub',p,aL, aLi);
[cov, cor, sd] = pregr('bert_pub', p, aL, aLi);
printpar(par_txt, p, sd);

a = linspace(0,18,100)';
L = bert_pub(p(:,1),a,1);

%% gset term postscript color solid "Times-Roman" 35
%% gset output "Came84.ps"

plot(aL(:,1), aL(:,2), '.g', a, L, 'r')
xlabel('time since birth, a')
ylabel('length, m')
