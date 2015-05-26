%% o2f_init
% Reconstructs food density trajectors from otolith opacity profiles

%%
function tcfeLLOO = o2f_init (LOO, TC, par, L)
  % created by Bas Kooijman at 2009/10/29
  
  %% Description
  % From otolith opacity O to scaled func response f: initial estimate
  %
  %   L is obtained from LO under asummption of constant food and temp
  %   t is ottained from L under assumption of constant food
  %   f = e and is obtained from O given L and t
  %
  % The routine reconstructs time-trajectories of scaled function response, scaled reserve density, body length, otolith length, opacity from otolith length-opacity data, given DEB parameters and temperature correction factors over time. 
  % The reconstructed body length at otolith collection can be compared to the observed body length as an independent check on the reliability of the reconstruction. 
  % The assumption k_J = k_M is made to ensure stage transitions at fixed length. 
  % Opacity is zero for contribution of dissipation and one of growth. 
  % Opacity, therefore, is always on the interval (0,1). 
  % Measured opacity might need some rescaling to fit these requirements. 
  % Otolith and body length are treated as volumetric length; measured lengths might need rescaling. 
  %
  % Input
  %
  % * LOO: (n,2)-matrix with otolith length LO and opacity O
  %
  %     LO should increase from LO_b; n > 2
  %     opacity = 0 if only maintenance, 1 if only growth contributes
  %
  % * TC: (n,2)-matrix with time, temp correction factor
  %
  %      TC(1,1) = 0 time at birth; TC(n,1) = time at collection LOO(n, :)
  %
  % * par: 10-vector with parameters:
  %    L_b, L_p, v, v_OD, v_OG, k_M, g, kap, kap_R, del_S 
  % * L: scalar with body length at otolith collection
  %
  % Output
  %
  % * tcfeLLOO: (n,7)-matrix with t, c_T, f, e, L, LO, O
  
  %% Remarks
  % Routine <o2f_init.html *o2f_init*> is similar; the reconstruction is faster, more robust, but much less accurate (especially the time points). 
  % It assumes e = f and constant f for parts of the reconstruction and requires body length at otolith collection as fourth input. 
  % It is only of use if <code>o2f</code> fails. 
  % Function <f2o.html *f2o*> is inverse to <o2f.html *o2f*> and can be used for checking. 
  % The theory behind *o2f* and *f2o* is discussed in <href="/thb/research/bib/PecqKooy2008.html" *PecqKooy2008*>

  %% Example of use
  % See <.../mydata_of.m *mydata_of*>

  global t f_mean E_obs L_obs LO_obs O_obs LO_end L_end t_end cor_T % tofno2f*
  global Li rB 
  global tc v vOD vOG Lb Lp Lm g kap kapR delS

  options = optimset('Display','off');
  nmregr_options('default');
  nmregr_options('report',0);
  
  tc = TC; L_end = L; % copy to allow global vars

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

  n = size(LOO,1);
  Lm = v/ kM/ g; LO_end = LOO(n,1); t_end = tc(n,1);
  LOb = LOO(1,1);

  % first assume contant temperature
  cor_T = sum(tc(:,2))/ n; % mean correction factor
  % assume constant food density
  [f_mean, flag, info] = fsolve('fno2f_f', .9, options); % mean f
  if info~= 1
    fprintf('no convergence for mean func response \n');
    return
  end
  rB = kM * g/ 3/ (f_mean + g); % mean von Bert growth rate
  Li = f_mean * Lm; % ultimate length
  [LO L] = ode23s('do2f_l', LOO(:,1), Lb); % length at constant food
  [L t_obs] = ode23('do2f_t', L, 0); % time at length for constant food
  % determine correction factor for time to ensure L = L_end at t_end
  cor_t = t_end/ t_obs(end);

  tcfeLLOO = zeros(0,7); % initiate output

  for i = 1:n
    LO_obs = LOO(i,1); O_obs = LOO(i,2); 
    L_obs = L(i); 
    t = cor_t * t_obs(i);
    cor_T = spline1(t,tc);
    if O_obs == 0
      E = L_obs/ Lm;
    else
      [E, flag, info] = fsolve('fno2f_e', f_mean, options);
      % [E, info] = nmregr('fno2f_e', f_mean, zeros(1,2));
      % ssq('fno2f_e',E,zeros(1,2))
      if info~= 1
        fprintf(['no convergence at point ', num2str(i),'\n']);
      end
    end
    tcfeLLOO_t = [t cor_T E E L_obs LO_obs O_obs];
    tcfeLLOO = [tcfeLLOO; tcfeLLOO_t];
  end

  tcfeLLOO(1,3) = tcfeLLOO(2,3); % overwrite f at birth
