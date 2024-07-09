%% get_max_kapRA
% get max reprod investment as fraction of assimilation at ultimate size

%%
function res = get_max_kapRA(pars,f)
% created 2024/07/09 by Bas Kooijman

%% Syntax
% res = <../get_max_kapRA.m *get_max_kapRA*> (par,f) 

%% Description
% get max reprod investment as fraction of assimilation at ultimate size as function of kap: kapRA = p_R^infty/p_A^\infty
% It also gives the min value for kap for positive reproduction and 
% the value for kap at which the max is reached
%
% Input:
% 
% * pars: (n,4)-matrix with parameters in columns:
% 
%    - p_Am, J/d.cm^2, spec assim rate
%    - p_M, J/d.cm^3, spec som maint rate
%    - k_J, 1/d, maturity maint rate coeff
%    - E_Hp, J, maturity at puberty
%
% * f: optional scalar with scaled functionsl response (default 1)
%
% Output:
% 
% * res: (n,4)-matrix with 
%
%    - kap_min: minimum value for kap for which kapRA > 0
%    - kap_opt: value of kap that maximizes kapRA
%    - kapRA_opt: max value of kapRA
%    - info: boolean for numerical success (1) or failure (0)

%% Remarks
% Uses fzero with bisection method

%% Example of use
% res = get_max_kapRA(read_stat('Daphnia',{'p_Am','p_M','k_J','E_Hp'}))
% pRJ = read_stat('Daphnia',{'p_Ri','p_Ai'}); kapRA = pRJ(:,1)./pRJ(:,2);
% prt_tab({select('Daphnia'),res,kapRA,kapRA./res(:,3)},{'species','kap_min','kap_opt','kapRA_opt','info','kapRA','kapRA/kapRA_opt'})

if ~exist('f','var') || isempty(f)
  f = 1; % -
end

n = size(pars,1); res = NaN(n,4);

for i = 1:n
  p_Am = pars(i,1); p_M = pars(i,2); k_J = pars(i,3); E_Hp = pars(i,4);

  % min kap
  kapMin = @(kap,k_J,E_Hp,f,p_Am,p_M) 1/kap - 1 - k_J * E_Hp * p_M^2/ (kap*f*p_Am)^3; 
  [kap_min, ~, infoMin] = fzero(@(kap) kapMin(kap,k_J,E_Hp,f,p_Am,p_M),[1e-5, 0.95]);

  % max kapRA
  kapOpt = @(kap,k_J,E_Hp,f,p_Am,p_M) 1 + kap - 2 * k_J * E_Hp/ (kap*f*p_Am/p_M)^3/ p_M; 
  [kap_opt, ~, infoOpt] = fzero(@(kap) kapOpt(kap,k_J,E_Hp,f,p_Am,p_M),[kap_min, 1]);
  p_Jp_opt = k_J * E_Hp / (kap_opt * f * p_Am/ p_M)^3;
  kapRA_opt = 1 - kap_opt * (1 + p_Jp_opt/ p_M);

  info = infoMin==1 && infoOpt==1;
  res(i,1) = kap_min; res(i,2) = kap_opt; res(i,3) = kapRA_opt; res(i,4) = info;
end
