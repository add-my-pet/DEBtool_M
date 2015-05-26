function [V, tR, F] = reprod1(p, VVwLN, ttR)
  %% [V, tR, F] = reprod1(p, VVwLN, ttR)
  %% p: vector with parameters
  %% VVwLN: (n,5)-matrix with dummy, eggvol, weight, length, number of eggs
  %% ttR:(1,3)-matrix with dummy, tR
  %% V: (n,1)-matrix with volume of eggs
  %% tR: scalar with tR
  %% F: (n,1)-matrix with f
 
  %% unpack parameters
  v0  = p(9); % mm/d, conversion of U0 to vol of egg

  n = size(VVwLN,1); V = zeros(n,1); F = V;
  for i = 1:n
    [f, in] = find_f(VVwLN(i,[4 5]), p);
    F(i) = f;
    p_isr = p(1:5); p_isr(1) = p(6)/(1 - p(1));
    V(i) = v0 * initial_scaled_reserve(f, p_isr);
    if in ~= 1
      fprintf('no convergence for f\n');
    end
  end

  tR = tr_min(p, VVwLN(:,[4 5]));
