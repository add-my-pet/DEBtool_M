function L = shiftbert(t, ts, ud, p)
  %% called from fig_7_2
  %% t: vector with time points
  %% ts: scalar with time of shift up or down
  %% ud: scalar with identifier for up or down shift: ud = 0: down shift
  %%     down: p(5) applies before shift, p(4) after shift
  %% p: 5-vector with parameters; see bert2
  
  global f Lm v g
  %% unpack parameters
  Lb = p(1); g = p(2); kM = p(3); v = p(4); f1 = p(5); f2 = p(6);
  Lm = v/ (kM * g); Li1 = f1 * Lm; Li2 = f2 * Lm; % max and ulti length
  rB1 = 1/ (3/ kM + 3 * Li1/ v); rB2 = 1/ (3/ kM + 3 * Li2/ v); % v Bert
  nt = length(t); L = t; % initiate output
  int = sum(t<ts); int1 = 1:int; int2 = (int + 1):nt; %indices

  if ud == 0 % shift down
    L(int1) = Li2 - (Li2 - Lb) * exp( - rB2 * t(int1));
    Le0 = [Li2 - (Li2 - Lb) * exp( - rB2 * ts); f2]; f = f1;
    [T, l] = ode45('dbert2a', [0;t(int2)-ts], Le0); l(1,:)=[];
    L(int2) = l(:,1);
  else % shift up
    L(int1) = Li1 - (Li1 - Lb) * exp( - rB1 * t(int1));
    Le0 = [Li1 - (Li1 - Lb) * exp( - rB1 * ts); f1]; f = f2;
    [T, l] = ode45('dbert2a', [0;t(int2)-ts], Le0); l(1,:)=[];
    L(int2) = l(:,1);
  end