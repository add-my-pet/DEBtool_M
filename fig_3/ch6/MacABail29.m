%% fig:MacABail29
%% bib:MacABail29
%% out:macabail29_al,macabail29_as

%% length and hazard rates of males and females D. magna

%% age and length of females
aLF = [ 0.544771453 0.7244883261;
	5.561212068 1.715405949;
	7.556335739 2.007877857;
	13.57290008 3.114594208;
	27.3461404  3.851026544;
	34.07530396 4.290242314;
	59.74547109 4.658982601;
	86.47530692 5.035983617;
       103.3745603  5.226993726];

aSF =	[1  1;
	 8  0.911;
	 15 0.889;
	 22 0.795;
	 29 0.665;
	 36 0.584;
	 43 0.431;
	 50 0.346;
	 57 0.258;
	 64 0.146;
	 71 0.115;
	 78 0.070;
	 85 0.035;
	 92 0.001;
	 99 0.000];

%% age and length of males
aLM = [ 0.35769396  0.7818913724;
        7.702727101 1.934972266;
       13.19067059  2.109816734;
       27.74414296  2.5842522;
       60.02645776  2.693297154];

%% age and survival fractions of males
aSM = [  1 1;
	 8 0.991;
	15 0.949;
	22 0.870;
	29 0.677;
	36 0.414;
	43 0.263;
	50 0.076;
	57 0.061;
	64 0.044;
	71 0.018;
	78 0.007;
	85 0.003;
	92 0.000];

aSF= [aSF, 5*ones(15,1)];

nrregr_options('report',1);
nmregr_options('max_step_number',500);
%% nrregr_options('max_step_size',1e-6);
Lb = .82;
gF = .169;
gM = .308;
kM = 1;
v = .862;
ha = .00093;
sG = -.5;
p = [Lb 0; gF 0; gM 0; kM 0; v 0; ha 1; sG 0];

nrregr_options('report',1);
p = nmregr('bertLS_fm', p, aLF, aLM, aSF, aSM);
[cov cor sd ssq] = pregr('bertLS_fm', p, aLF, aLM, aSF, aSM);
nm = {'birth length Lb'; 'female energy invest g';
      'male energy invest g'; 'maint rate coeff kM';
      'energy conductance v'; 'aging acceleration h_a';
      'Gompertz coefficient s_G'};
printpar(nm,p(:,1),sd);

a = linspace(0,105,100)';
[LFS, LMS, SF, SM] = bertLS_fm(p(:,1), a, a, a, a);

%% gset term postscript color solid 'Times-Roman' 35

subplot(1,2,1); 
%% gset output 'macabail29_al.ps'
plot(a, LFS, 'r', a, LMS, 'b', ...
    aLF(:,1), aLF(:,2), '.r', aLM(:,1), aLM(:,2), '.b')
legend('female', 'male')
xlabel('age, d')
ylabel('length, mm')

subplot(1,2,2); 
%% gset output 'macabail29_as.ps'
plot(a, SF, 'r', a, SM, 'b', ...
     aSF(:,1), aSF(:,2), '.r', aSM(:,1), aSM(:,2), '.b');
legend('female', 'male')
xlabel('age, d')
ylabel('survival fraction')
