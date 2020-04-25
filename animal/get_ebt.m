%% get_ebt
% get population trajectories from Escalaor Boxcar Train

%%
function tXNW = get_ebt(model, par, tT, tJX, x_0, V_X, t_max, numPar)
% created 2020/04/03 by Bas Kooijman
  
%% Syntax
% tXNW = <../get_ebt.m *get_ebt*> (model, par, tT, tJX, x_0, V_X, t_max, numPar)
  
%% Description
% integrates changes in food density and populations, called by ebt, 
%
% environmental variables 
%
%  - TC: temp corr factor
%  - X: food density X
%
% i-states
%
%  - a: t, age
%  - q: 1/d^2, aging acceleration
%  - h_a: 1/d, hazard for aging
%  - L: cm, struc length
%  - E: J/cm^3, reserve density [E]
%  - E_R: J, reprod buffer
%  - E_H: J, maturity
%  - W: g, wet weight
%
% Input:
%
% * model: character-string with name of model
% * par: structure with parameter values
% * tT: (nT,2)-array with time and temperature in Kelvin; time scaled between 0 (= start) and 1 (= end of cycle)
% * tJX: (nX,2)-array with time and food supply; time scaled between 0 (= start) and 1 (= end of cycle)
% * x_0: scalar with initial scaled food density 
% * V_X: scalar with volume of reactor
% * t_max: scalar with time to be simulated
% * numPar: structure with numerical parameter settings  
%
% Output:
%
% * tXNW: (n,4)-array with times, food density, number of individuals, population weight

%% Remarks
%
% * writes spline_TC.c and spline_JX.c (first degree spline function for temp correction and food input)
% * writes ebtmod.exe ebtmod.h, ebtmod.cvf and ebtmod.isf where mod is one of 10 DEB models
% * runs ebtmod.exe in PowerShell, which writes ebtmod.out
% * reads ebtmod.out for output

  % unpack par and compute compound pars
  vars_pull(par); vars_pull(parscomp_st(par));  
    
 %% spline_JX, spline_TC: for environmental variables
  
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
  tTC = tT; tTC(:,2) = tempcorr(tT(:,2), T_ref, par_T);
  write_spline('TC', tTC); TC = tTC(1,2);
  %
  % knots for food density in supply flux
  write_spline('JX', tJX); 
  
 %% DEB model parameters
 
  % initial reserve and states at birth appended to par
  switch model
    case {'stf','stx'}        
      [S_b, q_b, h_Ab, tau_b, tau_0b, u_E0, l_b] = get_Sb_foetus([g k v_Hb h_a s_G h_B0b 0]); 
    otherwise
      [S_b, q_b, h_Ab, tau_b, tau_0b, u_E0, l_b] = get_Sb([g k v_Hb h_a s_G h_B0b 0]);
  end
  E_0 = g * E_m * L_m^3 * u_E0; % J, initial reserve
  kT_M = k_M * TC; aT_b = tau_b/ kT_M; % d, age at birth (temp corrected)
  L_b = l_b * L_m; % cm, length at birth
  Ww_b = L_b^3 * (1 + ome); % g, wet weight at birth
  
  switch model
    case 'ssj'
      pars_ts = [g k 0 v_Hb v_Hs]; [tau_s, tau_b, l_s, l_b] = get_tp(pars_ts, 1);
      tT_s = tau_s/ kT_M; tT_j = tT_s + t_sj; kT_E = k_E * TC;
    case 'abj'
      [tau_j, tau_p, tau_b, l_j, l_p, ~, l_i, rho_j, rho_B] = get_tj([g k l_T v_Hb v_Hj v_Hp]); % -, scaled ages and lengths
      L_j = l_j * L_m;
    case 'asj'
      [tau_s, tau_j, tau_p, tau_b, l_s, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_ts([g, k, 0, v_Hb, v_Hs, v_Hj, v_Hp]); 
      L_s = l_s * L_m; L_j = l_j * L_m;
    case 'abp'
      [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj([g k l_T v_Hb v_Hp-1e-6 v_Hp]); % -, scaled ages and lengths
      L_p = l_j * L_m;
  end
   
  switch model
    case {'std','stf'}
      par = {E_Hp, E_Hb, V_X, h_D, h_J, h_B0b, h_Bbp, h_Bpi, h_a, s_G, thin,  ...
         L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, E_0, L_b, aT_b, ome};
      txtPar = {'E_Hp, J', 'E_Hb, J', 'V_X, L', 'h_D, 1/d', 'h_J, 1/d', 'h_B0b, 1/d', 'h_Bbp, 1/d', 'h_Bpi, 1/d', 'h_a, 1/d', 's_G, -', 'thin, -', ...
          'L_m, cm', 'E_m, J/cm^3', 'k_J, 1/d', 'k_JX, 1/d', 'v, cm/d', 'g, -', ...
          '[p_M] J/d.cm^3', '{p_Am}, J/d.cm^2', '{J_X_Am}, mol/d.cm^2', 'K, mol/L', 'kap, -', 'kap_G, -', ...
          'E_0, J', 'L_b, cm', 'a_b, d', 'ome, -'};
    case 'stx'
      par = {E_Hp, E_Hx, E_Hb, tTC, tJX, V_X, h_D, h_J, q_b, h_Ab, h_Bbx, h_Bxp, h_Bpi, h_a, s_G, thin, ...
          L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, E_0, aT_b};
    case 'ssj'
      par = {E_Hp, E_Hs, E_Hb, tTC, tJX, V_X, h_D, h_J, q_b, h_Ab, h_Bbs, h_Bjp, h_Bpi, h_a, s_G, thin, ...
          L_m, E_m, k_E, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, E_0, aT_b};
    case 'sbp'
      par = {E_Hp, E_Hb, tTC, tJX, V_X, h_D, h_J, q_b, h_Ab, h_Bbp, h_Bpi, h_a, s_G, thin, ...
          L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, E_0, aT_b};
    case 'abj'
      par = {E_Hp, E_Hj, E_Hb, tTC, tJX, V_X, h_D, h_J, q_b, h_Ab, h_Bbj, h_Bjp, h_Bpi, h_a, s_G, thin, ...
          L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, E_0, aT_b};
    case 'asj'
      par = {E_Hp, E_Hj, E_Hs, E_Hb, tTC, tJX, V_X, h_D, h_J, q_b, h_Ab, h_Bbs, h_Bsj, h_Bjp, h_Bpi, h_a, s_G, thin, ...
          L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, E_0, aT_b};
    case 'abp'
      par = {E_Hp, E_Hb, tTC, tJX, V_X, h_D, h_J, q_b, h_Ab, h_Bbp, h_Bpi, h_a, s_G, thin, ...
          L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, E_0, aT_b};
    case 'hep' % nog updaten
      par = {E_Hj, E_Hp, E_Hb, tTC, tJX, V_X, h_D, h_J, q_b, h_Ab, h_Bbp, h_Bpj, h_Bji, h_a, s_G, thin, ...
          L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, E_0, aT_b};
    case 'hex' % nog updaten
      par = {E_He, E_Hj, E_Hb, tTC, tJX, V_X, h_D, h_J, q_b, h_Ab, h_Bbp, h_Bpi, h_a, s_G, thin, ...
          L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G, E_0};
  end
  n_par = length(par); % number of parameters
    
 %% EBTtool: load ebt program, if necessary
 
  % EBTtool is a subdir of DEBtool_M
  % if ~exist('EBTtool','dir') % create EBTtool if not already there
  %  unzip('EBTtool')
  % end
  
%% ebtmod.h: header file 

  fileName = ['ebt', model,'.h'];
  oid = fopen(fileName, 'w+'); % open file for writing, delete existing content
  fprintf(oid, '/***\n');
  fprintf(oid, '  NAME\n');
  fprintf(oid, '    %s\n\n', fileName);
  fprintf(oid, '  PURPOSE\n');
  fprintf(oid, '    header file used by the Escalator Boxcar Train program for DEB models\n\n');
  fprintf(oid, '  HISTORY\n');
  fprintf(oid, '    SK - 2020/04/13: Created by DEBtool_M/animal/get_ebt\n');
  fprintf(oid, '***/\n\n');
  fprintf(oid, '#define POPULATION_NR   1\n');
  fprintf(oid, '#define I_STATE_DIM     8 /* a, q, h_a, L, E, E_R, E_H, W */\n');
  fprintf(oid, '#define I_CONST_DIM     0\n');
  fprintf(oid, '#define ENVIRON_DIM     2 /* time, scaled food density */\n'); 
  fprintf(oid, '#define OUTPUT_VAR_NR   3 /* (time,) scaled food density, nr ind, tot weight */\n');
  fprintf(oid, '#define PARAMETER_NR    %d\n', n_par);
  fprintf(oid, '#define TIME_METHOD     %s /* we need events */\n', numPar.TIME_METHOD);
  if strcmp(numPar.TIME_METHOD, 'DOPRI5')
    events = 2;
  else
    events = 0;
  end
  fprintf(oid, '#define EVENT_NR        %d /*  birth, puberty */\n', events);
  fprintf(oid, '#define DYNAMIC_COHORTS 0\n');
  fclose(oid);
  
 %% ebtmod.cvf: control variable file 
 
  fileName = ['ebt', model, '.cvf'];
  oid = fopen(fileName, 'w+'); % open file for writing, delete existing content
  
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.integr_accurary, numPar.integr_accurary); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.cycle_interval, numPar.cycle_interval); 
  fprintf(oid, '"%s" %5.3e\n\n',  numPar.txt.tol_zero, numPar.tol_zero); 

  fprintf(oid, '"%s" %5.3e\n',  'Maximum integration time', t_max); 
  fprintf(oid, '"%s" %5.3e\n\n',  numPar.txt.time_interval_out, numPar.time_interval_out); 

  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.state_out_interval, numPar.state_out_interval); 
  fprintf(oid, '"%s" %5.3e\n\n',  numPar.txt.min_cohort_nr, numPar.min_cohort_nr); 

  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.relTol_a, numPar.relTol_a); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.relTol_q, numPar.relTol_q); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.relTol_h_a, numPar.relTol_h_a); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.relTol_L, numPar.relTol_L); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.relTol_E, numPar.relTol_E); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.relTol_E_R, numPar.relTol_E_R); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.relTol_E_H, numPar.relTol_E_H); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.absTol_W, numPar.absTol_W); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.absTol_a, numPar.absTol_a); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.absTol_q, numPar.absTol_q); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.absTol_h_a, numPar.absTol_h_a); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.absTol_L, numPar.absTol_L); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.absTol_E, numPar.absTol_E); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.absTol_E_R, numPar.absTol_E_R); 
  fprintf(oid, '"%s" %5.3e\n',  numPar.txt.absTol_E_H, numPar.absTol_E_H); 
  fprintf(oid, '"%s" %5.3e\n\n',  numPar.txt.absTol_W, numPar.absTol_W); 

  for i=1:n_par
  fprintf(oid, '"%s" %5.4g\n',  txtPar{i}, par{i});
  end
  fclose(oid);
  
 %% ebtmod.isf: initial state file 
 
  fileName = ['ebt', model, '.isf'];
  oid = fopen(fileName, 'w+'); % open file for writing, delete existing content
  % initial time, scaled food density; length equals ENVIRON_DIM, empty line added
  fprintf(oid, '%5.4e %5.4e\n\n', 0, x_0); 
  
  % initial #, a, q, h_a, L, E, E_R, E_H, W; length equals 1+I_STATE_DIM, empty line added
  fprintf(oid, '%5.4e %5.4e %5.4e %5.4e %5.4e %5.4e %5.4e %5.4e %5.4e %5.4e\n\n', 1, 0, q_b, h_Ab, L_b, E_m, 0, E_Hb, Ww_b); 

fclose(oid);
  % initial i-states are values at birth, but for t < a_b, changes in i-states are set to 0
  
%% Detlete existin out-file
  
  delete('*.out')

%% ebtmod.exe: run EBTtool

  WD = cdEBTtool;  
  txt = ['!gcc -DPROBLEMFILE="<', pwd, '\deb\ebt', model, '.h>" -o '];
  TXT = ['!gcc -IOdesolvers\ -DPROBLEMFILE="<', pwd, '\deb\ebt', model, '.h>" -o '];
  TxT = ['!gcc -I. -I.\fns -DPROBLEMFILE="<', pwd, '\deb\ebt', model, '.h>" -o '];
  eval([txt, 'ebtmain.o  -c fns\ebtmain.c']);
  eval([txt, 'ebtinit.o  -c fns\ebtinit.c']);
  eval([TXT, 'ebttint.o  -c fns\ebttint.c']);
  eval([txt, 'ebtcohrt.o -c fns\ebtcohrt.c']);
  eval([txt, 'ebtutils.o -c fns\ebtutils.c']);
  eval([txt, 'ebtstop.o  -c fns\ebtstop.c']);
  eval([TxT, 'ebtstd.o   -c deb\ebtstd.c']);
  eval(['!gcc -o ebt', model, '.exe ebtinit.o ebtmain.o ebtcohrt.o ebttint.o ebtutils.o ebtstop.o ebt', model, '.o -lm']); % link o-files in ebtmod.exe
  delete('*.o')
  eval(['!.\ebt', model, '.exe ebt', model]); % run EBTtool using input files run.cvf and run.isf

  cd(WD);
%% ebtmod.out: read output variable file 

  out = fopen(['ebt', model, '.out'], 'r');
  data = fscanf(out,'%e');
  fclose(out);
  n = length(data);
  tXNW = wrap(data, floor(n/4), 4); % output (n,4)-array
  
  % read report file run.rep
  % read end state file run.esf
  % read complete state output file run.cso
  % read complete state binary output file run.csb

end



function [value,isterminal,direction] = puberty(t, Xvars, E_Hp, varargin)
  n_c = (length(Xvars) - 1)/ 7; % #, number of cohorts
  E_H = Xvars(1+5*n_c+(1:n_c)); % J, maturities, cf cpm_unpack
  value = min(abs(E_H - E_Hp)); % trigger 
  isterminal = 0;  % continue after event
  direction  = []; % get all the zeros
end

function [value,isterminal,direction] = leptoPub(t, Xvars, E_Hp, E_Hs, varargin)
  n_c = (length(Xvars) - 1)/ 7; % #, number of cohorts
  E_H = Xvars(1+5*n_c+(1:n_c)); % J, maturities, cf cpm_unpack
  value = [E_H(1) - E_Hs,  min(abs(E_H - E_Hp))]; % triggers 
  isterminal = [1 1];  % stop at event
  direction  = []; % get all the zeros
end

function write_spline(txt, tY)
  % writes c-function spline_txt
  % that function takes a scalar argument and returns a scalar interpolated value
  % the knots of this spline1 function are assigned inside the function
  %
  % txt: char-string with txt = "TC" or "JX"
  % tY: (n,2)-array with knots
  %
  % writes files spline_TC.c or spline_JX.c
  
  fnName = ['spline_', txt]; fileName = [fnName, '.c']; n = size(tY, 1);
  oid = fopen(fileName, 'w+'); % open file for writing, delete existing content
  fprintf(oid, 'double %s(double tt)\n', fnName);
  fprintf(oid, '{\n');
  fprintf(oid, '  int i, n; n = %d;\n', n);
  fprintf(oid, '  double t[n+1], %s[n+1];\n\n', txt);
  for i=1:n
  fprintf(oid, '  t[%d] = %5.4g; %s[%d] = %5.4g;\n', i, tY(i,1), txt, i, tY(i,2));
  end
  fprintf(oid, '\n');
  fprintf(oid, '  for (i = n - 1; i >= 1; i--)\n');
  fprintf(oid, '  {\n');
  fprintf(oid, '    if (tt - t[i] >= 0)\n');
  fprintf(oid, '      break;\n');
  fprintf(oid, '  }\n\n');
  fprintf(oid, '  return %s[i] + (tt - t[i]) * (%s[i+1] - %s[i])/ (t[i+1] - t[i]);\n\n', txt, txt, txt);
  fprintf(oid, '}\n');
  fclose(oid);
end
