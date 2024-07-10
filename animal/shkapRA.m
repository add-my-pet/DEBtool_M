%% get_max_kapRA
% plots reprod investment as fraction of assimilation at ultimate size as function of kap

%%
function res = shkapRA(pars,f)
% created 2024/07/10 by Bas Kooijman

%% Syntax
% res = <../shkapRA.m *shkapRA*> (par,f) 

%% Description
% Plots reprod investment as fraction of assimilation at ultimate size as function of kap: kapRA = p_R^infty/p_A^\infty
% It also gives the min value for kap for positive reproduction and 
% the value for kap at which the max is reached
%
% Input:
% 
% * pars: 4-vector with parameters:
% 
%    - p_Am, J/d.cm^2, spec assim rate (after accelleration)
%    - p_M, J/d.cm^3, spec som maint rate
%    - k_J, 1/d, maturity maint rate coeff
%    - E_Hp, J, maturity at puberty
%
% * f: optional scalar with scaled functionsl response (default 1)
%
% Output:
% 
% * res: 5-vector with 
%
%    - kap_opt: value of kap that maximizes kapRA
%    - kapRA_opt: max value of kapRA
%    - kap_min: minimum value for kap for which kapRA > 0
%    - kap_max: maximum value for kap for which kapRA > 0
%    - info: boolean for numerical success (1) or failure (0)

%% Example of use
% nm = select('Daphnia'); res = get_max_kapRA(read_stat(nm,{'p_Am','p_M','k_J','E_Hp'}));
% pRA = read_stat(nm,{'p_Ri','p_Ai','kap'}); kapRA = pRA(:,1)./pRA(:,2); kap = pRA(:,3); 
% prt_tab({nm,res,kap,kapRA,kapRA./res(:,3)},{'species','kap_min','kap_opt','kapRA_opt','info','kap', 'kapRA','kapRA/kapRA_opt'})

close all

  p_Am = pars(1); % J/d.cm^2
  p_M = pars(2);  % J/d.cm^3
  k_J = pars(3);  % 1/d
  E_Hp = pars(4); % J

  res = get_max_kapRA(pars);
  kap_opt = res(1); kapRA_opt = res(2); kap_min = res(3); kap_max = res(4);

if ~exist('f','var') || isempty(f)
  f = 1; % -
end

% prepare for plotting
kap = linspace(1e-3,0.9999,500)';
L_i = kap * f * p_Am/ p_M; % cm
p_Jp = k_J * E_Hp ./ L_i.^3; % J/d.cm^3
kapRA = 1 - kap .* (1 + p_Jp/ p_M);

% plot
plot(kap,kapRA,'k', 'linewidth',2)
ylim ([0 1])
xlabel('\kappa')
ylabel('\kappa_R^A')
set(gca, 'FontSize', 15, 'Box', 'on')

hold on
plot([kap_opt;kap_opt], [0;kapRA_opt],'r', 'linewidth',2)
plot([0;kap_opt], [kapRA_opt;kapRA_opt],'r', 'linewidth',2)
plot([0;1], [1,0], ':b', 'linewidth',2)
%saveas(gca, '../../eps/ch8_c/kap_kapRA.png')

