txNL23W_ssm = SSM('Torpedo_marmorata');
txNL23W_cpm = CPM('Torpedo_marmorata');
txNL23W_ebt = EBT('Torpedo_marmorata');

close all
path = 'C:\Users\Bas\Documents\deb3\eps\ch9_c\';
datePrintNm = ['date: ',datestr(date, 'yyyy/mm/dd')];
title_txt = ['Torpedo marmorata ', datePrintNm];
%
figure(1) % t-x
hold on
plot(txNL23W_ssm(:,1), txNL23W_ssm(:,2), 'k', 'Linewidth', 2)
plot(txNL23W_cpm(:,1), txNL23W_cpm(:,2), 'b', 'Linewidth', 2)
plot(txNL23W_ebt(:,1), txNL23W_ebt(:,2), 'r', 'Linewidth', 2)
title(title_txt);
xlabel('time, d');
ylabel('scaled food density, X/K');
ylim([0,2])
set(gca, 'FontSize', 15, 'Box', 'on');
saveas (gca, [path, 'sce_x.pdf']);
%
figure(2) % t-N_tot
hold on
plot(txNL23W_ssm(:,1), txNL23W_ssm(:,3), 'k', 'Linewidth', 2)
plot(txNL23W_cpm(:,1), txNL23W_cpm(:,3), 'b', 'Linewidth', 2)
plot(txNL23W_ebt(:,1), txNL23W_ebt(:,3), 'r', 'Linewidth', 2)
title(title_txt);
xlabel('time, d');
ylabel('# of individuals, #/L');
set(gca, 'FontSize', 15, 'Box', 'on');
saveas (gca, [path, 'sce_N.pdf']);

%
figure(3) % t-L_tot
hold on
plot(txNL23W_ssm(:,1), txNL23W_ssm(:,4), 'k', 'Linewidth', 2)
plot(txNL23W_cpm(:,1), txNL23W_cpm(:,4), 'b', 'Linewidth', 2)
plot(txNL23W_ebt(:,1), txNL23W_ebt(:,4), 'r', 'Linewidth', 2)
title(title_txt);
xlabel('time, d');
ylabel('total structural length, cm/L');
set(gca, 'FontSize', 15, 'Box', 'on');
saveas (gca, [path, 'sce_L.pdf']);
%
figure(4) % t-L^2_tot
hold on
plot(txNL23W_ssm(:,1), txNL23W_ssm(:,5), 'k', 'Linewidth', 2)
plot(txNL23W_cpm(:,1), txNL23W_cpm(:,5), 'b', 'Linewidth', 2)
plot(txNL23W_ebt(:,1), txNL23W_ebt(:,5), 'r', 'Linewidth', 2)
title(title_txt);
xlabel('time, d');
ylabel('total structural surface area, cm^2/L');
set(gca, 'FontSize', 15, 'Box', 'on');
saveas (gca, [path, 'sce_L2.pdf']);
%
figure(5) % t-L^3_tot
hold on
plot(txNL23W_ssm(:,1), txNL23W_ssm(:,6), 'k', 'Linewidth', 2)
plot(txNL23W_cpm(:,1), txNL23W_cpm(:,6), 'b', 'Linewidth', 2)
plot(txNL23W_ebt(:,1), txNL23W_ebt(:,6), 'r', 'Linewidth', 2)
title(title_txt);
xlabel('time, d');
ylabel('total structural volume, cm^3/L');
set(gca, 'FontSize', 15, 'Box', 'on');
saveas (gca, [path, 'sce_L3.pdf']);
%
figure(6) % t-Ww_tot
hold on
plot(txNL23W_ssm(:,1), txNL23W_ssm(:,7), 'k', 'Linewidth', 2)
plot(txNL23W_cpm(:,1), txNL23W_cpm(:,7), 'b', 'Linewidth', 2)
plot(txNL23W_ebt(:,1), txNL23W_ebt(:,7), 'r', 'Linewidth', 2)
title(title_txt);
xlabel('time, d');
ylabel('total wet weight, g/L');
set(gca, 'FontSize', 15, 'Box', 'on');
saveas (gca, [path, 'sce_W.pdf']);
