%  created at 2002/02/05 by Bas Kooijman
%  Examples of use of 'grpop', 'hapop', 'adpop'
%  Data example from DEBtox

clear all; close all; clc;

t = [0 0.9375 1.8958]'; % d, time
c = [0 0 10 18 32 56 100 180]'; % mug/l, concentration of mixture 
N = [0.4 0.8 0.9 1.1 1.1 1 1.4 1.1; % 1000 cells/ml
     4.9 5.4 6.8 5.4 4.7 5.2 2.8 2.5;
     70.5 77.4 74.5 71.1 64 56.6 6.9 3.9];

 par = [50 60 0.5 2.6]';
 p = nmregr2('grpop',par,t,c,N);
 p = nrregr2('grpop',p,t,c,N);
 shregr2('grpop',p,t,c,N);
 [cov cor sd] = pregr2('grpop',p,t,c,N);

 par = [50 25 0.5 2.6]';
 p = nmregr2('hapop',p,t,c,N);
 p = nrregr2('hapop',p,t,c,N);
 shregr2('hapop',p,t,c,N);
 [cov cor sd] = pregr2('hapop',p,t,c,N);

 par = [51 20 0.5 2.6]';
 p = nmregr2('adpop',par,t,c,N);
 shregr2('adpop',p,t,c,N);
 [cov cor sd] = pregr2('adpop',p,t,c,N);

[p, sd]
