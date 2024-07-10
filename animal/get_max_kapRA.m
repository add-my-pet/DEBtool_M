%% get_max_kapRA
% get max reprod investment as fraction of assimilation at ultimate size

%%
function res = get_max_kapRA(pars,f)
% created 2024/07/09 by Bas Kooijman

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
%    - p_Am, J/d.cm^2, spec assim rate (after accelleration)
%    - p_M, J/d.cm^3, spec som maint rate
%    - k_J, 1/d, maturity maint rate coeff
%    - E_Hp, J, maturity at puberty
%
% * f: optional scalar with scaled functionsl response (default 1)
%
% Output:
% 
% * res: (n,5)-matrix with 
%
%    - kap_opt: value of kap that maximizes kapRA
%    - kapRA_opt: max value of kapRA
%    - kap_min: minimum value for kap for which kapRA > 0
%    - kap_max: maximum value for kap for which kapRA > 0
%    - info: boolean for numerical success (1) or failure (0)

%% Remarks
% Uses fzero with bisection method

%% Example of use
% nm = select('Daphnia'); res = get_max_kapRA(read_stat(nm,{'p_Am','p_M','k_J','E_Hp'}));
% pRA = read_stat(nm,{'p_Ri','p_Ai','kap'}); kapRA = pRA(:,1)./pRA(:,2); kap = pRA(:,3); 
% prt_tab({nm,res,kap,kapRA,kapRA./res(:,3)},{'species','kap_min','kap_opt','kapRA_opt','info','kap', 'kapRA','kapRA/kapRA_opt'})

if ~exist('f','var') || isempty(f)
  f = 1; % -
end

n = size(pars,1); res = NaN(n,4);

for i = 1:n
  p_Am = pars(i,1); p_M = pars(i,2); k_J = pars(i,3); E_Hp = pars(i,4);

  % prepare for plotting
  kap = linspace(1e-5,0.99999,100)';
  L_i = kap * f * p_Am/ p_M; % cm
  p_Jp = k_J * E_Hp ./ L_i.^3; % J/d.cm^3
  kapRA = 1 - kap .* (1 + p_Jp/ p_M);
  kap_opt = spline1(max(kapRA),[kapRA,kap]);
  kap0 = kap(kapRA>0); kap0 = [kap0(1) kap0(end)];

  % min/max kap
  try
    kapMin = @(kap,k_J,E_Hp,f,p_Am,p_M) 1/kap - 1 - k_J * E_Hp * p_M^2/ (kap*f*p_Am)^3; 
    [kap_min, ~, infoMin] = fzero(@(kap) kapMin(kap,k_J,E_Hp,f,p_Am,p_M),kap0(1));
    [kap_max, ~, infoMax] = fzero(@(kap) kapMin(kap,k_J,E_Hp,f,p_Am,p_M),kap0(2));
  catch
    infoMin = 0; infoMax = 0; kap_min = 0; kap_max = 1;
  end
 
  % max kapRA
  try
    kapOpt = @(kap,p_Am,p_M,k_J,E_Hp,f) 1 - 2 * k_J * E_Hp/ (kap*f*p_Am/p_M)^3/ p_M; 
    [kap_opt, ~, infoOpt] = fzero(@(kap) kapOpt(kap,p_Am,p_M,k_J,E_Hp,f),kap_opt);
    p_Jp_opt = k_J * E_Hp / (kap_opt * f * p_Am/ p_M)^3;
    kapRA_opt = 1 - kap_opt * (1 + p_Jp_opt/ p_M);
  catch
    infoOpt = 0; kap_opt = NaN; kapRA_opt = NaN;
  end
  info = infoMin==1 && infoMax==1 && infoOpt==1;
  res(i,1) = kap_opt; res(i,2) = kapRA_opt; res(i,3) = kap_min; res(i,4) = kap_max; res(i,5) = info;
end
