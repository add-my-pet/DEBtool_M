%% get_kapRA
% get reprod investment as fraction of assimilation at ultimate size

%%
function res = get_kapRA(pars,f)
% created 2024/07/12 by Bas Kooijman/Dina Lika

%% Syntax
% res = <../get_kapRA.m *get_kapRA*> (par,f) 

%% Description
% get reprod investment as fraction of assimilation at ultimate size as function of kap: kapRA = p_R^infty/p_A^\infty
%
% Input:
% 
% * pars: (n,6)-matrix with parameters in columns:
% 
%    - p_Am, J/d.cm^2, spec assim rate (before accelleration): f * s_M * {p_Am}
%    - p_M, J/d.cm^3, spec som maint rate: [p_M]
%    - k_J, 1/d, maturity maint rate coeff
%    - E_Hp, J, maturity at puberty
%    - s_M, -, acceleration factor
%    - kap, -, allocation fraction to soma
%
% * f: optional scalar with scaled functionsl response (default 1)
%
% Output:
% 
% * res: (n,3)-matrix with 
%
%    - kapRA, -
%    - p_Ri, J/d
%    - p_Ai, J/d

%% Remarks
% Assumes p_T = 0 

%% Example of use
% nm = select('Daphnia'); res = get_kapRA(read_stat(nm,{'p_Am','p_M','k_J','E_Hp','s_M','kap'}));
% prt_tab({nm,res},{'species','kapRA','p_Ri','p_Ai'})

n = size(pars,1); res = NaN(n,3);

if ~exist('f','var') || isempty(f)
  f = 1; % -
end

if size(pars,2)==4 
  pars = [pars, ones(n,1)];
end

for i = 1:n
  p_Am = f * pars(i,1) * pars(i,5); p_M = pars(i,2); p_Jp = pars(i,3) * pars(i,4); kap = pars(i,6);
    
  L_i = kap * p_Am/ p_M;
  p_Ai = p_Am * L_i^2;
  p_Ri = (1 - kap) * p_Ai - p_Jp;
  kapRA = p_Ri/ p_Ai;

  res(i,1) = kapRA; res(i,2) = p_Ri; res(i,3) = p_Ai;
end
