%% get_tb_foetus
% Obtains scaled age at birth for foetal development.

%%
function [tau_b, lb] = get_tb_foetus(par)
  %  created at 2007/07/28 by Bas Kooijman; modified 2013/08/21
  % modified 2018/09/10 (t -> tau) Nina Marn
  
  %% Syntax
  % [tau_b, lb] = <../get_tb_foetus.m *get_tb_foetus*> (par)
  
  %% Description
  % Obtains scaled age at birth, given the scaled reserve density at birth in case of foetal development. 
  % Divide the result by the somatic maintenance rate coefficient to arrive at age at birth. 
  %
  % Input
  %
  % * par: 1 or 3-vector with parameters g, k_J/ k_M, v_H^b
  
  %       Last 2 values are optional in invoke call to get_lb
  %  
  % Output
  %
  % * tau_b: scaled age at birth \tau_b = a_b k_M
  % * lb: scalar with scaled length at birth 
  %
  %% Remarks
  % Scaled reserve density at birth equals 1. See also <get_tb.html *get_tb*>
  
  %% Example of use
  % get_tb_foetus([.1;.5;.03])
  % See also <../mydata_ue0.m *mydata_ue0*>
  
  % unpack input parameters
  g   = par(1); % energy investment ratio
  k   = par(2); % ratio of maturity and somatic maintenance rate coefficients
  vHb = par(3); %% scaled maturity at birth
  %               (g^2 k_M^3/ v^2) M_H^b/ ((1 - kap) {J_EAm})

  if k == 1
    lb = vHb^(1/ 3); % exact solution for k = 1
    tau_b = 3 * lb/ g;
    return;
  end

  options = odeset('Events',@birth);
  [tau, vH, tau_b] = ode23(@fnget_tb_foetus, [0; 1e8], 0, options, g, k, vHb);
  lb = g * tau_b/ 3;
  
end

% subfunctions

function [val, isterm, dir] = birth(tau, vH, g, k, vHb)
  val = vH - vHb;
  isterm = 1; % stop
  dir = 0; % all directions
end

function dvH = fnget_tb_foetus(tau, vH, g, k, vHb)
  %  tau: scaled age
  %  vH: scaled maturity

  dvH = g^3 * tau^2 * (1 + tau/ 3)/ 9 - k * vH;
end