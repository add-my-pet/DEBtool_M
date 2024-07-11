%% get_max_kapRA
% get max reprod investment as fraction of assimilation at ultimate size

%%
function res = get_max_kapRA(pars,f)
% created 2024/07/09 by Bas Kooijman/Dina Lika

%% Syntax
% res = <../get_max_kapRA.m *get_max_kapRA*> (par,f) 

%% Description
% get max reprod investment as fraction of assimilation at ultimate size as function of kap: kapRA = p_R^infty/p_A^\infty
% It also gives the min and max value for kap for positive reproduction and 
% the value for kap at which the max is reached
%
% Input:
% 
% * pars: (n,4)-matrix with parameters in columns:
% 
%    - p_Am, J/d.cm^2, spec assim rate (before accelleration)
%    - p_M, J/d.cm^3, spec som maint rate
%    - k_J, 1/d, maturity maint rate coeff
%    - E_Hp, J, maturity at puberty
%    - s_M, -, acceleration factor (optional, default 1)
%
% * f: optional scalar with scaled functionsl response (default 1)
%
% Output:
% 
% * res: (n,4)-matrix with 
%
%    - kap_opt: value of kap that maximizes kapRA
%    - kapRA_opt: max value of kapRA
%    - kap_min: minimum value for kap for which kapRA > 0
%    - kap_max: maximum value for kap for which kapRA > 0

%% Remarks
% Assumes p_T = 0 

%% Example of use
% nm = select('Daphnia'); res = get_max_kapRA(read_stat(nm,{'p_Am','p_M','k_J','E_Hp','s_M'}));
% pRA = read_stat(nm,{'p_Ri','p_Ai','kap'}); kapRA = pRA(:,1)./pRA(:,2); kap = pRA(:,3); 
% prt_tab({nm,res,kap,kapRA,kapRA./res(:,2)},{'species','kap_opt','kapRA_opt','kap_min','kap_max','kap','kapRA','kapRA/kapRA_opt'})

n = size(pars,1); res = NaN(n,4);

if ~exist('f','var') || isempty(f)
  f = 1; % -
end

if size(pars,2)==4 
  pars = [pars, ones(n,1)];
end

for i = 1:n
  p_Am = f * pars(i,1) * pars(i,5); p_M = pars(i,2); p_Jp = pars(i,3) * pars(i,4);

  % max kapRA
  kap_opt = (2 * p_Jp * p_M^2)^(1/3)/ p_Am;
  kapRA_opt = 1 - kap_opt * 3/ 2;

  % min/max kap
  s_s = p_Jp * p_M^2/ p_Am^3; % -, supply stress, 
  % p_Am: f * s_M * {p_Am}; J/d.cm^2
  % p_Jp: k_J * E_Hp; J/d
  % p_M:  [p_M]; J/d.cm^3
  kap0 = sort(roots3([1 -1 0 s_s],3)); kap_min = kap0(1); kap_max = kap0(2);

  res(i,1) = kap_opt; res(i,2) = kapRA_opt; res(i,3) = kap_min; res(i,4) = kap_max;
end
