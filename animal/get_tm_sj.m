%% get_tj 
% Gets scaled median life span for short growth periods

%%
function [tau_m, info] = get_tm_sj (par, f)
  % created at 2025/03/18 by Bas Kooijman, 
  
  %% Syntax
  % [tau_m, info] = <../get_tm_sj.m *get_tm_sj*> (par, f)
  
  %% Description
  % Obtains scaled median life span for growth period that short relative to life span. 
  % Allows for metabolic acceleration (std and abj models). 
  %
  % Input
  %
  % * par: 2, 3 or 4-vector with parameters: g, h_a, s_G, s_M, where s_G = 0 and s_M = 1 by default 
  % * f: optional scalar with functional response (default f = 1) 
  %  
  % Output
  %
  % * tau_m: scaled median life span
  % * info: indicator equals 1 if successful, 0 otherwise
  
  %% Remarks
  % The theory behind these computations is presented in the comments on DEB3 for 7.8.2
 
  %% Example of use
  %  get_tm_sj([.5, .1])
   
  g = par(1); h_a = par(2); 
  if length(par)<3 || isempty(par(3)); s_G = 0; else s_G = par(3); end
  if length(par)<4; s_M = 1; else s_M = par(4); end 
  if ~exist('f','var'); f = 1; end
  
  if s_G >0.05
    h_G = s_G * s_M^3 * f^3 * g; % scaled Gompertz ageing rate
    h3_W = h_a * g/ 6; % scaled Weibull aging rate
    get_tau_m =  @(tau_m, h3_W, h_G) log(2) + 6 * h3_W/ h_G^3 * (1 - exp(tau_m * h_G) + tau_m * h_G + tau_m^2 * h_G^2/ 2);
  
    [tau_m, fval, flag]  = fzero(@(tau) get_tau_m(tau, h3_W, h_G), 1);
    if ~flag==1; info = 0; else info = 1; end
  else
    h_W = (h_a * g/ 6)^(1/3); tau_m = log(2)/h_W; info = 1;  
  end
end