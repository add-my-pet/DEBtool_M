%% Parameters for 'symbi'
%%
%% Control-parameters: throughput rate h, concentrations in the feed
%%   of nitrogen X_RN, and substrate X_R

global k_EA k_EH j_EN_M j_EC_M j_E_M j_EN_Am j_EN_Am j_E_ANm ...
    j_EC_Am j_E_AXm j_E_AVm j_E_AEm K_NA K_NH b_X b_VA b_EN ...
    b_EC y_E_X y_E_VA y_E_V y_EC_V y_E_EN y_E_EC n_N_E n_N_VA ...
    n_N_VH n_N_X kap_EN kap_EC h X_R X_RN;

h = 0.05;      % spec throughput rate of the chemostat 
X_R = 100;     % conc substrate in feed
X_RN = 0.001;  % conc nitrogen in feed

k_EA = 0.3; % voorraad-turnover in autotroof 
k_EH = 0.2; % voorraad-turnover in heterotroof

j_EN_M = 0.001; % spec N-maintenance costs in autotroph
j_EC_M = 0.01;  % spec CH-maintenance costs in autotroph
j_E_M = 0.01;   % spec maintenance costs in heterotroph
j_EN_Am = 0.1;  % max spec N-uptake in autotroph
j_E_ANm = 0.3;  % max spec N-uptake in heterotroph
j_EC_Am = 1;    % max spec C-reserve-synthesis by autotroph
j_E_AXm = 1;    % max spec reserve-synthesis from substrate by heterotroph
j_E_AVm = .5;   % max spec reserve-synthesis from autotrophic-structure by heterotroph 
j_E_AEm = 0.5;  % max spec reserve-synthesis from N and CH by heterotroph

K_NA = 0.1; % N-saturation constant for autotroph
K_NH = 0.5; % N-saturation constant for heterotroph

b_X = 0.05;    % transport-rate and binding of substrate by heterotroph
b_VA = 0.0001; % transport-rate and binding of autotrophic-structure by
               % heterotroph
b_EN = 0.01;   % transport-rate and binding of nitrogen by heterotroph
b_EC = 0.001;  % transport-rate and binding of carbohydrate by
               % heterotroph 

y_E_X = 0.5;  % yield-coefficient: heterotroph-reserves  <- substrate 
y_E_VA = 0.4; % yield-coefficient: heterotroph-reserves  <- autotroph-structure 

y_E_V = 1.2;  % yield-coefficient: heterotroph-reserves <- heterotroph-structure 
y_EC_V = 1.5; % yield-coefficient: autotroph-C-reserves <- autotroph-structure 
y_E_EN = 0.15;% yield-coefficient: heterotroph-reserves <- nitrogen 
y_E_EC = 0.6; % yield-coefficient: heterotroph-reserves <- carbohydrate

n_N_E = 0.2;  % nitrogen/carbon-ratio in heterotroph-reserves
n_N_VA = 0.1; % nitrogen/carbon-ratio in autotroph-structure 
n_N_VH = 0.2; % nitrogen/carbon-ratio in heterotroph-structure 
n_N_X = 0.2;  % nitrogen/carbon-ratio in substrate
    
kap_EN = 0.7;% fraction of not-processed N-reserve which is fed back to reserve
	     % the remaining fraction is excreted
kap_EC = 0.9;% fraction of not-processed C-reserve which is fed back to reserve
	     % the remaining fraction is excreted
