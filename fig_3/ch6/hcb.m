%% fig:hcb
%% bib:RussGoba89,KooyHare90
%% out:hcbd,hcbw

%% Internal and external concentration of hexachlorobenzene
%%   in Elliptio complanata

%% External (ng cm^-3) at time (h)
tc = [290.29251    0.21487;
      264.32290    0.21177;
      236.81193    0.21311;
      211.46520    0.21435;
      185.51210    0.22929;
      158.01624    0.24789;
      132.66264    0.24178;
      107.93329    0.24316;
      79.78843    0.22780;
      53.08733    0.13049;
      27.70898    0.11256;
      0.24062    0.42894];

%% Internal (mug/g wet weight) at time (h)

tC = [2.6744e-01   1.5922e-04;
      2.7312e+01   1.2157e-01;
      5.2499e+01   2.4755e-01;
      7.7961e+01   4.2788e-01;
      1.0666e+02   3.4282e-01;
      1.3046e+02   3.3748e-01;
      1.5718e+02   6.3945e-01;
      1.8469e+02   6.2897e-01;
      2.0885e+02   8.0802e-01;
      2.3511e+02   7.1760e-01;
      2.6354e+02   6.8433e-01;
      2.8683e+02   6.9132e-01;
      3.1158e+02   6.5580e-01;
      3.3556e+02   7.5589e-01;
      3.5868e+02   3.4700e-01;
      3.8265e+02   3.8002e-01;
      4.0824e+02   3.9109e-01;
      4.2993e+02   3.3540e-01;
      4.5323e+02   2.6482e-01;
      4.7895e+02   1.7550e-01;
      5.0123e+02   1.7364e-01;
      5.2491e+02   1.8256e-01;
      5.5074e+02   7.4790e-02];

global Tc

Tc = knot([0 25 50 100 200 264]', tc); % obtain smoothed concentrations
%% for displaying environmental concentrations:
t = linspace(0,264,100)'; etc = [t, spline(t,Tc)];

nrregr_options('report',1)
p = [6 1; 4.5 1; 264 0];
p = nrregr('accum', p, tC);
[cov cor, sd ssq] = pregr('accum', p, tC);
par_txt = {'elim rate, 1000/h'; 'BCF'; 'accum period, h'};
printpar(par_txt, p(:,1), sd);

t = linspace(0,550,100)'; etC = [t, accum(p(:,1), t)];

%% gset term postscript color solid 'Times-Roman' 35

subplot(1,2,1);
%% gset output 'hcbd.ps'
plot(tc(:,1), tc(:,2), '.g', etc(:,1), etc(:,2),'r')
xlabel('time, h'); ylabel('ng HCB cm^-3');

subplot(1,2,2);
%% gset output 'hcbw.ps'
plot(tC(:,1), tC(:,2), '.g', etC(:,1),etC(:,2), 'r')
xlabel('time, h'); ylabel('mug HCB (g wet weight)^-1');
