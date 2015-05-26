%% fig:prof
%% out:prof_social,prof_solitary

%% enzyme excretion 2005/06/18

%% set parameters: 4-par problem
%% depth of spatial cells: unit length
%% no depletion of substrate
JE = 1;     % mol/t excretion rate of enzymes (def of time unit)
DE = 0.03;  % l^2/t diffusion rate of enzymes 
DP = 0.03;  % l^2/t diffusion rate of metabolites
kE = 0.01;  % 1/t decay rate of enzymes
kP = 0.01;  % 1/t spec production rate of metabolites
k  = 20;    % 1/t spec uptake rate of metabolites JPm/K
dL = .15;    % l, depth of spatial cell
LR = .5;    % l, radius of cell
%% if k is high, its value does not matter
par = [k kE kP DE DP JE dL LR];

%% gset term postscript color solid  "Times-Roman" 35

shdiffu(50,par) %% produces plots!

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%33

hold on
subplot(1,3,1)
%% gset term postscript color solid  "Times-Roman" 35
%% gset output 'prof_social.ps'
for i = 2:nt
  plot(L, nEP(i,1:n)', 'r', L, nEP(i,(n+1):(2*n))', 'g')
end
nPi = JE * kP * LE/ (kE * DP);
plot(L, exp(-(L - LR)/ LE) * JE/ (kE * LE),'m', ...
     L, (1 - exp(-(L - LR)/LE)) * nPi, 'b')
xlabel('distance') 
ylabel('conc enzyme/metabolites')
  
subplot(1,3,2)
%% gset output 'prof_yield.ps'
plot(t, k * dL * nEP(:, n + 1)/ JE,'g', ...
     [0;t(nt)], [kP/kE; kP/kE],'r', ...
     t, k * dL * nEPF(:, n + 1)/ JE, 'b')
xlabel('time') 
ylabel('y_{PE}')

subplot(1,3,3)
%% gset output 'prof_solitary.ps'
for i = 2:nt
  plot(L, nEPF(i,1:n)', 'r', L, nEPF(i,(n+1):(2*n)), 'g')
end
  nE = (LR^2 ./ (L * (LR + LE))) .* exp((LR - L)/ LE) * JF/ (kE * LE);
  nP = (kP/ kE) * (DE/ DP) * (JF * LE * LR ./ (DE * (LE + LR)) - nE);
  plot(L, nE, 'm', L, nP, 'b') 
xlabel('distance') 
ylabel('conc enzyme/metabolites')









