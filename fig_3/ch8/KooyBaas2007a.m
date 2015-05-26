%% fig:KooyBaas2007a
%% bib:KooyBaas2007,Gerr97
%% out:KooyBaas2007a

%% log  NEC vs kr for aldehydes, alifatic compounds and biocyds

Pealdehyd = [ ...
1.34870449e+000	-6.43834585e-001
1.38907580e+000	-1.01899920e+000
1.61659496e+000	-1.54606049e+000
2.25853289e+000	-2.78205567e+000
3.21261147e+000	-3.07706725e+000
1.07063586e+000	-9.70621893e-001
2.60486969e+000	-1.21188780e+000
1.62329766e+000	-7.36710324e-001];

Pealifat =[ ...
4.57308500e-001	2.20099081e-001
4.84057207e-001	-4.99946161e-002
6.13363310e-001	-1.86282704e-001
1.08897517e+000	-5.06150102e-001
2.04988057e+000	2.31764476e-002
1.93481769e+000	1.29333449e-001
2.99837357e+000	-9.46293600e-001
2.70730296e+000	-1.09307016e+000
2.48682783e+000	-1.46544199e+000
3.51991129e+000	-2.72061432e+000
2.51022519e+000	-2.14021077e+000
2.27774107e+000	-2.21266812e+000
3.69874284e+000	-3.87670471e+000
1.50140796e+000	-1.45489145e+000];

Pebiocyd =[ ...
3.61849672e+000	-3.06642362e+000
3.15228724e+000	-3.36121798e+000
3.67075289e+000	-3.75649067e+000
5.16669448e+000	-5.12154373e+000
2.33831355e+000	-1.89854145e+000
2.28146479e+000	-1.76302914e+000
1.80498406e+000	-1.54807750e+000
1.71902824e+000	-1.42724284e+000
1.42696463e+000	-1.69392313e+000
1.35550028e+000	-1.57324363e+000
-5.33683743e-002 -1.94133544e-001
-1.84908708e-001 -3.27628843e-001
-7.57988887e-001 4.72939551e-001
2.85814456e+000 -2.12894652e+000
2.81442191e+000 -2.15845699e+000
2.65228503e+000 -2.48648553e+000];

nrregr_options('default');

paldehyd = nrregr('linear',[1 1; -1 0],Pealdehyd);
palif =  nrregr('linear',[1 1; -1 0],Pealifat);
pbiocyd =  nrregr('linear',[1 1; -1 0],Pebiocyd);
		
P = [-1;6];
EPaldehyd = [P, linear(paldehyd(:,1),P)];
EPalif = [P, linear(palif(:,1),P)];
EPbiocyd = [P, linear(pbiocyd(:,1),P)];

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'KooyBaas2007a.ps'

plot(Pealdehyd(:,1), Pealdehyd(:,2), '.g', ...
    Pealifat(:,1), Pealifat(:,2), '.b', ...
    Pebiocyd(:,1), Pebiocyd(:,2), '.m', ...
    EPaldehyd(:,1), EPaldehyd(:,2), 'g', ...
    EPalif(:,1), EPalif(:,2), 'b', ...
    EPbiocyd(:,1), EPbiocyd(:,2), 'm')
legend('aldehydes','alifates', 'biocides')
xlabel('log killing rate');
ylabel('log No Effect Concentration');
