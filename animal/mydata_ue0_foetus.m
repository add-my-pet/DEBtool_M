%% compare results for egg and foetus

%% set parameters
p = [.9;     % g energy investment ratio
     0.99;   % k maintenance ratio: k_J/ k_M
     .0001]; % vHb scaled maturity density at birth
eb = .8;     % scaled reserve density at birth

%% first for an egg
[uE0, lb, info] = get_ue0(p, eb); tb = get_tb(p, eb, lb);
%% then for a foetus
[uE0_f lb_f tb_f info_f] = get_ue0_foetus(p, eb);

txt = [{'scaled initial reserve'}; ...
       {'scaled length at birth'}; ...
       {'scaled age at birth   '}; ...
       {'convergence indicator '}];
fprintf('                           egg      foetus\n');
data = [uE0 uE0_f; lb lb_f; tb tb_f; info info_f];
print_txt_var(txt, data);
