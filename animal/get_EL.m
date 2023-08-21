%% get_EL
% ODE for reserve density and structural length for std model for varying
% food

%%
function dEL = get_EL(t, EL, tf, v, g, E_m, L_m, p_Am)
% t: scalar with time
  % EL: 1-2 vector with  reserve density [E], J/cm^3 and structural length,
  % L 
  % dEL: n-2 matrix with d/t E and L
  % 

  E = EL(1); % J/cm^3, reserve density [E}
  L = EL(2); % cm, structural length
  
  f = spline1(t, tf);                    % -, scaled functional response at t
  dE = (f * p_Am - E * v)/ L;            % J/d.cm^3, change in reserve density d/dt [E]
  e = E/ E_m;                            % -, scaled reserve density
  r = v * (e/ L - 1/ L_m)/ (e + g);      % 1/d, specific growth rate
  dL = L * r/ 3;                         % cm/d, change in structural length d/dt L
  
  dEL = [dE; dL]; % catenate for output
end

