%%  std2abj
% writes table with abj and std values for tau_p, tau_b, l_p, l_b

%%
function std2abj(spec)
% created 2024/11/19 by Bas Kooijman

%% Syntax
% <../std2abj.m *std2abj*> (spec) 

%% Description
% writes table with abj and std values for tau_p, tau_b, l_p, l_b and shows it in the bowser
%
% Input:
%
% * spec: entry name
%
% Output:
%
% * text-file with the name title.html is written and shown in browser

%% Example of use
% std2abj('Daphnia_pulex');


  par = allStat2par(spec); 
  if ~isfield(par,'E_Hj') 
      par.E_Hj = par.E_Hb + 1e-3; 
  else
      fprintf('Warning from std2abj: E_Hj is already in pars\n');
  end
  cPar = parscomp_st(par); vars_pull(par); vars_pull(cPar);
  
  res = NaN(4,2); vars = {'tau_p';'tau_b';'l_p';'l_b'};
  pars_tj = [g k l_T v_Hb v_Hj v_Hp]; % compose pars for get_tj
  [tau_j, tau_p, tau_b, l_j, l_p, l_b] = get_tj(pars_tj, 1);
  res(:,1) = [tau_p; tau_b; l_p; l_b];

  pars_tp = [g k l_T v_Hb v_Hp]; % compose pars for get_tp
  [tau_p, tau_b, l_p, l_b] = get_tp(pars_tp, 1);
  res(:,2) = [tau_p; tau_b; l_p; l_b];

  prt_tab({vars,res},{spec,'abj','std'})
end