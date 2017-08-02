%% get_Nf_hep
% Gets number of eggs at emergence for hep model

%%
function [N, f, info] = get_Nf_hep(lj, p)
  % created at 2016/02/13 by Bas Kooijman, 
  
  %% Syntax
  % [N, f, info] = <../get_Nf_hep.m *get_Nf_hep*> (lj, p)
  
  %% Description
  % Obtains number of eggs at emergence from structural length of imago for hep model
  % Food density is assumed to be constant.
  %
  % Input
  %
  % * lj: vector with scaled structural lengths of imago 
  % * p: 7-vector with parameters: g, k, v_H^b, v_H^p, v_R^j, kap, kap_R  
  %  
  % Output
  %
  % * N: number of eggs at emergence
  % * f: vector with functional response 
  % * info: vector with indicators equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  first finds f from lj, then N from f.
  
  %% Example of use
  %  get_Nf_hep([.5, .1, .01, .05, .2, 0.8, .95])
  
 n = length(lj); N = zeros(n,1); f = zeros(n,1); info = zeros(n,1);
 
 for i = 1:n
    
     fi = fzero(@fnNf, 1, [], p, lj(i));
     [tji, tp, tb, lji, lp, lb, li, rj, rB, Ni, infoi] = get_tj_hep(p, fi);
     N(i) = Ni;
     f(i) = fi;
     info(i) = infoi;
 end
 
end

%% subfunction

function F = fnNf(fi, p, l)
     [tj, tp, tb, lj] = get_tj_hep(p, fi);
     F = lj - l; 
end