%% shssd_iso
% Plots population characteristics against the (constant) scaled functional response

%%
function shssd_iso(p)
  % created 2009/09/30 by Bas Kooijman
  
  %% Description
  %  shows population statistics as function of scaled functional response
  
  %% Syntax
  % <../shssd_iso.m *shssd_iso*>(p)
  
  %% Description
  % Plots population characteristics against the (constant) scaled functional response. 
  % The specific population growth rate is obtained from the characteristic equation; age zero is the start of development. 
  % The mean age, length, squared and cubed length only applies to juveniles and adults, excluding embryos. 
  % For input parameters see sgr_iso. 
  %
  % Input
  %
  %  p:  11-vector with kap; kapR; g; kJ; kM; LT; v; UHb; UHp; ha; sG;
  %
  % Output
  %
  % * fig 1: Specific growth rate as function of scaled functioanl response
  % * fig 2: Mean age as function of scaled functioanl response
  % * fig 3: Mean length as function of scaled functioanl response
  % * fig 4: Mean squared length as function of scaled functioanl response
  % * fig 5: Mean cubed length as function of scaled functioanl response
  
  %% Example of use
  % shssd_iso([.8 .95 .2 .002 .02 0 .2 .02 .3 1e-8 1e-4]) 

[f0 info] = f_ris0 (p); % f at which r = 0
if info ~= 1
    fprintf('warning: no convergence for f0\n')
end

f = linspace(f0 + 1e-3,1, 100)'; n = length(f);
r = zeros(n,1); 
Ea = zeros(n,1); 
EL = zeros(n,1); 
EL2 = zeros(n,1); 
EL3 = zeros(n,1); 

for i = 1:n
 [r(i) Ea(i) EL(i) EL2(i) EL3(i) info] = ssd_iso(p, f(i));
 if info ~= 1
    fprintf(['warning: no convergence for r = ', num2str(r(i)),' at i = ', num2str(i), '\n'])
 end
end

figure
plot(f,r,'r')
xlabel('scaled functional response f')
ylabel('spec population growth rate')

figure
plot(f,Ea,'r')
xlabel('scaled functional response f')
ylabel('mean age')

figure
plot(f,EL,'r')
xlabel('scaled functional response f')
ylabel('mean length')

figure
plot(f,EL2,'r')
xlabel('scaled functional response f')
ylabel('mean squared length')

figure
plot(f,EL3,'r')
xlabel('scaled functional response f')
ylabel('mean cubed length')