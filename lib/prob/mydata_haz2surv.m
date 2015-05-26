global par % for parameter transfer to function that specifies hazard rate

% set par
  cA = 1; % mM, external conc for compound A
  cB = 2; % mM, external conc for compound B
  kA = .02; % 1/d, elimination rate for A
  kB = .04; % 1/d, elimination rate for B
  BCFA = 5; % l/C-mol, BCF for A
  BCFB = 10; % l/C-mol, BCF for B
  Q0 = .1; % mmol/C-mol, internal NEC
  bA = .5; % C-mol/mmol.d, killing rate for A
  bB = .1; % C-mol/mmol.d, killing rate for B
  par = [cA cB kA kB BCFA BCFB Q0 bA bB]'; % pack parameters
t = linspace(0,21,100)'; % set time points
S = haz2surv('haz_AB',t); % obtain time, survival probabilities

% plot it
xlabel('time, d')
ylabel('survival probability')
plot (t, S, 'r')