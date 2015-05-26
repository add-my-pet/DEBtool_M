%% o2f
% Reconstructs food density trajectors from otolith profiles

%%
function tcfeLLOO = o2f(LOO, TC, par)
  % created by Bas Kooijman, 2007/08/29, modified 2009/09/29
  
  %% Syntax 
  % tcfeLLOO = <../o2f.m *o2f*> (LOO, TC, par)
  
  %% Description
  % From otolith opacity O to scaled functional response f
  % See <f2o.html *f2o*>
  %
  % Input
  %
  % * LOO: (n,2)-matrix with otolith length LO and opacity O;
  %
  %      LO should increase from LO_b; n > 2
  %      opacity = 0 if only maintenance, 1 if only growth contributes
  %
  % * TC: (n,2)-matrix with time, temp correction factor
  %
  %     TC(1,1) = 0 time at birth; TC(n,1) = time at collection LOO(n, :)
  %
  % * par: 10-vector with parameters:
  %    Lb, Lp, v, vOD, vOG, kM, g, kap, kapR, delS
  %
  % Output
  %
  % * tcfeLLOO: (n,7)-matrix with t, c_T, f, e, L, LO, O
  
  %% Example of use
  % See <.../mydata_of.m *mydata_of*>

  global t_obs E_obs L_obs LO_obs O_obs % tofno2f*
  global t t_old f_old E_old L_old LO_old % to fno2f*
  global f E L LO O dLO cor_T % from fno2f*
  global tc v vOD vOG Lb Lp Lm g kap kapR delS

  options = optimset('TolFun',1e-9,'TolX',1e-9,'Display','off'); % silence fsolve
  ode_options = odeset('AbsTol',1e-9,'RelTol',1e-9);
  nmregr_options('default'); % nmregr is used if fsolve fails
  nmregr_options('report',0); % silence nmregr
  nrregr_options('report',0); % silence nmregr
  nrregr_options('max_norm',1e-16);

  
  if isempty(TC)
    tc = [0 1; 10000 1];
  else
    tc = TC; % copy to make it global
  end

  % unpack par
  Lb = par(1); % cm, length at birth
  Lp = par(2); % cm, length at puberty
  v = par(3);  % cm/d, energy conductance
  vOD = par(4); % mum/d, otolith growth linked to dissipation
  vOG = par(5); % mum/d, otolith growth linked to body growth
  kM = par(6); % 1/d, maintenance rate coefficient 
  g = par(7);  % -, energy investment ratio
  kap = par(8); % -, fraction to som maint + growth
  kapR = par(9); % -, reproduction efficiency
  delS = par(10); % -, shape coefficient for otosac

  Lm = v/ kM/ g; % maximum length; only application of kM

  n = size(LOO,1); % number of data points
  t = 0; % time at birth

  % situation at birth
  LO_obs = LOO(1,1); O_obs = LOO(1,2); L_obs = Lb;
  cor_T = spline1(0,tc);
  [eb, flag, info] = fsolve('fno2f_e', 1, options);
  if info ~= 1 % try to repair convergence problems
    [eb, info] = nrregr('fno2f_e', 1, zeros(1,2));
    if info ~= 1
      fprintf('no convergence at point 1\n');
      return
    end
  end
  tcfeLLOO = [t cor_T 0 eb L_obs LO_obs O_obs]; % f = 0 will be overwritten
  E = eb; L = L_obs; LO = LO_obs;
  vT = v * cor_T;  % energy conductance
  SC = cor_T * L ^ 2 * (g + L/ Lm) * E/ (g + E); % p_C/ {p_Am}
  SM = cor_T * kap * L^3/ Lm; % p_M/ {p_Am}
  SG = max(0, kap * SC - SM); % p_G/ {p_Am}
  SD = (SM + (1 - kap) * SG)/ kap; % p_D/ {p_Am}
  vSG = vOG * max(0,SG);
  svS = vOD * SD + vSG;
  dLO = svS * (1 - delS * LO^3/ L^3)/ 3/ LO^2; % change in vol otolith length
  % required for initial estimate of nex time point

  % first data point after birth; f = constant since birth
  LO_old = tcfeLLOO(6); LO_obs = LOO(2,1); DLO = LO_obs - LO_old; O_obs = LOO(2,2);
  E_old = eb; L_old = Lb;
  dt = DLO/ dLO; f = eb;
  [tf, flag, info] = fsolve('fno2f_tf', [dt; f], options);
  if info ~= 1 % try to repair convergence problem
    [tf, info] = nmregr('fno2f_tf', [dt; f], zeros(2,2));
    if info ~= 1
      fprintf('no convergence at point 2\n');
      return
    end
  end
  t_obs = tf(1); f_obs = tf(2); L_obs = L; E_obs = E; LO_obs = LO; % from fnget_tf
  cor_T = spline1(t, tc);
  tcfeLLOO(3) = f_obs; % overwrite f at t = 0
  tcfeLLOO = [tcfeLLOO; [t_obs cor_T f_obs E_obs L_obs LO_obs O]]; % append to output
  df = 0; % initiate change in f
  ddf = .001;

  % third and later output points; f = changing linearly in time
  for i = 3:n
    % unpack states
    t_old = tcfeLLOO(i - 1, 1); f_old = tcfeLLOO(i - 1, 3); 
    E_old = tcfeLLOO(i - 1, 4); L_old = tcfeLLOO(i - 1, 5); 
    LO_old = LOO(i - 1, 1); LO_obs = LOO(i,1); 
    O_old = LOO(i - 1, 2); O_obs = LOO(i,2);
        
    if O_obs == 0 && O_obs == O_old % no growth, limited access to f
      df = 0; % no change in f
      [LO, teL] = ode23s('dfno2f_tel', [LO_old; LO_obs], [t_old; E_old; L_old],ode_options);
      t_obs = teL(end,1); L_obs = L_old; E_obs = L_obs/ Lm; f_obs = E_obs; O = O_obs;
      cor_T = spline1(t_obs, tc);
      
    else % growth conditions
      if O_old == 0 && O_obs > 0 % special treatment for resuming growth to find df
        % the change in df is too sudden for convergence if continuation is applied
        fn_new = 1000 * O_obs; df = 0; j = 0;
        while fn_new > 0 && j < 1000
          df = df + ddf; j = j + 1;
          fn_old = fn_new; fn_new = fno2f(df);
        end
        df = df + ddf * fn_new/ (fn_old - fn_new);
        % [df, flag, info] = fsolve('fno2f', df, options); 
        % nmregr_options('report',1);
        [df info] = nrregr('fno2f', df, [0 0]); df = df(1);
        if info ~= 1
          fprintf(['no convergence at point ', num2str(i), ' after awakening \n']);
          df = 0.5; % for next call after convergence failure
          % return
        end
      else 
        [df, info] = nmregr('fno2f', df, [0 0]); df = df(1); % continuation
        [df, info] = nrregr('fno2f', df, [0 0]); df = df(1); % continuation
        if info ~= 1 || isnan(df)  % try to repair convergence problem
          [df, info] = nmregr('fno2f', 1e-8, zeros(1,2)); df = df(1);
          [df, info] = nrregr('fno2f', df, [0 0]); df = df(1); % continuation
          if info ~= 1 || isnan(df)% drastic repair attempt
            garegr_options('report', 1); garegr_options('max_evol', 5);
            garegr_options('max_step_number', 5); garegr_options('popSize', 500);
            [df, info] = garegr('fno2f', [0 1 -.5 .5], zeros(1,2)); df = df(1);% try again with garegr
            garegr_options('report',0);
            [df, info] = nmregr('fno2f', df(1), zeros(1,2)); df = df(1);% improve accuracy
            [df, info] = nrregr('fno2f', df, zeros(1,2)); % improve accuracy further
            if info ~= 1
              fprintf(['no convergence at point ', num2str(i), '\n']);
              df = 0; % for next call after convergence failure
              % return
            end
          end
        end
      end   
      f_obs = max(L_obs/ Lm, min(1, f_old + df * (t_obs - t_old)));
      E_obs = max(E_obs, L_obs/ Lm);
    end
    fprintf(['i = ', num2str(i), '; t = ', num2str(t_obs), '; f = ', num2str(f_obs), ...
            '; e = ', num2str(E_obs), '; L = ', num2str(L_obs), ...
            '; LO = ', num2str(LO_obs), '; O = ', num2str(O_obs), '; df = ', num2str(df), '\n']);
  
    % append to output
    tcfeLLOO_i = [t_obs cor_T f_obs E_obs L_obs LO_obs O];
    tcfeLLOO = [tcfeLLOO; tcfeLLOO_i];
  end
