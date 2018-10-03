% plots the profile of the loss function for a parameter
% plots the distribution function of the loss function of Monte Carlo
% simulations
% gives the confidence interval of the parameter

%% <../plot_profile_CI.m *plot_profile_CI*>
% created by Dina Lika 2018/04/11
%
  %% Syntax
  % [ci, ci_low, ci_upper] = <../gplot_profile_CI.m *plot_profile_CI*>(pProfile)
  %
  %% Description
  % Calculates the profile of the loss function for a parameter
  %
  % The theory is discussed in Marques et al. 2018. "Fitting Multiple
  % Models to Multiple Data Sets". J Sea Research, doi.org/10.1016/j.seares.2018.07.004
  %
  % Input
  %
  % * pProfile: the parameter for which the profile is calculated (string)
  % * clevel: confidence level, e.g. 0.9 for the 90% marginal confidence interval 
  %
  % Output
  %
  % * lf_thres: threshold of the profile to get the CI
  % * ci_low: the lower boundary of the CI
  % * ci_upper: the upper boundary of the CI
  %
  % REMARK: In some cases several intervals may result. This can be seen
  % from the profile of the loss function. This function will not compute
  % the confidence sets

function [lf_thres, ci_low, ci_upper] = plot_profile_CI(pars_profile, lf_profile, lf_calibrate, clevel)
lf_min = min(lf_profile);
surv_vec0=surv(lf_calibrate);
lf0      = min(surv_vec0(:,1)); % F_*^0, 

thres = 1-clevel; %0.1; % 1-0.9, for the 90% marginal confidence interval 
surv_vec = [surv_vec0(:,1)-lf0  surv_vec0(:,2)]; % corrected for contribution of pseudo data
auxN = find(surv_vec(:,2) <= thres);
n        = auxN(1);       % find the value of lf that 90% of the estimations in the Monte Carlo simulations were under that
lf_thres = surv_vec(n,1); % threshold of the profile to get the CI

figure(1)
plot(surv_vec(:,1),surv_vec(:,2),'r','linewidth',3),hold on
ylabel('\fontsize{14}survivor function'); xlabel('\fontsize{14}loss function')
figure(2) 
plot(pars_profile, lf_profile - lf_min, 'r','linewidth',3), hold on
plot([min(pars_profile), max(pars_profile)], [lf_thres, lf_thres],'b')
ylabel('\fontsize{14} loss function'); xlabel('\fontsize{14} z, -')

%%%------------------- find confidence interval---------------------------
lf_profile = lf_profile - lf_min;
I=find(lf_profile <= lf_thres);

% This algorithm assumes that the CI consists of a single set
x=pars_profile; y = lf_profile;
z1 = x(I(1)-1); z2 = x(I(1)); z12=0.5*(z1+z2);
w1 = y(I(1)-1); w2 = y(I(1)); w12= w1 + (z12-z1)*(w1-w2)/(z1-z2); 
A_low =[z1, z12, z2 ; abs(w1-lf_thres), abs(w12-lf_thres), abs(w2-lf_thres)]';
[w_min, ii] = min(A_low(:,2));
ci_low = A_low(ii,1);

z1 = x(I(end)); z2 = x(I(end)+1); z12=0.5*(z1+z2);
w1 = y(I(end)); w2 = y(I(end)+1); w12= w1 + (z12-z1)*(w1-w2)/(z1-z2); 
A_upper =[z1, z12, z2 ; abs(w1-lf_thres), abs(w12-lf_thres), abs(w2-lf_thres)]';
[w_min, ii] = min(A_upper(:,2));
ci_upper = A_upper(ii,1);
