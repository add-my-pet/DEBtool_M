%% fig:RobeSalt81
%% bib:RobeSalt81
%% out:RobeSalt81,RobeSalt81v

%% hazard at age and ultimate volume against feeding rate

VI = [ 20 10.11953216;
       30 11.17934286;
       60 11.87800004;
      120 13.59132125;
      240 14.81192249];

H1 = [ 0 0;
       6 0.008564580142;
       7 0.03288810977;
       9 0.0344916583;
      10 0.09409616713;
      11 0.09033153208;
      12 0.06945349779;
      13 0.2704373785;
      14 0.2962141926;
      15 0.5115905768];

H2 = [ 0 0;
       3 0.00187678658;
       4 0.089089503;
       5 0.0112722762;
       6 0.009367522909;
       7 0.04538283467;
       8 0.04284989007;
       9 0.2390442772;
      10 0.2549542847;
      11 0.3170322728;
      12 0.4532417775];

H3 =  [ 0 0;
        2 0.007416731109;
        3 0.07632572146;
        4 0.03734830796;
        5 0.09492400183;
        6 0.0683207866;
        8 0.09925647805;
        9 0.134395499;
       10 0.1898893893;
       11 0.1564797584;
       12 0.3197496909;
       13 0.3066259534;
       14 0.4721616255];

H4 =  [ 0 0;
        3 0.001007997281;
        4 0.03988572812;
        8 0.3793837998;
        9 0.2900207967;
       10 0.4634737095];

H5 = [0  0;
      1 -0.006089002902;
      3  0.029393833;
      4  0.1345091894;
      5  0.3675159692;
      6  0.4499241649;
      7  0.6832498167];

V1 = [1 4.247539783;
      2 5.037146685;
      3 5.482052703;
      4 6.576576915;
      5 7.220922373;
      6 8.285218682;
      7 8.287263078;
      8 8.427331734;
      9 8.689431272];

V2 = [1  5.049656606;
      2  6.885202253;
      3  8.415191007;
      4  9.486724501;
      5  9.86273831;
      6  9.782135659;
      7 10.44883225];

V3 = [1  6.546733479;
      2  8.847731727;
      3 11.0196218;
      4 11.99131566;
      5 12.55961167;
      6 13.39448048;
      7 13.56453719];

%% volume at age for 3 food levels
nrregr_options('report',0);
pV = [1 1; 8 1; 11 1; 15 1; 3 1; 5 0; 1 0]; 
pV = nrregr('bertV', pV, V1, V2, V3);
aV = linspace(0,9.5,100)'; [v1 v2 v3] = bertV(pV(:,1), aV, aV, aV);

%% ultimate volume at feeding level
pX = [14, 10]'; pX = nrregr('hyp', pX, VI);
X = linspace(0,250,100)'; vi = hyp(pX(:,1), X);

%% hazard rate at age for 5 food levels
kM = pV(5,1); v = pV(6,1); Vb = pV(1,1); a = linspace(0, 16, 100)';
H = VI; % initiate data for aging accelerations

Vi = VI(1,2); Li = Vi^(1/3) ; rB =  1/ (3/ kM + 3 * Li/ v);
p = [Vb 0; Vi 0; rB 0; kM 0; .0015 1]; p = nmregr('bertLh', p, H1);
h1 = bertLh(p(:,1), a); H(1,2) = p(5,1);


Vi = VI(2,2); Li = Vi^(1/3) ; rB =  1/ (3/ kM + 3 * Li/ v);
p = [Vb 0; Vi 0; rB 0; kM 0; 2e-3 1]; p = nrregr('bertLh', p, H2);
h2 = bertLh(p(:,1), a); H(2,2) = p(5,1);

Vi = VI(3,2); Li = Vi^(1/3) ; rB =  1/ (3/ kM + 3 * Li/ v);
p = [Vb 0; Vi 0; rB 0; kM 0; 2e-3 1]; p = nrregr('bertLh', p, H3);
h3 = bertLh(p(:,1), a); H(3,2) = p(5,1);

Vi = VI(4,2); Li = Vi^(1/3) ; rB =  1/ (3/ kM + 3 * Li/ v);
p = [Vb 0; Vi 0; rB 0; kM 0; 4e-3 1]; p = nrregr('bertLh', p, H4);
h4 = bertLh(p(:,1), a); H(4,2) = p(5,1);

Vi = VI(5,2); Li = Vi^(1/3) ; rB =  1/ (3/ kM + 3 * Li/ v);
p = [Vb 0; Vi 0; rB 0; kM 0; 1e-2 1]; p = nrregr('bertLh', p, H5);
h5 = bertLh(p(:,1), a); H(5,2) = p(5,1);

%% fit linear relationship between aging acceleration and feeding level
pH = nrregr('linear', [5e-4 0;1 1], H);
XH = [0 250]'; HH = linear(pH(:,1), XH);

nrregr_options('report',1);

%% gset term postscript color solid 'Times-Roman' 35
subplot(1,3,1);
plot(V1(:,1), V1(:,2), '.r', V2(:,1), V2(:,2), '.g', V3(:,1), V3(:,2), '.b', ...
     aV, v1, '-r', aV, v2, '-g', aV,v3, '-b'); 
title('size in A. girodi');
xlabel('age, d');
ylabel('volume, 10^-12 m^3');

subplot(1,3,2);
plot(a, h1, '-r', a, h2, '-g', a, h3, '-b', a, h4, '-m', a, h5, '-k', ...
     H1(:,1), H1(:,2), '.r', H2(:,1), H2(:,2), '.g', H3(:,1), H3(:,2), '.b', ...
     H4(:,1), H4(:,2), '.m', H5(:,1), H5(:,2), '.k');
axis([0, 15, 0, 1]);
legend('20', '30', '60', '120', '240'); % legend gives 'paramecia d^-1'
title('death rate in A. girodi');
xlabel('age, d');
ylabel('hazard rate, 1/d');

subplot(1,3,3);
plot(X, vi, '-r', XH, 1000 * HH, '-g', ...
     VI(:,1), VI(:,2), '.r', H(:,1), 1000 * H(:,2), '.g'); 
legend('ultimate volume', 'aging accel.');
title('size & death rate in A. girodi')
xlabel('paramecia (rotifer d)^-1')
ylabel('ultimate volume, 10^-12 m^3, 1000 * aging acceleration, d^-2')
