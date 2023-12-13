%% get_IBMnlogo_std211
% get population trajectories from NetLogo

%%
function txxNL23W = get_IBMnlogo_std211(model, par, tT, tJX1, tJX2, X1_0, X2_0, V_X, t_R, t_max, tickRate, runNetLogo)

% created 2023/10/12 by Bas Kooijman
  
%% Syntax
% txxNL23W = <../get_IBMnlogo_std211.m *get_IBMnlogo_std211*> (model, par, tT, tJX1, tJX2, X1_0, X2_0, V_X, t_R, t_max, tickRate, runNetLogo)
  
%% Description
% Gets trajectories of  food density and populations, using NetLogo, 
%
% environmental variables 
%
%  - TC: temp corr factor
%  - X1: food density X1
%  - X2: food density X2
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
% * tJX1: (nX1,2)-array with time and food 1 supply; time scaled between 0 (= start) and 1 (= end of cycle)
% * tJX2: (nX2,2)-array with time and food 2 supply; time scaled between 0 (= start) and 1 (= end of cycle)
% * X1_0: scalar with initial food 1 density 
% * X2_0: scalar with initial food 2 density 
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
% * txxNL23W: (n,8)-array with times and densities of scaled food, total number, length, squared length, cubed length, weight

%% Remarks
%
% * writes spline_TC.txt and spline_JX1.txt spline_JX2.txt (first degree spline function for temp correction and food input)
% * writes mod.nlogo,  where mod is std211 DEB model, and eaLE.txt with embryo settings for interpolation withing NetLogo
% * runs NetLogo in Window's PowerShell, which writes txxNL23W.txt
% * reads txxNL23W.txt.out for output

  % unpack par and compute compound pars
  vars_pull(par); vars_pull(parscomp_st(par));  
  
  %% write spline_JX1.txt, spline_JX2.txt, spline_TC.txt for environmental variables
  
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
  write_spline('JX1', tJX1); 
  write_spline('JX2', tJX2); 
  
  %% write eaLE.txt for embryo & pupa -setting
 
  eaLE = zeros(10,4);
  [e_b, l_b, u_E0, info] =  get_eb_min([g, k, v_Hb], 1); % minimum value for e_b
  e = linspace(e_b+1e-3, 1, 10);

  switch model
    case {'stf','stx'} % foetal development
      for i = 1:10
        [tau_b, l_b] = get_tb_foetus([g, k, v_Hb]);
        u_E0 = get_ue0_foetus([g, k, v_Hb], e(i));
        eaLE(i, :) = [e(i), tau_b/ k_M, l_b * L_m, g * E_m * L_m^3 * u_E0];
      end
    otherwise % egg development
      for i = 1:10
        [tau_b, l_b] = get_tb([g, k, v_Hb], e(i));
        u_E0 = get_ue0([g, k, v_Hb], e(i));
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
  if ~exist('E_Hpm', 'var') && exist('E_Hp', 'var')
    E_Hpm = E_Hp; 
  end
  if exist('z_m', 'var')
    p_Amm = z_m * p_M/ kap;
  else
    p_Amm = p_Am;
  end
  
      % specify input parameters, to be written in set_pars.txt
      par = {tickRate, ...
          t_max, X1_0, X2_0, V_X, ...
          mu_X1, mu_X2, h_X1, h_X2, ...
          h_B0b, h_Bbp, h_Bpi, ...
          thin, h_J, h_a, s_G, ...
          E_Hb, E_Hp, E_Hpm, fProb, ...
          kap, kap_X1, kap_X2, kap_G, kap_R, ...
          t_R, F_m, p_Am, p_Amm, ...
          v, p_M, k_J, k_JX, ...
          E_G, ome};
      txtPar = {'tickRate', ...
          't_max', 'X1_0', 'X2_0', 'V_X', ...
          'mu_X1', 'mu_X2', 'h_X1', 'h_X2', ...
          'h_B0b', 'h_Bbp', 'h_Bpi', ...
          'thin', 'h_J', 'h_a', 's_G', ...
          'E_Hb', 'E_Hp', 'E_Hpm', 'fProb', ...
          'kap', 'kap_X1', 'kap_X2', 'kap_G', 'kap_R', ...
          't_R', 'F_m', 'p_Am', 'p_Amm', ...
          'v', 'p_M', 'k_J', 'k_JX', ...
          'E_G', 'ome'};
  
  % write parameter settings
  n_par = length(par); % number of parameters
  oid = fopen('set_pars.txt', 'w+'); % open file for writing, delete existing content
  for i = 1:n_par
    fprintf(oid, '"set %s %5.4g"\n', txtPar{i}, par{i});
  end
  fclose(oid);
      
  %% run NetLogo and read output file tXXNL23W.txt
  
  model = 'std211';
  txxNL23W = []; % initiate output
  if runNetLogo
    eval(['!netlogo-headless --model ', model, '.nlogo --experiment experiment']); % run NetLogo in background
    out = fopen('txxNL23W.txt', 'r'); % open output-file for reading
    data = fscanf(out,'%e');
    fclose(out);
    n = length(data);
    txxNL23W = wrap(data, floor(n/8), 8); % output (n,8)-array
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
      system( 'notepad spline_JX1.txt');
      system( 'notepad spline_JX2.txt');
      system( 'notepad spline_TC.txt');
      system( 'netlogo'); % run NetLogo in foreground
    else
      system(['powershell cd ', path]);
      system( 'powershell notepad set_pars.txt');
      system( 'powershell notepad spline_JX1.txt');
      system( 'powershell notepad spline_JX2.txt');
      system( 'powershell notepad spline_TC.txt');
      system( 'powershell netlogo'); % run NetLogo in foreground
    end
  end

end

function write_spline(txt, tY)
  % text-file spline_txt for use in NetLogo
  %
  % txt: char-string with txt = "TC" or "JX1" or "JX2"
  % tY: (n,2)-array with knots
  %
  % writes files spline_TC.txt or spline_JX1.txt or spline_JX2.txt
  
  n = size(tY, 1);
  oid = fopen(['spline_', txt, '.txt'], 'w+'); % open file for writing, delete existing content
  for i=1:n
  fprintf(oid, '%5.4g %5.4g\n', tY(i,1), tY(i,2));
  end
  fclose(oid);
end
