%% CPMmap
% plot cohorts using linear mapping

%%
function CPMmap(tXN, tXW, M_N, M_W, n_R)
% created 2020/03/16 by Bob Kooi & Bas Kooijman
  
%% Syntax
% <../CPMmap.m *CPMmap*> (tXN, tXW, M_N, M_W)
  
%% Description
%  plot cohorts using N(t+T_R) = M_N * N(t) and W(t+T_R) = M_N * W(t)
%
% Input:
%
% * tXN: (n,m)-array with times, food density and number of individuals in the various cohorts
% * tXW: (n,m)-array with times, food density and cohort wet weights
% * M_N: (n_c,n_c)-array with map for N: N(t+t_R) = M_N * N(t)
% * M_W: (n_c,n_c)-array with map for W: W(t+t_R) = M_W * W(t)
% * n_R: optional scalar with number of iterations

%% Remark
% inputs are outputs for cpm

if ~exist('n_R','var') || isempty(n_R)
  n_R = 250; 
end
n_c = size(M_N,1); t = 1:n_R;
Nt = tXN(end,3:end)'; N = Nt'; 
Wt = tXW(end,3:end)'; W = Wt';
for i=2:n_R
  Nt = M_N * Nt;
  N = [N; Nt']; 
  Wt = M_W * Wt;
  W = [W; Wt']; 
end
N = cumsum(N,2); W = cumsum(W,2);
title_txt = 'Linear map';

figure
hold on
for i = 1:n_c-1
  plot(t, N(:,i), 'color', color_lava(i/n_c), 'Linewidth', 0.5) 
end
plot(t, N(:,n_c), 'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time in reprod event periods');
ylabel('# of individuals');
set(gca, 'FontSize', 15, 'Box', 'on')
%
figure
hold on
for i = 1:n_c-1
  plot(t, W(:,i), 'color', color_lava(i/n_c), 'Linewidth', 0.5) 
end
plot(t,W(:,n_c),'color', [1 0 0], 'Linewidth', 2) 
title(title_txt);
xlabel('time in reprod event periods');
ylabel('total wet weight, g');
set(gca, 'FontSize', 15, 'Box', 'on')

