%% fig:mcn
%% bib:Oppe86,KooyHare90
%% out:mcnd,mcnw

%% Internal and external concentration of 2-monochloronaphthalene
%%   in Poecilia reticulosa

%% External (mug cm^-3) at time (h)

tc = [ 24 0.359199;
       48 0.278800;
       72 0.234401;
       96 0.188601;
      168 0.068600];

%% Internal (mug/g wet weight) at time (h)
tC=[ 24   1.0040e-01;
     48   5.1300e-01;
     72   4.6950e-01;
     96   4.6750e-01;
    168   3.4500e-01;
    240   1.0740e-01;
    360   2.1401e-02;
    600   3.8504e-03];
   
global Tc

Tc = knot([0 40 80 120 160]', tc); % obtain smoothed concentrations
%% for displaying environmental concentrations:
t = linspace(0,170,100)'; etc = [t, spline(t,Tc)];

nrregr_options('report',0)
p = [13 1; 2.4 1; 168 0];
p = nrregr('accum', p, tC);
[cov cor, sd ssq] = pregr('accum', p, tC);
par_txt = {'elim rate, 1000/h'; 'BCF'; 'accum period, h'};
printpar(par_txt, p(:,1), sd);
nrregr_options('report',1)

t = linspace(0,600,100)'; etC = [t, accum(p(:,1), t)];

subplot(1,2,1);
plot(tc(:,1), tc(:,2), '.g', etc(:,1), etc(:,2), '-r');
xlabel('time, h'); ylabel('mug 2-MCN cm^-3');

subplot(1,2,2);
plot(tC(:,1), tC(:,2), '.g', etC(:,1), etC(:,2), '-r');
xlabel('time, h'); ylabel('mg 2-MCN (g wet weight)^-1');
