%% fig:ass; ass.eps
%% bib:BaynHawk87,BaynHawk89,Borc85,HawkBayn84,KiorMohl81,HareKooy93
%% out:ass

%% assimilation as function of ingestion in Mytilus edulis

%% diamond
ia1= [0.36242   3.93610;
      0.44993   5.52583;
      0.41272   5.87319;
      0.49832   5.94812;
      0.78017   9.61336;
      0.83128  11.67749];

%% box
ia2 = [0.99592  10.10863;
       0.88126  10.19713;
       0.61756   6.89509;
       0.67189   7.22887;
       0.41011   5.24490;
       0.51370   6.25689];

%% triang-up
ia3 = [0.026251  0.405507;
       0.039584  0.544818;
       0.059167  0.667823;
       0.088750  0.834137;
       0.133333  1.025827;
       0.199999  1.429132];

%% triang-down
ia4 = [0.171803  1.848429;
       0.109108  1.550407;
       0.074152  1.159056];

%% cross
ia5 = [0.31284  3.09001;
       0.42537  3.93516;
       0.55616  4.88517];

ia = [ia1; ia2; ia3; ia4; ia5];

%% gset term postscript color solid 'Times-Roman' 35
%% gset output 'ass.ps'

nrregr_options('report',0);
p = nrregr('linear', [0 0; 1 1], ia);
[cov cor sd] = pregr('linear', p, ia);
printpar({'prop constant'}, p(2,1), sd(2));
ing = [0 1.1]';
assim = linear(p(:,1), ing);
nrregr_options('report',1);

plot(ia1(:,1), ia1(:,2), '.g', ...
    ia2(:,1), ia2(:,2), '.b', ...
    ia3(:,1), ia3(:,2), '.m', ...
    ia4(:,1), ia4(:,2), '.y', ...
    ia5(:,1), ia5(:,2), '.c', ...
    ing, assim, 'r')
xlabel('ingestion rate, mg POM/h')
ylabel('assimilation rate, J/h')
