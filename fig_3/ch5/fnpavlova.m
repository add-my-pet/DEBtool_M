function [MV, XP, XB, qP, qB] = fnpavlova(p, H, Xr);
  %% called from pavlova
  %% no coupling between nutrients to form reserves:
  %%  jEiA = fi jEiAm with fi = Xi/ (Xi + Ki) and yEX = 1
  %% excreted nutrients cannot be taken up again

  global KP KB jPAm jBAm kP kB jPM jBM yPV yBV kapP kapB XrP XrB h;
  
  opt = optimset('display','off');
  
  %% unpack parameters
  KP = p(1); KB = p(2); jPAm = p(3); jBAm = p(4);
  kP = p(5); kB = p(6); kMP = p(7); kMB = p(8);
  yPV = p(9); yBV = p(10); kapP = p(11); kapB = p(12);
  XrP = Xr(1); XrB = Xr(2); nr = length(H);

  %% compound parameters
  jPM = yPV * kMP; jBM = yBV * kMB;

  MV = zeros(nr,1); XP = MV; XB = MV; qP = MV; qB = MV; % prefil output variables
  h0 = -1; % initiate former throughput rate; make sure that h0 << h
  for i = 1:nr
    h = H(i,1); % copy appropriate throughput into h
    %% find equilibrium states
    if (h0 - h)^2 > 1e-3
      %% first integrate to get appropriate initial values
      [t, f0] = ode15s('findt_pavlova', [0 2000]', [1, XrP, XrB, jPAm/kP, jBAm/kB, 0, 0]');
      f0 = f0(end,:)'; % state variables at time 2000
    else
      f0 = f; % continuation
    end
    [f, val, info] = fsolve('find_pavlova', f0, opt); f0 = f; % continuation
    if info ~= 1 % trouble
      fprintf(['trouble for point ', num2str(i), '\n']);
      %% first try to solve problem by integration
      f0 = [1, XrP, XrB, jPAm/kP, jBAm/kB, 0, 0]';
      [t, f0] = ode15s('findt_pavlova', [0 2000]', f0);
      f0 = f0(end,:)'; % state variables at time 2000
      [f, val, info] = fsolve('find_pavlova', f0, opt); f0 = f; % continuation
      if info ~= 1 % trouble cannot be solved
        fprintf(['Warning: no steady states found for point ', ...
	       num2str(i), '\n']);
      end
    end
    MV(i) = f(1); % biomass
    %% measured concentration includes excreted concentrations
    XP(i) = f(2) + f(6); XB(i) = f(3) + f(7);
    %% measured cell quota of P,B = reserve per cell + P, B in structure
    qP(i) = yPV + f(4); qB(i) = yBV + f(5);
    
    %% test balances
    P = XrP - XP(i) - MV(i) * qP(i); % P balance
    B = XrB - XB(i) - MV(i) * qB(i); % B balance
    if P^2 + B^2 > 1e-4 % test mass balances
       fprintf(['Warning: mass balances are in error for point ', ...
     	       num2str(i), '\n']);
    end

    %% test biomass being non-negative
    if MV(i) < 0
      fprintf(['biomass negative for point ', num2str(i),', try to solve problem \n']);
      %% first try to solve problem by integration
      f0 = [1, XrP, XrB, jPAm/kP, jBAm/kB, 0, 0]';
      [t, f0] = ode15s('findt_pavlova', [0 2000]', f0);
      f0 = f0(end,:)'; % state variables at time 2000
      [f, val, info] = fsolve('find_pavlova', f0, opt); f0 = f; % continuation
      MV(i) = f(1); XP(i) = f(2) + f(6); XB(i) = f(3) + f(7);
      qP(i) = yPV + f(4); qB(i) = yBV + f(5);
      if info ~= 1 | MV(i) < 0 % trouble cannot be solved
        fprintf(['Warning: no steady states with MV > 0 found for point ', ...
	       num2str(i), '\n']);
      end
    end
    h0 = h; % copy present throughtput into former
  end