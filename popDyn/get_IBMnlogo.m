%% get_IBMnlogo
% get population trajectories from NetLogo

%%
function tXNL23W = get_IBMnlogo(model, par, tT, tJX, X_0, V_X, t_R, t_max, tickRate, runNetLogo)

% created 2021/01/08 by Bas Kooijman
  
%% Syntax
% tXNL23W = <../get_IBMnlogo.m *get_IBMnlogo*> (model, par, tT, tJX, x_0, V_X, t_R, t_max, tickRate, runNetLogo)
  
%% Description
% Gets trajectories of  food density and populations, using NetLogo, 
%
% environmental variables 
%
%  - TC: temp corr factor
%  - X: food density X
%
% i-states
%
%  - a: d, age
%  - t_spawn: d, time since last spawning
%  - h_a: 1/d, hazard rate due to aging
%  - q: 1/d^2, ageing acceleration
%  - L: cm, structural length
%  - e: -, scaled reserve density
%  - E_H: J, maturity
%  - E_Hmax: J, max maturity ever reached
%  - E_R: J, reproduction buffer
%
% Input:
%
% * model: character-string with name of model
% * par: structure with parameter values
% * tT: (nT,2)-array with time and temperature in Kelvin; time scaled between 0 (= start) and 1 (= end of cycle)
% * tJX: (nX,2)-array with time and food supply; time scaled between 0 (= start) and 1 (= end of cycle)
% * X_0: scalar with initial food density 
% * V_X: scalar with volume of reactor
% * t_R: scalar for reproduction buffer handling rule with 
%
%     - 0 for spawning as soon as reproduction buffer allows
%     - 1 for spawning after accumulation over an incubation period
%     - time between spawning events
%
% * t_max: scalar with time to be simulated
% * tickRate: scalar with number of ticks per day for Euler intergration
% * runNetLogo: boolean for running NetLogo under Matlab
%
% Output:
%
% * txNL23W: (n,7)-array with times and densities of scaled food, total number, length, squared length, cubed length, weight

%% Remarks
%
% * writes spline_TC.txt and spline_JX.txt (first degree spline function for temp correction and food input)
% * writes mod.nlogo,  where mod is one of 10 DEB models, and eaLE.txt with embryo settings for interpolation withing NetLogo
% * runs NetLogo in Window's PowerShell, which writes txNL23W.txt
% * reads txNL23W.txt.out for output

  % unpack par and compute compound pars
  vars_pull(par); vars_pull(parscomp_st(par));  
  
  %% write spline_JX.txt, spline_TC.txt for environmental variables
  
  % knots for temperature, and convert to temp correction factors
  % compose temp par vector
  par_T = T_A;
  if exist('T_L','var') && exist('T_AL','var')
    par_T = [T_A; T_L; T_AL];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    par_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  % knots for temperature
  tTC = tT;  tTC(:,2) = tempcorr(tT(:,2), T_ref, par_T);
  write_spline('TC', tTC); TC = tTC(1,2);
  %
  % knots for food density in supply flux
  write_spline('JX', tJX); 
  
  %% write eaLE.txt for embryo-setting
 
  eaLE = zeros(10,4);
  [e_b, l_b, u_E0, info] =  get_eb_min([g, k, v_Hb], 1); % minimum value for e_b
  e = linspace(e_b+1e-3, 1, 10);
  switch model
    case {'std','abj'}
      for i = 1:10
        [tau_b, l_b] = get_tb([g, k, v_Hb], e(i));
        u_E0 = get_ue0([g, k, v_Hb], e(i));
        eaLE(i, :) = [e(i), tau_b/ k_M, l_b * L_m, g * E_m * L_m^3 * u_E0];
      end
    case {'stf','stx'}
      for i = 1:10
        [tau_b, l_b] = get_tb_foetus([g, k, v_Hb]);
        u_E0 = get_ue0_foetus([g, k, v_Hb], e(i));
        eaLE(i, :) = [e(i), tau_b/ k_M, l_b * L_m, g * E_m * L_m^3 * u_E0];
      end
  end
  
  oid = fopen('eaLE.txt', 'w+'); % open file for writing, delete existing content
  for i = 1:10
    fprintf(oid, '%5.4g %5.4g %5.4g %5.4g \n', eaLE(i,1), eaLE(i,2), eaLE(i,3), eaLE(i,4));
  end
  fclose(oid);

  
  %% write set_pars.txt for parameter setting
   
  % set male parameters
  if ~exist('E_Hpm', 'var')
    E_Hpm = E_Hp;
  end
  if exist('z_m', 'var')
    p_Amm = z_m * p_M/ kap;
  else
    p_Amm = p_Am;
  end
  
  % specify input parameters
  switch model
    case {'std','stf','sbp'}
      par = {tickRate, t_max, X_0, V_X, mu_X, h_X, h_B0b, h_Bbp, h_Bpi, ...
        thin, h_J, h_a, s_G, E_Hb, E_Hp, E_Hpm, fProb, kap, kap_X, kap_G, kap_R, ...
        t_R, F_m, p_Am, p_Amm, v, p_M, k_J, k_JX, E_G, ome};
      txtPar = {'tickRate', 't_max', 'X_0', 'V_X', 'mu_X', 'h_X', 'h_B0b', 'h_Bbp', 'h_Bpi', ...
        'thin', 'h_J', 'h_a', 's_G', 'E_Hb', 'E_Hp', 'E_Hpm', 'fProb', 'kap', 'kap_X', 'kap_G', 'kap_R', ...
        't_R', 'F_m', 'p_Am', 'p_Amm', 'v', 'p_M', 'k_J', 'k_JX', 'E_G', 'ome'};
    case 'stx'
      par = {tickRate, t_max, X_0, V_X, mu_X, h_X, h_B0b, h_Bbx, h_Bxp, h_Bpi, ...
        thin, h_J, h_a, s_G, E_Hb, E_Hx, E_Hp, E_Hpm, fProb, kap, kap_X, kap_G, kap_R, ...
        t_R, F_m/10, p_Am, p_Amm, v, p_M, k_J, k_JX, E_G, ome};
      txtPar = {'tickRate', 't_max', 'X_0', 'V_X', 'mu_X', 'h_X', 'h_B0b', 'b_Bbx', 'h_Bxp', 'h_Bpi', ...
        'thin', 'h_J', 'h_a', 's_G', 'E_Hb', 'W_Hx', 'E_Hp', 'E_Hpm', 'fProb', 'kap', 'kap_X', 'kap_G', 'kap_R', ...
        't_R', 'F_m', 'p_Am', 'p_Amm', 'v', 'p_M', 'k_J', 'k_JX', 'E_G', 'ome'};
    case 'ssj' 
      del_sj = exp(-k_E * t_sj/ 3); % reduction factor for structural length at end of leptocephalus stage
      par = {tickRate, t_max, X_0, V_X, mu_X, h_X, h_B0b, h_Bbp, h_Bpi, ...
        thin, h_J, h_a, s_G, E_Hb, E_Hs, E_Hp, E_Hpm, fProb, kap, kap_X, kap_G, kap_R, ...
        t_R, F_m, p_Am, p_Amm, v, p_M, k_J, k_JX, del_sj, E_G, ome};
      txtPar = {'tickRate', 't_max', 'X_0', 'V_X', 'mu_X', 'h_X', 'h_B0b', 'h_Bbp', 'h_Bpi', ...
        'thin', 'h_J', 'h_a', 's_G', 'E_Hb', 'E_Hp', 'E_Hpm', 'fProb', 'kap', 'kap_X', 'kap_G', 'kap_R', ...
        't_R', 'F_m', 'p_Am', 'p_Amm', 'v', 'p_M', 'k_J', 'k_JX', 'E_G', 'ome'};
    case 'abj'
      par = {tickRate, t_max, X_0, V_X, mu_X, h_X, h_B0b, h_Bbj, h_Bjp, h_Bpi, ...
        thin, h_J, h_a, s_G, E_Hb, E_Hj, E_Hp, E_Hpm, fProb, kap, kap_X, kap_G, kap_R, ...
        t_R, F_m, p_Am, p_Amm, v, p_M, k_J, k_JX, E_G, ome};
      txtPar = {'tickRate', 't_max', 'X_0', 'V_X', 'mu_X', 'h_X', 'h_B0b', 'h_Bbj', 'h_Bjp', 'h_Bpi', ...
        'thin', 'h_J', 'h_a', 's_G', 'E_Hb', 'E_Hj', 'E_Hp', 'E_Hpm', 'fProb', 'kap', 'kap_X', 'kap_G', 'kap_R', ...
        't_R', 'F_m', 'p_Am', 'p_Amm', 'v', 'p_M', 'k_J', 'k_JX', 'E_G', 'ome'};
    case 'asj'
      par = {tickRate, t_max, X_0, V_X, mu_X, h_X, h_B0b, h_Bbs, h_Bsj, h_Bjp, h_Bpi, ...
        thin, h_J, h_a, s_G, E_Hb, E_Hs, E_Hj, E_Hp, E_Hpm, fProb, kap, kap_X, kap_G, kap_R, ...
        t_R, F_m, p_Am, p_Amm, v, p_M, k_J, k_JX, E_G, ome};
      txtPar = {'tickRate', 't_max', 'X_0', 'V_X', 'mu_X', 'h_X', 'h_B0b', 'h_Bbs', 'h_Bsj', 'h_Bjp', 'h_Bpi', ...
        'thin', 'h_J', 'h_a', 's_G', 'E_Hb', 'E_Hs', 'E_Hj', 'E_Hp', 'E_Hpm', 'fProb', 'kap', 'kap_X', 'kap_G', 'kap_R', ...
        't_R', 'F_m', 'p_Am', 'p_Amm', 'v', 'p_M', 'k_J', 'k_JX', 'E_G', 'ome'};
    case 'abp'
      par = {E_Hp, E_Hb, V_X, h_X, h_J, h_B0b, h_Bbp, h_Bpi, h_a, s_G, thin,  ...
        L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, ome, E_0, L_b, a_b, aT_b, q_b, qT_b, h_Ab, hT_Ab};
      txtPar = {'E_Hp, J', 'E_Hb, J', 'V_X, L', 'h_X, 1/d', 'h_J, 1/d', 'h_B0b, 1/d', 'h_Bbj, 1/d', 'h_Bjp, 1/d', 'h_Bpi, 1/d', 'h_a, 1/d', ...
        's_G, -', 'thin, -', 'L_j, cm', 'L_m, cm', 'E_m, J/cm^3', 'k_J, 1/d', 'k_JX, 1/d', 'v, cm/d', 'g, -', ...
        '[p_M] J/d.cm^3', '{p_Am}, J/d.cm^2', '{J_X_Am}, mol/d.cm^2', 'K, mol/L', 'kap, -', 'kap_G, -', ...
        'ome, -', 'E_0, J', 'L_b, cm', 'a_b, d', 'aT_b, d', 'q_b, 1/d^2', 'qT_b, 1/d^2', 'h_Ab, 1/d', 'hT_Ab, 1/d'};
    case 'hep' 
      par = {E_Hp, E_Hb, V_X, h_X, h_J, h_B0b, h_Bbp, h_Bpj, h_Bji, h_a, s_G, thin,  ...
        L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, ome, E_0, E_Rj, L_b, L_j, a_b, aT_b, q_b, qT_b, h_Ab, hT_Ab, numPar.cycle_interval}/ t_m;
      txtPar = {'E_Hp, J', 'E_Hb, J', 'V_X, L', 'h_X, 1/d', 'h_J, 1/d', 'h_B0b, 1/d',  'h_Bbp, 1/d', 'h_Bpj, 1/d', 'h_Bji, 1/d', 'h_a, 1/d', 's_G, -', 'thin, -', ...
        'L_m, cm', 'E_m, J/cm^3', 'k_J, 1/d', 'k_JX, 1/d', 'v, cm/d', 'g, -', ...
        '[p_M] J/d.cm^3', '{p_Am}, J/d.cm^2', '{J_X_Am}, mol/d.cm^2', 'K, mol/L', 'kap, -', 'kap_G, -', ...
        'ome, -', 'E_0, J', 'E_Rj, J/cm^3', 'L_b, cm', 'L_j, cm', 'a_b, d', 'aT_b, d', 'q_b, 1/d^2', 'qT_b, 1/d^2', 'h_Ab, 1/d', 'hT_Ab, 1/d', 'N_batch, -'};
    case 'hex' 
      par = {E_He, E_Hb, V_X, h_X, h_J, h_B0b, h_Bbj, h_Bje, h_Bei, h_a, s_G, thin,  ...
        L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, ome, E_0, E_Rj, L_b, L_j, L_e, a_b, aT_b, q_b, qT_b, h_Ab, hT_Ab, numPar.cycle_interval}/ t_m;
      txtPar = {'E_He, J', 'E_Hb, J', 'V_X, L', 'h_X, 1/d', 'h_J, 1/d', 'h_B0b, 1/d',  'h_Bbj, 1/d', 'h_Bje, 1/d', 'h_Bei, 1/d', 'h_a, 1/d', 's_G, -', 'thin, -', ...
        'L_m, cm', 'E_m, J/cm^3', 'k_J, 1/d', 'k_JX, 1/d', 'v, cm/d', 'g, -', ...
        '[p_M] J/d.cm^3', '{p_Am}, J/d.cm^2', '{J_X_Am}, mol/d.cm^2', 'K, mol/L', 'kap, -', 'kap_G, -', ...
        'ome, -', 'E_0, J', 'E_Rj, J/cm^3', 'L_b, cm', 'L_j, cm', 'L_e, cm', 'a_b, d', 'aT_b, d', 'q_b, 1/d^2', 'qT_b, 1/d^2', 'h_Ab, 1/d', 'hT_Ab, 1/d', 'N_batch, -'};
  end
  
  % write parameter settings
  n_par = length(par); % number of parameters
  oid = fopen('set_pars.txt', 'w+'); % open file for writing, delete existing content
  for i = 1:n_par
    fprintf(oid, '"set %s %5.4g"\n', txtPar{i}, par{i});
  end
  fclose(oid);
      
  %% run NetLogo and read output file tXNL23W.txt
  
  tXNL23W = []; % initiate output
  if runNetLogo
    eval(['!netlogo-headless --model ', model, '.nlogo --experiment experiment']); % run NetLogo in background
    out = fopen('tXNL23W.txt', 'r'); % open output-file for reading
    data = fscanf(out,'%e');
    fclose(out);
    n = length(data);
    tXNL23W = wrap(data, floor(n/7), 7); % output (n,7)-array
  else
    path = which('cdCur'); 
    if ismac
      ind = strfind(path,'/'); 
    else
      ind = strfind(path,'\');
    end
    path = path(1:ind(end));
    if ismac || isunix
      system(['cd ', path]);
      system( 'notepad set_pars.txt');
      system( 'notepad spline_JX.txt');
      system( 'notepad spline_TC.txt');
      system( 'netlogo'); % run NetLogo in foreground
    else
      system(['powershell cd ', path]);
      system( 'powershell notepad set_pars.txt');
      system( 'powershell notepad spline_JX.txt');
      system( 'powershell notepad spline_TC.txt');
      system( 'powershell netlogo'); % run NetLogo in foreground
    end
  end

end

function write_spline(txt, tY)
  % text-file spline_txt for use in NetLogo
  %
  % txt: char-string with txt = "TC" or "JX"
  % tY: (n,2)-array with knots
  %
  % writes files spline_TC.txt or spline_JX.txt
  
  n = size(tY, 1);
  oid = fopen(['spline_', txt, '.txt'], 'w+'); % open file for writing, delete existing content
  for i=1:n
  fprintf(oid, '%5.4g %5.4g\n', tY(i,1), tY(i,2));
  end
  fclose(oid);
end
