%% fig:Droo74
%% bib:Droo74
%% out:Droo74e1,Droo74e2,Droo74x1,Droo74x2,Droo74mv

%% Simultaneous limitation by PO4 and vit B12 of Pavlova lutheri

%% Prefixes: mu = 10^-3, p = 10^-12, f = 10^-15
%% Xr_PO4, X_PO4: muM       Xr_B12, X_B12: pM
%% q_PO4: fmol/cell         q_B12: 10^-21 mol/cell
%% MV: 10^6 cell/ml = 10^9 cell/l
%% r: 1/d

%% Xr_PO4 Xr_B12 r MV q_PO4 q_B12 X_PO4 X_B12
data = [ ...
 1.44 68   0.633 1.48  0.916 39    -0.0138 6.28;
 1.44 68   0.65  1.62  0.733 38.5   0.247   5.5;
 1.44 68   0.724 1.35  0.93  45.7   0.179   6.15;
 1.44 68   0.752 1.4   0.967 43.8   0.0812  6.57;
 1.44 68   0.8   1.03  1.26  58.5   0.144   7.77;
 1.44 68   0.855 0.939 1.47  67     0.059   5.13;
 1.44 68   0.162 3.01  0.44  19.4   0.114   9.6;
 1.44 68   0.175 2.65  0.433 21.8   0.29   10.2;
14.4   6.8 0.694 1.18  5.16   5.14  8.27    0.728;
14.4   6.8 0.719 1.05  4.93   6.1   9.21    0.415;
14.4   6.8 0.774 0.804 5.87   7.21  9.65    1;
14.4   6.8 0.754 0.97  5.21   6.03  9.31    0.949;
14.4   6.8 0.862 0.812 6.39   7.63  9.18    0.603;
14.4   6.8 0.871 0.719 6.92   7.88  9.4     1.14;
14.4   6.8 0.858 0.728 5.83   8.48 10.1     0.633;
14.4   6.8 0.211 1.94  3.39   2.95  7.78    1.06;
14.4   6.8 0.219 1.87  3.25   3.05  8.29    1.09;
 1.44 20.4 0.458 1.97  0.664  8.81  0.127   3.01;
 1.44 20.4 0.452 1.97  0.695  8.58  0.0656  3.45;
 1.44 20.4 0.459 2.24  0.584  8.38  0.13    1.63;
 1.44 20.4 0.475 2.16  0.637  7.74  0.0574  3.65;
 1.44 20.4 0.591 1.67  0.803 10.4   0.0954  3;
 1.44 20.4 0.587 1.57  0.815 11.2   0.155   2.79;
 1.44 20.4 0.586 1.66  0.818 10.8   0.0781  2.42;
 1.44 20.4 0.704 1.43  0.917 12.6   0.124   2.38;
 1.44 20.4 0.709 1.23  1.06  15     0.128   1.91;
 1.44 20.4 0.705 1.31  1.04  12.5   0.0678  3.96;
 1.44 20.4 0.644 1.38  1.02  13.6   0.0256  1.61;
 1.44 20.4 0.116 2.77  0.496  6.21  0.0663  3.23;
 1.44 20.4 0.123 3.39  0.398  5.08  0.0885  3.19;
 1.44  6.8 0.559 1.12  1.17   5.35  0.122   0.804;
 1.44  6.8 0.546 1.28  1.11   4.65  0.0195  0.87;
 1.44  6.8 0.572 1.37  0.965  4.5   0.11    0.619;
 1.44  6.8 0.531 1.11  1.17   5.38  0.141   0.856;
 1.44  6.8 0.518 1.2   1.18   4.92  0.0277  0.909;
 1.44  6.8 0.644 1.14  1.21   5.35  0.0539  0.682;
 1.44  6.8 0.643 1.06  1.26   5.84  0.101   0.619;
 1.44  6.8 0.642 1.04  1.36   5.74  0.0276  0.848;
 1.44  6.8 0.729 1.03  1.16   5.76  0.238   0.841;
 1.44  6.8 0.76  0.749 1.86   8.18  0.0449  0.674;
 1.44  6.8 0.763 0.798 1.76   7.76  0.036   0.612;
 1.44  6.8 0.73  0.829 1.43   7.58  0.263   0.563;
 1.44  6.8 0.14  1.86  0.713  2.88  0.113   1.45;
 1.44  6.8 0.134 2.02  0.626  2.63  0.169   1.47];

%% reformat data to meet requirements for regression routines
global data1 data2 data3 data4

data1 = data( 1: 8, [3 4 7 8 5 6]);
data2 = data( 9:17, [3 4 7 8 5 6]);
data3 = data(18:30, [3 4 7 8 5 6]);
data4 = data(31:44, [3 4 7 8 5 6]);

%% make sure that biomass data fit well
rMV1 = [data1(:, [1 2]), 10*ones(8,1)];
rMV2 = [data2(:, [1 2]), 10*ones(9,1)];
rMV3 = [data3(:, [1 2]), 10*ones(13,1)];
rMV4 = [data4(:, [1 2]), 10*ones(14,1)]; 

rXP1 = data1(:, [1 3]);
rXP2 = data2(:, [1 3]);
rXP3 = data3(:, [1 3]);
rXP4 = data4(:, [1 3]);

%% less weight because of gaps in B12-balance
rXB1 = [data1(:, [1 4]), .01*ones(8,1)];
rXB2 = [data2(:, [1 4]), .01*ones(9,1)];
rXB3 = [data3(:, [1 4]), .01*ones(13,1)];
rXB4 = [data4(:, [1 4]), .01*ones(14,1)];

%% less weight because of large numbers
rqP1 = [data1(:, [1 5]), .5*ones(8,1)];
rqP2 = [data2(:, [1 5]), .5*ones(9,1)];
rqP3 = [data3(:, [1 5]), .5*ones(13,1)];
rqP4 = [data4(:, [1 5]), .5*ones(14,1)];

%% less weight because of large numbers
rqB1 = [data1(:, [1 6]), .5*ones(8,1)];
rqB2 = [data2(:, [1 6]), .5*ones(9,1)];
rqB3 = [data3(:, [1 6]), .5*ones(13,1)];
rqB4 = [data4(:, [1 6]), .5*ones(14,1)];

%% conc of PO4 and B12 in the feed
global Xr
Xr = [1.44 68; 14.4 6.8; 1.44 20.4; 1.44 6.8];

%% parameters:
KP = 0.017;   % muM, saturation constant for PO4
KB = 0.12;    % pM, saturation constant for B12
jPAm = 4.91;  % fmol/cell.d, max spec assim of P
jBAm = 76.6;  % 10^-21 mol/cell.d, max spec assim of B
kP = 1.19;    % 1/d, reserve PO4 turnover
kB = 1.22;    % 1/d, reserve B12 turnover
kMP = 0.0079; % 1/d, maintenance rate coeff from EP
kMB = 0.135;  % 1/d, maintenance rate coeff from EB
yPV = 0.39;   % fmol/cell, yield of P on V
yBV = 2.35;   % 10^-21 mol/cell, yield of B on V
kapP = 0.69;  % -, recovery fraction of rejected EP
kapB = 0.96;  % -, recovery fraction of rejected EB

%% pack parameters and assign fix
p = [KP   0; KB   0;  ...
     jPAm 1; jBAm 0;  ...
     kP   1; kB   1;  ...
     kMP  1; kMB  1;  ...
     yPV  1; yBV  1;  ...
     kapP 1; kapB 1];

%% re-estimate parameter values
nrregr_options('max_step_number', 20);
nrregr_options('max_step_size', .01);
p = nrregr ('pavlova', p, rMV1, rMV2, rMV3, rMV4, ...
	    rXP1, rXP2, rXP3, rXP4, rXB1, rXB2, rXB3, rXB4, ...
	    rqP1, rqP2, rqP3, rqP4, rqB1, rqB2, rqB3, rqB4);  

%% get sd
[cov, cor, sd, ssq] = pregr('pavlova', p, rMV1, rMV2, rMV3, rMV4, ...
	    rXP1, rXP2, rXP3, rXP4, rXB1, rXB2, rXB3, rXB4, ...
	    rqP1, rqP2, rqP3, rqP4, rqB1, rqB2, rqB3, rqB4);  

%% set parameter text
par_txt = {'KP'; 'KB'; 'jPAm'; 'jBAm'; 'kP'; 'kB'; 'kMP'; 'kMB'; ...
     'yPV'; 'yBV'; 'kapP'; 'kapB'}; 
printpar(par_txt, p(:,1), sd); % display results

%% prepare for graphs
r = linspace(1e-3, 1, 100)';
[MV1, MV2, MV3, MV4, XP1, XP2, XP3, XP4, XB1, XB2, XB3, XB4, ...
 qP1, qP2, qP3, qP4, qB1, qB2, qB3, qB4] = pavlova ...
    (p(:,1), r, r, r, r, r, r, r, r, r, r, r, r, r, r, r, r, r, r, r, r);

subplot(2,3,1); 
plot(rqP1(:,1), rqP1(:,2), '.r', ...
     rqP2(:,1), rqP2(:,2), '.m', ...
     rqP3(:,1), rqP3(:,2), '.b', ...
     rqP4(:,1), rqP4(:,2), '.k', ...
     r, qP1, '-r', r, qP2, '-m', r, qP3, '-b', r, qP4, '-k');
xlabel('throughput rate, 1/d');
ylabel('P content, fmol/cell');

subplot(2,3,2); 
plot(0, 0, '-r', 0, 0, '-m', 0, 0, '-b', 0, 0, '-k');
axis off;
legend(' 1.44, 68  ', '14.4 ,  6.8', ' 1.44, 20.4', ' 1.44,  6.8');
title('muM PO4, pM B12');

subplot(2,3,3); 
plot(rqB1(:,1), rqB1(:,2), '.r', ...
     rqB2(:,1), rqB2(:,2), '.m', ...
     rqB3(:,1), rqB3(:,2), '.b', ...
     rqB4(:,1), rqB4(:,2), '.k', ...
     r, qB1, '-r', r, qB2, '-m', r, qB3, '-b', r, qB4, '-k');
xlabel('throughput rate, 1/d');
ylabel('B12 content, 10^-21 mol/cell');

subplot(2,3,4); 
plot(rXP1(:,1), rXP1(:,2), '.r', ...
     rXP2(:,1), rXP2(:,2), '.m', ...
     rXP3(:,1), rXP3(:,2), '.b', ...
     rXP4(:,1), rXP4(:,2), '.k', ...
     r, XP1, '-r', r, XP2, '-m', r, XP3, '-b', r, XP4, '-k');
xlabel('throughput rate, 1/d');
ylabel('P conc, mumol/l');

subplot(2,3,5); 
plot(rMV1(:,1), rMV1(:,2), '.r', ...
     rMV2(:,1), rMV2(:,2), '.m', ...
     rMV3(:,1), rMV3(:,2), '.b', ...
     rMV4(:,1), rMV4(:,2), '.k', ...
     r, MV1, '-r', r, MV2, '-m', r, MV3, '-b', r, MV4, '-k');
xlabel('throughput rate, 1/d');
ylabel('biomass, 10^6 cells/ml');

subplot(2,3,6); 
plot(rXB1(:,1), rXB1(:,2), '.r', ...
     rXB2(:,1), rXB2(:,2), '.m', ...
     rXB3(:,1), rXB3(:,2), '.b', ...
     rXB4(:,1), rXB4(:,2), '.k', ...
     r, XB1, '-r', r, XB2, '-m', r, XB3, '-b', r, XB4, '-k');
xlabel('throughput rate, 1/d');
ylabel('B12 conc, pmol/l');