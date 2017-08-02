%% get_Nf_hex
% Gets number of eggs at emergence for hex model from structural length of imago

%%
function [N, f, info] = get_Nf_hex(le, p)
  % created at 2017/07/31 by Bas Kooijman, 
  
  %% Syntax
  % [N, f, info] = <../get_Nf_hex.m *get_Nf_hex*> (le, p)
  
  %% Description
  % Obtains number of eggs at emergence from structural length of imago for hex model
  % Food density is assumed to be constant.
  %
  % Input
  %
  % * le: vector with scaled structural lengths of imago 
  % * p: 8 with parameters: g k v_Hb v_He s_j kap kap_V kap_R
  %  
  % Output
  %
  % * N: number of eggs at emergence
  % * f: vector with functional response 
  % * info: vector with indicators equals 1 if successful, 0 otherwise
  
  %% Remarks
  %  first finds f from le, then N from f.
  
  %% Example of use
  %  get_Nf_hex([.5, .1, .01, .05, .2, 0.8, .95])

   kap = p(6); kap_R = p(8);
   n = length(le); N = zeros(n,1); f = zeros(n,1); info = zeros(n,1);
 
   for i = 1:n    
     fi = fzero(@fnNf, 1, [], p, le(i));
     [tji, te, tb, lji, le, lb, rj, vRj, uEe, infoi] = get_tj_hex(p, fi);
     N(i) = kap_R * (1 - kap) * vRj * lji^3/ get_ue0(p, fi);
     f(i) = fi;
     info(i) = infoi;
   end
 
end

%% subfunction

function F = fnNf(fi, p, l)
  [tj, tp, tb, lj] = get_tj_hex(p, fi);
  F = lj - l; 
end