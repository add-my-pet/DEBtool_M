% estimate parameters from gamma distibution and plot survivor function

theta = 1.9;  % set par theta
alpha = 3.02; % set par alpha
t = gammarnd(theta,alpha,100,1); % 100 random trials 
p = gammaML(t); % get pars from the trials
surv_t = surv(t); % compose empirical survivor function

close all
figure 
plot(log10(surv_t(:,1)),surv_t(:,2),'r') % plot empirical survivor function

hold on
t = 10.^linspace(log10(min(t)),log10(max(t)),500); % compose t-axis
plot(log10(t), 1 - gammainc(t/p(1),p(2)), 'b') % plot expected survivor function
xlabel('log10 transformed argument')
ylabel('survivor function')