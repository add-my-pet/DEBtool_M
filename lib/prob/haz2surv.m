%% haz2surv
% Obtains the survival probability from the hazard rate

%%
function S = haz2surv(fnm, t)
  
  %% Syntax
  % S = <../haz2surv.m *haz2surv*> (fnm, t)

  %% Description
  % Obtains the survival probability from the hazard rate
  %
  % Input:
  %
  % * fnm: string with name of function that specifies hazard
  %
  %       this function must be of the form: h = haz(x,t)
  %       where x is a dummy, and t the time
  %
  % * t: n-vector with time points
  %
  % Output
  %
  % * S = (n,1)-matrix with time and survival probabilities
  
  %% Example of use 
  % see <../mydata_haz2surv.m *mydata_haz2surv*>

  t = [-1e-6; t(:)]; % prepent zero for time points
  eval(['[t, ch] = ode45(''', fnm, ''', t, 0);']); % cumulative hazard
  S = exp( - ch); S(1) = []; % survival probability

