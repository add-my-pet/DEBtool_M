%% fig:wscat;
%% out:grsim,cvgrsim

%% deterministic growth with stochastic input (random telegraph process)

clear all; clf;

%% unit of time 1/kM
lab0 = 2*11.666; % prob rate from starving to feeding
lab1 = 2*5;      % prob rate from feeding to starving
g = 1;         % investment ratio
lb = 0.05;     % scaled length at birth
d = 0.5;       % w_E[M_em]/ d_V = d_E/d_V rel contrib of reserve in weight
%% scaled weight w = (1 + e d) l^3 (dimensionless)

p = [lab0, lab1, g, lb, d]'; % pack parameters

t = linspace(1e-8,12,100)'; % time points
w = weight(p,t,100);        % weight^1/3
sw = sort(w')';             % sorted weight^1/3 for each row
[t,sw(:,[2 5 10 90 95 99])]
mw = .01 * sum(w, 2); % time and mean weight
cv = sqrt(max(1e-8,.01 * sum(w .* w, 2) - mw .* mw)) ./ mw; % variation coeff

subplot(1,2,1)
plot(t, mw, '-k', ...
     t, sw(:,10), '-g', t,sw(:, 5), '-b', t,sw(:, 2),'-r', ...
     t, sw(:,90), '-g', t, sw(:,95), '-b', t, sw(:,99), '-r')
legend('mean', '80%', '90%', '98%');
xlabel('scaled time')
ylabel('scaled weight^1/3')

subplot(1,2,2);
plot (mw, cv, '-g')
xlabel('mean scaled weight^1/3')
ylabel('cv scaled weight^1/3')
