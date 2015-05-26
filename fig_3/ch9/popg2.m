%% fig:popg2
%% bib:RutgTeix87,Tayl78
%% out:RutgTeix87,Tayl78

%% spec growth rate of rods and isomorphs
%%           as a function of substrate concentration

%% Klebsiella aerogenes
Ka = [0.06755911085 0.05836174774;
      0.03524057885 0.1054367736;
      0.09483789986 0.1730465152;
      0.08911767725 0.222123926;
      0.222059293   0.3008496547;
      0.3963843619  0.4244779585;
      0.3737007758  0.4861074683;
      0.54810866    0.518575279;
      0.59899754    0.5510065237;
      0.6517715072  0.5664680814;
      0.8061113033  0.6875642932;
      0.9068013654  0.6983841283;
      1.200583745   0.8010209183;
      1.360238563   0.814866878;
      1.653340463   0.8048212855;
      1.796193111   0.9058860115;
      2.163938128   0.9669519235;
      2.344975289   0.9993479398;
      2.500535126   1.037975023;
      2.968175236   1.040698027;
      3.08897888    1.15116331];

%% Colpidium campylum
Cc = [6.869121545 0.0008958142199;
      10.13875939 0.03339850748;
      10.59630779 0.07756338858;
      15.88355786 0.08180369799;
      20.17978826 0.0957336141;
      16.01305103 0.1125940559;
      24.24911724 0.1038027667;
      23.95238786 0.1108413809;
      31.75168921 0.1172340538;
      30.23680233 0.1643628131;
      37.90567227 0.1624854989;
      43.63466468 0.1467694113;
      43.71213434 0.1301466142;
      43.42003153 0.125542328;
      58.16073881 0.1681192251];


par_txt = {'saturation constant'; 'investment ratio'; ...
	   'scaled length at division'; 'maintenance rate coeff'; ...
	   'aspect ratio'};

nmregr_options('default');
pKa = [1 0; 4.68 1; 0.006 1; 0.001 0; 0.3 0];
pKa = nmregr('rrod', pKa, Ka);
[cor cov sd ssq] = pregr('rrod', pKa, Ka);
printpar(par_txt, pKa, sd);
qKa = nmregr('rV1', pKa(1:4,:), Ka);

X1 = linspace(1e-3, 3.2, 100)'; % set glucose conc for plotting
eKa = rrod(pKa(:,1), X1); EKa = rV1(qKa(:,1), X1);

par_txt = {'saturation constant'; 'investment ratio'; ...
	   'scaled length at division'; 'maintenance rate coeff'};

pCc = [27 1; .2 0; 0.2 0; 0.26 1];
pCc = nmregr('riso', pCc, Cc);
[cor cov sd ssq] = pregr('riso', pCc, Cc);
printpar(par_txt, pCc, sd);
%% nmregr_options('report',1);
qCc = nmregr('rV1', pCc(1:4,:), Cc);

X2 = linspace(1e-3, 60, 100)'; % set food density for plotting
eCc = riso(pCc(:,1), X2); ECc = rV1(qCc(:,1), X2);

%% gset term postscript color solid 'Times-Roman' 35

subplot(1,2,1)
plot(X1, EKa, '-b', ...
     X1, eKa, '-r', ...
     Ka(:,1), Ka(:,2), '.g')
legend('V1-morph', 'rod', 4);
title('Klebsiella aerogenes (dividing rod)')
xlabel('glucose, mg/l')
ylabel('pop growth rate, 1/h')

subplot(1,2,2);
plot(X2, ECc, '-b', ...
     X2, eCc, '-r', ...
     Cc(:,1), Cc(:,2), '.g') 
legend('V1-morph', 'isomorph', 4)
title('Colpidium campylum (dividing isomorph)')
xlabel('Enterobacter aerogenes, 10^6 cells/ml')
ylabel('pop growth rate, 1/h')
