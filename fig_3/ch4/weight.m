function w = weight(p, t, n)
  %% called from fig_7_1
  %% p: 5-vector with parameters
  %% t: nt-vector with scaled times
  %% n: scalar, number of simulations
  %% (nt,n)-matrix with scaled weights

  global g f

  if exist ('n','var') == 0
    n = 1; 
  end
  
  %% unpack parameters
  lab0 = p(1); lab1 = p(2); g = p(3); lb = p(4); d = p(5); % see growthrt

  nt = length(t); w = zeros(nt,n); % initiate output
  for j = 1:n
    T0 = 0; % evaluation time (point of switch from feeding to starving
    el0 = [1; lb]; % initial condition; start in starving mode
    il = 0; % lower boundary index of t  
    while T0 < t(nt)
      T1 = min(t(nt) + 1e-4, T0 + exprnd(lab0)); f = 0; % starving mode
      iu = sum(t < T1); id = iu - il;
      if iu > il
	    T = [T0; t((il+1):iu); T1];
        [T, el] = ode45('growthrt', T, el0); el(1,:) = [];
        w((il+1):iu, j) = el(1:id, 2) .* (1 + d * el(1:id, 1)) .^ (1/3);
	    el0 = el(id + 1,:);
      else % no time points between switch points
	    T = [T0; T1];
        [T, el] = ode45('growthrt', T, el0); 
        el0 = el(end,:);
      end
      
      T0 = T1; il = iu;  
      T1 = min(t(nt)+ 2e-4, T0 + exprnd(lab1)); f = 1; % feeding mode
      iu = sum(t < T1); id = iu - il;
      if iu > il
	    T = [T0; t((il+1):iu); T1];
        [T, el] = ode45('growthrt', T, el0); el(1,:) = [];
        w((il+1):iu,j) = el(1:id, 2) .* (1 + d * el(1:id, 1)) .^ (1/3);
	    el0 = el(id + 1,:);
      else % no time points between switch points
	    T = [T0; T1];
        [T, el] = ode45('growthrt', T, el0); 
        el0 = el(end,:);
      end
      T0 = T1; il = iu;
    end
  end