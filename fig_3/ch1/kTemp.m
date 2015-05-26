function kT = kTemp (p, T)
  %% p: 7-vector with parameters
  %% T: n-vector of temperatures
  %% kT: n-vector with temp-corrected rates

  %% unpack parameters p
  k = p(1);    % reference rate      
  T_1 = p(2);  % reference temp; always fix this parameter
  T_A = p(3);  % Arrhenius temp
  T_L = p(4);  % Lower temp boundary
  T_H = p(5);  % Upper temp boundary
  T_AL = p(6); % Arrh. temp for lower boundary
  T_AH = p(7); % Arrh. temp for upper boundary

  T = T(:,1);
  f = 1 ./ (1 + exp(T_AL ./ T - T_AL/ T_L) + ...
	    exp(T_AH ./ T_H - T_AH ./ T)); % Eq (2.21) {57}
  kT = k * f .* exp(T_A/ T_1 - T_A./ T);   % Eq (2.20) {53}

