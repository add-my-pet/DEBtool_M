% mydata_get_ld

% set parameters
g = 1;     % -, energy investment ratio
k = .1;     % -, maintenance ratio
v_Hd = .01; % -, scaled maturity at division

par = [g; k; v_Hd]; % pack parameters

f_min = 1e-4+get_ed_min(par); % minimal f that allows division
f = linspace(f_min, 1, 100)'; % -, scaled functional response

ld = zeros(100,1); % initialize ld
El1 = zeros(100,1); % enitialize El1
El2 = zeros(100,1); % enitialize El2
El3 = zeros(100,1); % enitialize El3
ld0 = f(1) + 1e-4; % initial value of ld for first f

for i = 1:100
  [El1(i) El2(i) El3(i) ld0] = get_Eli(par, f(i), ld0);
  %ld0 = get_ld(par, f(i), ld0); % overwrite initial value for next call
  ld(i) = ld0; % fill ld
end

% result
plot(f, ld, 'b', f, ld/2^(1/3), 'b', f, El1, 'r', f, El3./El2, 'g', 'linewidth', 2)
set(gca, 'FontSize', 15, 'Box', 'on')
xlabel('scaled functional response f')
ylabel('range of l, El (red), E l^3/ E l^2 (green)')


