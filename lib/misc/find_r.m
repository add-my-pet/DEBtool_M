function [r, info] = find_r (m_E, k_E, j_EM, y_EV)
  %  created: 2004/08/13 by Bas Kooijman
  %
  %% Description
  %  The function obtains the specific growth rate for a V1-morph with 2 reserves and 1 structure. 
  %  This function is obsolate and will be removed in the future; see
  %  DEBtool/alga/sgr. 
  %  see p169 of DEB-book \cite{Kooy2000}
  %
  %% Input
  %  m_E:  2-vector with mol/mol, reserve densities
  %  k_E:  2-vector with 1/time, reserve turnover rates
  %  j_EM: 2 vector with mol/time.mol, spec maintenance fluxes
  %  y_EV: 2 vector with mol/mol, yields of reserve on structure
  %
  %% Output
  %  r:    scalar with 1/time, spec growth rate
  %
  %% Remarks
  %  called from fig_5_4, fig_5_5
  %
  %% Example of use
  %  find_r([1 .3],[.8 .01], [.02 .03], [1.4 1.3])

  %% check consistency of parameters
  if k_E(1) < 0 | k_E(2) < 0 | ...
	j_EM(1) < 0 | j_EM(2) < 0 | ...
	y_EV(1) < 0 | y_EV(2) < 0 
    r = 0; info = 3;
    return;
  end

  i = 1; info = 1;
  M = m_E ./ y_EV; sM = sum(M); % help quantities
  R = (m_E .* k_E - j_EM) ./ y_EV; % compounding rates
  r = 1/ (sum(1 ./ R) - 1/ sum(R)); % initial estimate for output
  f = 1; % initiate norm; make sure that Newton-Raphson procedure is started
  while f^2 > 1e-20 % test norm
    R = 1e-6 + (m_E .* (k_E - r) - j_EM) ./ y_EV; % compounding rates
    sR = sum(R); s = sum(1 ./ R) - 1/ sR;
    f = r - 1/ s; % norm
    df = 1 + (sum(M ./ R .^2) - sM/ sR^2)/ s^2; % d/dr f
    r = r - f/ df; % new step in NR-procedure
    i = i + 1;
    if i > 20
      %% no convergence
      r = 0; info = 3;
      break
    end
  end