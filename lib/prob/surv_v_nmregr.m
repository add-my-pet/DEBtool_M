% surv_v_nmregr; run from deb3/matlab/ch8_c 

figure % v post acceleration
vsM = read_allStat('v','s_M'); v = vsM(:,1) .* vsM(:,2); n = length(v);
logv = log(v); surv_logv = surv(logv); logv_m = mean(logv); logv_std = std(logv);
logv_med = median(logv); logv_min = min(logv); logv_max = max(logv); 
V = linspace(logv_min,logv_max,500)'; 
par = [-4.1107 1; 0.98653 1; 9.1628 1]; % initial parameters loc, scale, shape
nmregr_options('report',1); % no output during estimation
par = nmregr('skewNormal', par, surv_logv); % overwrite initial par with estimated par
loc = par(1,1); scale = par(2,1); shape = par(3,1);

fprintf(['Pars log skew normal for v: loc ', num2str(loc), ' cm/d; scale ', num2str(scale), '; shape ', num2str(shape),'\n'])
S = surv_skewNorm(loc, scale, shape, V);
fprintf(['mean & sd: ', num2str(logv_m), ' cm/d, ', num2str(logv_std),'  cm/d\n'])
plot(V, S, '-', 'color',[0.75 0.75 1], 'linewidth',8)
set(gca, 'FontSize', 15, 'Box', 'on', 'YTick', 0:0.2:1)

hold on
plot([logv_min; logv_med; logv_med], [0.5;0.5;0], 'r', surv_logv(:,1), surv_logv(:,2), 'b', 'Linewidth', 2)
xlabel('log energy conductance, cm/d') 
ylabel('survivor function')
title(['\it all ',num2str(n),'  AmP species @ ',datestr(datenum(date),'yyyy/mm/dd')], 'FontSize',15, 'FontWeight','normal'); 
set(gca, 'FontSize', 15, 'Box', 'off', 'YTick', 0:0.2:1)
saveas(gca,'../../eps/ch8_c/surv_v.png')
