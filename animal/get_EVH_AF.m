%% get_EVH_AF
% reserve energy, structure, maturity for pregnant females (with upregulation) and foetus (stops
% at weaning)

%%
% function [a, EVH_AF, a_g, t_x] = get_EVH_AF(a, EVH_AF_0, pars_AF)
function prd = get_EVH_AF(a, EVH_AF_0, pars_AF)
  % created by Dina Lika 2019/06/11
   %% Syntax
  % prd = <..get_EVH_AF.m *get_EVH_AF*> (a, EVH_AF_0, pars_AF)
  
  %% Description
  % reserve energy, structure and maturity 
  %    (quantified as cumulated investedment into maturation in the form of reserve), 
  % given constant food density, for adult pregnant female and foetus. 
  %
  % Input
  %
  % * a: (n,1)-matrix with ages
  % * EVH_AF_0: (1, 6)-vector with initial values for the odes
  % * pars_AF: vector with parameters for dget_EVH_AF
  %   pars_AF = [p_Am, p_FAm, v, v_F, kap, kap_R, kap_RL, p_M, k_J, E_G, E_Hb, E_Hx, E_Hp, E_m, t_0, S_eff, Npups, f, t_mate]; % temp-correct and pack pars for dget_EVR_AF
  %  
  % Output
  % * prd: structure with:
  % * a: (n,1)-matrix with ages
  % * EVH_AF: (n,6)-matrix with
  %   energy in reserve, E, structural volume V, energy in reproductive reserve, E_R, of the mother
  %   energy in reserve, E_F, structural volume, V_F, energy invested to maturation, EH_F, of foetus
  % * a_g: age at birth
  % * t_x: time since birth at weaning
  %% Example of use
  % See mydata_get_EVH_AF
    
  options = odeset('Events', @event_bx); 
  [a, EVH_AF, te, ye, ie] = ode23s(@dget_EVH_AF, a, EVH_AF_0, options, pars_AF);

  a_mating = pars_AF(19);  % d, age at mating
  a_g = te(1)- a_mating;   % d, gestation time at f and T
  t_x = te(2)- te(1);      % d, time since birth at weaning at f and T  
  
  % pack output
    prd.a = a;
    prd.EVH_AF = EVH_AF;
    prd.a_g = a_g;
    prd.t_x = t_x;

end
%% 
function [value,isterminal,direction] = event_bx(t, EVH_AF, pars_AF)
  % EVH_AF: 6-vector with [E, V, E_R, E_F, V_F, EH_F]
  E_Hb = pars_AF(11); E_Hx = pars_AF(12);
  value = [E_Hb; E_Hx] - EVH_AF(6);
  isterminal = [0; 1]; % stop at weaning
  direction = [0; 0]; 
end