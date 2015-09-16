%% statistics_std
% Computes implied properties of standard DEB model 

function [stat, txt_stat] = statistics_std(par, T, fStat, model) %% T_ref from metapar or input like T?
% created 2000/11/02 by Bas Kooijman, modified 2014/03/17 
% created 2015/03/25 by Starrlight Augustine & Goncalo Marques, 
% last modified 2015/07/27 by starrlight
% modified 2015/08/06 by Dina Lika

%% FUNCTION STILL UNDER CONSTRUCTION

%% Description
% Computes quantites which depend on parameters, temperature and food
% level.
%
% Standard DEB model
%
% Inputs:
%
% * par :  structure with primary parameters at reference temperature
% * T:     scalar with temperature in Kelvin
% * fStat:     scalar (between 0 and 1) scaled functional response
% * model: 3 letter string with model key
% NOTA : fStat is used to not be confused with  par.f

% Output:
% 
% * structure with statistics

%% Syntax
% stats = statistics_std(par, T, f, model)

%% Comments
% If the shape coefficient $\delta_M$ is not in the par structure then the
% values of the physical length will be NaN.


%% Example


 par.f = fStat; %fStats is user-defined and replaces par.f
 filternm = ['filter_', model];
 [pass, flag]  = feval(filternm, par);
 if ~pass 
      print_filterflag(flag);
      error('    The parameter set is not realistic');
 end

cPar = parscomp_st(par);
vars_pull(cPar);  vars_pull(par);

par_names = fields(par);
% mat_lev = par_names(strncmp(par_names, 'E_H', 3));
% mat_ind = strrep(mat_lev, 'E_H', '');  % maturity levels' indices
% 
% for i = 1:length(mat_ind)
%   switch mat_ind{i}
%     case 'b'
%       mat_label{i} = 'at birth';
%     case 'j'
%       mat_label{i} = 'at metamorphosis';
%     case 'p'
%       mat_label{i} = 'at puberty';
%     case 'h'
%       mat_label{i} = 'at hatching';
%     case 'x'
%       mat_label{i} = 'at weaning';
%     otherwise
%       mat_label{i} = ['at ', mat_ind{i}];
%   end  
% end

% mat_ind_post_birth = {'b'};  % maturity indices post-birth, including birth
% for i = 1:length(mat_ind)
%   if eval(['E_H', mat_ind{i}, ' > E_Hb'])
%     mat_ind_post_birth = [mat_ind_post_birth; mat_ind{i}];
%   end
% end

% temporary
mat_ind = {'b'; 'p'};
mat_label = {'at birth'; 'at puberty'};

mat_ind = [mat_ind; 'i'];
% mat_ind_post_birth = [mat_ind_post_birth; 'i'];
mat_label{length(mat_ind)} = 'at ultimate size';



label.f  = 'scaled funtional response'; units.f = '-';   stat.f = f;  
label.T  = 'temperature';               units.T = 'k';   stat.T = T;  

% parameter vectors used as input for DEBtool routines:

pars_T   = T_A;
pars_E0  = [V_Hb; g; k_J; k_M; v];        % initial_scaled_reserve
pars_tp  = [g; k; l_T; v_Hb; v_Hp]; % parameters for get_tp
pars_R   = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp];  % reprod_rate
pars_tm  = [g; k; l_T; v_Hb; v_Hp; h_a/ (p_M/ E_G)^2; s_G];     % get_tm_s
pars_pow = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp]; % scaled_power

%%%%%%%%%%%%% Life stages:
TC = tempcorr(T, T_ref, pars_T);   % -, Temperature Correction factor


switch model

  case 'std' % standard model
        
    [U_E0, L_b, info] = initial_scaled_reserve(f, pars_E0); % d cm^2, initial scaled reserve
    if info ~= 1
      fprintf('warning in initial_scaled_reserve: invalid parameter value combination for egg \n')
    end    
    [t_p, t_b, l_p, l_b, info] = get_tp(pars_tp, f); % -, scaled age at puberty
    if info ~= 1              
      fprintf('warning in get_tp: invalid parameter value combination for t_p \n')
    end  
        
  case 'stf'  % standard model with foetal development, no acceleration   
    
    [U_E0, L_b, info] = initial_scaled_reserve_foetus(f, pars_E0); % d cm^2, initial scaled reserve
    if info ~= 1
      fprintf('warning in initial_scaled_reserve_foetus: invalid parameter value combination for foetus \n')
    end
    [t_p, t_b, l_p, l_b, info] = get_tp_foetus(pars_tp, f);
    if info ~= 1
      fprintf('warning in get_tj: invalid parameter value combination \n')
    end
    
%   case 'abj' % model with acceleration from birth
%     
%     [U_E0, L_b, info] = initial_scaled_reserve(f, pars_E0); % d cm^2, initial scaled reserve
%     if info ~= 1
%       fprintf('warning in initial_scaled_reserve_foetus: invalid parameter value combination for egg \n')
%     end
%     pars_tj  = [g; k; l_T; v_Hb; v_Hj; v_Hp]; % parameters for get_tp
%     [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rj, rB, info] = get_tj(pars_tj, f);
%     if info ~= 1
%       fprintf('warning in get_tj: invalid parameter value combination \n')
%     end
      
case 'stx'  % standard model with foetal development, no acceleration   
    
    [U_E0, L_b, info] = initial_scaled_reserve_foetus(f, pars_E0); % d cm^2, initial scaled reserve
    if info ~= 1
      fprintf('warning in initial_scaled_reserve_foetus: invalid parameter value combination for foetus \n')
    end
    [t_p, t_b, l_p, l_b, info] = get_tp_foetus(pars_tp, f);
    if info ~= 1
      fprintf('warning in get_tj: invalid parameter value combination \n')
    end


  otherwise    % no foetal development
    fprintf('warning statistics_std: invalid model key \n')
    return;
end    

s_M = 1;                        % -, acceleration factor
l_i = s_M * (f - l_T);            % scaled ultimate length
rho_B = 1/ 3/ (1 + f/ g);       % scaled von Bert growth rate

E_0    = p_Am * U_E0;           % J, initial reserve (of embryo)
M_E0   = E_0/ mu_E;             % mol, initial reserve (of embryo)
W_0    = M_E0 * w_E;            % g, initial reserve (of embryo)

label.E_0  = 'initial reserve energy';  units.E_0  = 'J';   stat.E_0  = E_0;
label.M_E0 = 'initial reserve mass';    units.M_E0 = 'mol'; stat.M_E0 = M_E0;
label.W_0  = 'initial dry weight';      units.W_0  = 'g';   stat.W_0  = W_0;

% example % length, age, mass
% L_b    = L_m * l_b;             % cm, structural length at birth
% Lw_b = L_b/ del_M;              % cm, physical length at birth
% a_b    = t_b/ k_M;              % d, age at birth at T
% M_Vb   = M_V * L_b^3;           % mol, structural mass at birth
% W_b = L_b^3 * d_V * (1 + f * w); % g, dry weight at birth

for i = 1:length(mat_ind)
  stri = mat_ind{i};
  labeli = mat_label{i};
  eval(['L_',  stri, ' = L_m * l_', stri, ';']);   % cm, structural length
  eval(['Lw_',  stri, ' = L_', stri, '/ del_M;']); % cm, physical length
%   eval(['a_',  stri, ' = t_', stri, '/ k_M;']);  % d, age at birth at T_ref
%   % temperature correction
%   eval(['a_',  stri, ' = a_', stri, '/ TC;']);      % d, age at birth at T
  eval(['M_V',  stri, ' = M_V * L_', stri, '^3;']);                % mol, structural mass
  eval(['W_',  stri, ' = L_', stri, '^3 * d_V * (1 + f * w);']); % g, dry weight
  
  eval(['label.L_',  stri, ' = ''structural length ',  labeli, ''';  units.L_',  stri, ' = ''cm'';  stat.L_',  stri, ' = L_',         stri, ';']);  %cm, structutral length
  eval(['label.Lw_', stri, ' = ''physical length ',    labeli, ''';  units.Lw_', stri, ' = ''cm'';  stat.Lw_', stri, ' = Lw_',        stri, ';']);  %cm, physical length
  eval(['label.M_V', stri, ' = ''structural mass ',    labeli, ''';  units.M_V', stri, ' = ''mol''; stat.M_V', stri, ' = M_V',        stri, ';']);  %cm, structural mass
  eval(['label.E_V', stri, ' = ''structural energy ',  labeli, ''';  units.E_V', stri, ' = ''J'';   stat.E_V', stri, ' = mu_V * M_V', stri, ';']);  %cm, structutral energy
  eval(['label.W_',  stri, ' = ''dry weight ',         labeli, ''';  units.W_',  stri, ' = ''g'';   stat.W_',  stri, ' = W_',         stri, ';']);  %cm, dry weight
end

for i = 1:length(mat_ind)
  if mat_ind{i} ~= 'i'   % there is no a_i
    stri = mat_ind{i};
    labeli = mat_label{i};
    eval(['a_',  stri, ' = t_', stri, '/ k_M;']);    % d, age at birth at T_ref
    % temperature correction
    eval(['a_',  stri, ' = a_', stri, '/ TC;']);      % d, age at birth at T

    eval(['label.a_',  stri, ' = ''age ',  labeli, ''';  units.a_',  stri, ' = ''d'';  stat.a_', stri, ' = a_', stri, ';']);  %d, age
  end
end


r_B    = rho_B * k_M;           % 1/d, von Bert growth rate
a_99   = a_p + log((1 - L_p/ L_i)/(1 - 0.99))/ r_B; 	% d, time to reach length 0.99 * L_i
% temperature correct ages and rates:
r_B  = r_B * TC;
a_99 = a_99/ TC; 

U_Eb   = f * E_m * L_b^3/ p_Am; % d cm^2, scaled reserve at birth
del_Ub = U_Eb/ U_E0;            % -, fraction of reserve left at birth

label.c_T  = 'temp. correction factor'; units.c_T = '-'; stat.c_T = TC;   
% pack output:
label.a_99 = 'age at 99% of ultimate length'; units.a_99 = 'd';   stat.a_99 = a_99; temp.a_99 = T;
label.r_B  = 'von Bertalanffy growth rate';   units.r_B   = '1/d'; stat.r_B  = r_B;  temp.r_B  = T;
label.del_Ub = 'fraction of reserve left at birth';  units.del_Ub = '-';   stat.del_Ub  = del_Ub;

% reproduction
R_i = reprod_rate(L_i, f, pars_R);
 R_i =  R_i * TC;
R_p = reprod_rate(L_p, f, pars_R);
 R_p =  R_p * TC;

label.R_i = 'ultimate reproduction rate';      units.R_i = '1/d';  stat.R_i = R_i; temp.R_i = T;
label.R_p = 'reproduction rate at puberty';    units.R_p = '1/d';  stat.R_p = R_p; temp.R_p = T;
 
 % min and max possible egg sizes as determined by the maternal effect rule (e = f)

[eb_min, lb_min, uE0_min, info_eb_min] = get_eb_min([g; k; v_Hb]); %#ok<*ASGLU> % growth, maturation cease at birth
M_E0_min_b = L_m^3 * E_m * g * uE0_min/ mu_E; % mol, initial reserve (of embryo) at eb_min
% if sum(info_eb_min) ~= 2
%     fprintf('Warning: no convergence for eb_min\n')
% end

ep_min  = get_ep_min([k; l_T; v_Hp]); % growth and maturation cease at puberty   
% if length(ep_min) > 1
%    ep_min = max(ep_min);
% end
M_E0_min_p = L_m^3 * E_m * g * get_ue0([g; k; v_Hb], ep_min)/ mu_E; % mol, initial reserve (of embryo) at ep_min

label.M_E0_min_b = 'egg mass whereby growth ceases at birth';   units.M_E0_min_b = 'mol';  stat.M_E0_min_b = M_E0_min_b;
label.M_E0_min_p = 'egg mass whereby growth ceases at puberty'; units.M_E0_min_p = 'mol';  stat.M_E0_min_p = M_E0_min_p;


% Feeding module 

% food densities for which growth/maturation ceases at a given life-stage
Kb_min = K * eb_min ./ (1 - eb_min);          % growth, maturation cease at birth
Kp_min = K * ep_min ./ (1 - ep_min);          % growth and maturation cease at puberty

label.Kb_min = 'food density where growth, maturation cease at birth';   units.Kb_min = 'mol/l'; stat.Kb_min  = Kb_min;
label.Kp_min = 'food density where growth, maturation cease at puberty'; units.Kp_min = 'mol/l'; stat.Kp_min  = Kp_min;

label.eb_ming = 'scaled func. resp. such that growth ceases at birth';   units.eb_ming = '-'; stat.eb_ming  = eb_min(1);
label.eb_minh = 'scaled func. resp. such that maturation ceases at birth';   units.eb_minh = '-'; stat.eb_minh  = eb_min(2);
label.ep_min = 'scaled func. resp. such that maturation and growth ceases at puberty';   units.ep_min = '-'; stat.ep_min  = ep_min;

%%

% example % food intake and clearance rates :
% p_Xb  = p_Am * f * L_b^2/ kap_X;    % J/d, food intake at birth
% J_XAb = f * J_X_Am * L_b^2;         % mol/d, food intake at birth
% CR_b  = F_m * L_b^2;                % l/d, clearance rate at birth 

for i = 1:length(mat_ind)
  stri = mat_ind{i};
  labeli = mat_label{i};
  eval(['p_X',  stri, ' = p_Am * f * L_', stri, '^2/ kap_X;']); % J/d, food intake
  eval(['J_XA', stri, ' = f * J_X_Am * L_', stri, '^2;']);      % mol/d, food intake
  eval(['CR_',  stri, ' = s_M * F_m * L_', stri, '^2;']);       % l/d, clearance rate
  
  %temperature corrections
  eval(['p_X', stri, ' = p_X', stri, ' * TC;  J_XA', stri, ' = J_XA', stri, ' * TC;  CR_', stri, ' = CR_', stri, ' * TC;']); 
  
  eval(['label.p_X', stri,  ' = ''food intake ',    labeli, ''';  units.p_X',  stri, ' = ''J/d'';   stat.p_X',  stri, ' = p_X',  stri, '; temp.p_X',  stri, ' = T;']); 
  eval(['label.J_XA', stri, ' = ''food intake ',    labeli, ''';  units.J_XA', stri, ' = ''mol/d''; stat.J_XA', stri, ' = J_XA', stri, '; temp.J_XA', stri, ' = T;']); 
  eval(['label.CR_', stri,  ' = ''clearance rate ', labeli, ''';  units.CR_',  stri, ' = ''1/d'';   stat.CR_',  stri, ' = CR_',  stri, '; temp.CR_',  stri, ' = T;']); 
end

%%

del_Wb = W_b/ W_i;     % -, birth weight as fraction of maximum weight
del_Wp = W_p/ W_i;     % -, puberty weight as fraction of maximum weight
xi_W_E = (mu_V + mu_E * m_Em * f)/ (f * w); 
    % kJ/g, whole-body energy density (no reprod buffer), <E + E_V>

del_V    = 1/(1 + f * w); % -, fraction of max weight that is structure
t_E      = L_m/ v;    % d, maximum reserve residence time
t_starve = E_m/ p_M;  % d, max survival time when starved  

% temperature correct output:
t_E = t_E/ TC; t_starve = t_starve/ TC;  

label.del_Wb   = 'birth weight as fraction of maximum weight';   units.del_Wb = '-';      stat.del_Wb  = del_Wb;
label.del_Wp   = 'puberty weight as fraction of maximum weight'; units.del_Wp  = '-';     stat.del_Wp  = del_Wp;
label.xi_W_E   = 'whole-body energy density (no reprod buffer)'; units.xi_W_E  = 'kJ/g';  stat.xi_W_E  = xi_W_E;
label.del_V    = 'fraction of max weight that is structure';     units.del_V = '-';       stat.del_V  = del_V;
label.t_starve = 'maximum survival time when starved';           units.t_starve = 'd';    stat.t_starve  = t_starve;
label.t_E      = 'maximum reserve residence time';               units.t_E  = 'd';        stat.t_E  = t_E;
label.E_m      = 'reserve capacity';                             units.E_m  = 'J/cm^3';   stat.E_m  = E_m;
label.m_Em     = 'reserve capacity';                             units.m_Em = 'mol/cm^3'; stat.m_Em  = m_Em;



%% 

% life span
%[t_m S_b S_p] = get_tm(pars_tm, f, l_b, l_p); a_m = t_m/ kT_M; % d, mean life span
[t_m, S_b, S_p] = get_tm_s(pars_tm, f, L_b/ L_i, L_p/ L_i); 
a_m = t_m/ k_M; % d, mean life span
% if E_Hj > E_Hb: l_i > f - l_T
h_W = (h_a * f * k_M * g/ 6)^(1/3); % 1/d, Weibull ageing rate
h_G = s_G * f * k_M * g;             % 1/d, Gompertz ageing rate

% temperature correct output:
a_m = a_m/ TC;
h_W = h_W * TC; 
h_G = h_G * TC; 

label.S_b = 'survival probability at birth';   units.S_b = '-';     stat.S_b  = S_b;
label.S_p = 'survival probability at puberty'; units.S_p = '-';     stat.S_p  = S_p;
label.h_W = 'Weibull aging rate';              units.h_W = '1/d';   stat.h_W  = h_W;
label.h_G = 'Gompertz aging rate';             units.h_G = '1/d';   stat.h_G  = h_G;

%%
% mass fluxes for L = L_i = s_M (f L_m - L_T)

 mu_Or = [mu_X; mu_V; mu_E; mu_P]; % J/mol, chemical potentials for organics

 mu_M = [mu_C; mu_H; mu_O; mu_N];  % chemical potential of minerals

% eta_O = [...   %%% pag. 141
%     -3/2, 0, 0;
%     0,    0, 1/2;
%     1,   -1, -1;
%     1/2,  0,  0];

p_ref = p_Am * L_m^2;        % max assimilation power at max size

pACSJGRD_b = p_ref * scaled_power(L_b+1e-6, f, pars_pow, l_b, l_p); % powers

for i = 1:length(mat_ind)
  if mat_ind{i} ~= 'b'
    stri = mat_ind{i};
    labeli = mat_label{i};
    eval(['pACSJGRD_', stri, ' = p_ref * scaled_power(L_', stri, ', f, pars_pow, l_b, l_p);']);  % assimilation, dissipation, growth power
  end
end

% example % at birth
% pADG_b = pACSJGRD_b(:,[1 7 5])';  % assimilation, dissipation, growth power
% J_O = eta_O * diag(pADG_b);     % mol/d, J_X, J_V, J_E, J_P in rows, A, D, G in cols
% J_M = - (n_M\n_O) * J_O;      % mol/d, J_C, J_H, J_O, J_N in rows, A, D, G in cols
% RQ_b = -(J_M(1,2) + J_M(1,3))/ (J_M(3,2) + J_M(3,3)); % mol C/ mol O, resp quotient
% UQ_b = -(J_M(4,2) + J_M(4,3))/ (J_M(3,2) + J_M(3,3)); % mol N/ mol O, urin quotient
% WQ_b = -(J_M(2,2) + J_M(2,3))/ (J_M(3,2) + J_M(3,3)); % mol H/ mol O, water quotient
% SDA_b = J_M(3,1)/ J_O(1,1);     % mol O/mol X, specific dynamic action
% VO_b = J_M(3,2)/ W_b/ 24/ X_gas; % L/g.h, dioxygen use per gram max dry weight, <J_OD>
% p_t_b = sum(- J_O' * mu_Or - J_M' * mu_M); % J/d, dissipating heat

X_gas = T_ref/ T/ 24.4;  % M, mol of gas per litre at T_ref (= 20 C) and 1 bar 

for i = 1:length(mat_ind)
  stri = mat_ind{i};
  labeli = mat_label{i};
  eval(['pADG_', stri, ' = pACSJGRD_', stri, '(:,[1 7 5])'';']);  % assimilation, dissipation, growth power
  eval(['J_O = eta_O * diag(pADG_', stri, ');']);                 % mol/d, J_X, J_V, J_E, J_P in rows, A, D, G in cols
  J_M = - (n_M\n_O) * J_O;                                        % mol/d, J_C, J_H, J_O, J_N in rows, A, D, G in cols
  eval(['RQ_', stri, ' = -(J_M(1,2) + J_M(1,3))/ (J_M(3,2) + J_M(3,3));']); % mol C/ mol O, resp quotient
  eval(['UQ_', stri, ' = -(J_M(4,2) + J_M(4,3))/ (J_M(3,2) + J_M(3,3));']); % mol N/ mol O, urin quotient
  eval(['WQ_', stri, ' = -(J_M(2,2) + J_M(2,3))/ (J_M(3,2) + J_M(3,3));']); % mol H/ mol O, water quotient
  eval(['SDA_', stri, ' = J_M(3,1)/ J_O(1,1);']);                 % mol O/mol X, specific dynamic action
  eval(['VO_', stri,  ' = J_M(3,2)/ W_', stri, '/ 24/ X_gas;']);  % L/g.h, dioxygen use per gram max dry weight, <J_OD>
  eval(['p_t_', stri, ' = sum(- J_O'' * mu_Or - J_M'' * mu_M);']); % J/d, dissipating heat

  %temperature corrections
  eval(['VO_', stri, ' = VO_', stri, ' * TC; p_t_', stri, ' = p_t_', stri, ' * TC;']); 
  
  eval(['label.RQ_',  stri, ' = ''respiration quotient ',        labeli, ''';  units.RQ_',  stri, ' = ''mol C/ mol O''; stat.RQ_',  stri, ' = RQ_',  stri, '; temp.RQ_',  stri, ' = T;']);  
  eval(['label.UQ_',  stri, ' = ''urination quotient ',          labeli, ''';  units.UQ_',  stri, ' = ''mol N/ mol O''; stat.UQ_',  stri, ' = UQ_',  stri, '; temp.UQ_',  stri, ' = T;']); 
  eval(['label.WQ_',  stri, ' = ''watering quotient ',           labeli, ''';  units.WQ_',  stri, ' = ''mol H/ mol O''; stat.WQ_',  stri, ' = WQ_',  stri, '; temp.WQ_',  stri, ' = T;']); 
  eval(['label.SDA_', stri, ' = ''specific dynamic action ',     labeli, ''';  units.SDA_', stri, ' = ''mol O/ mol X''; stat.SDA_', stri, ' = SDA_', stri, '; temp.SDA_', stri, ' = T;']); 
  eval(['label.VO_',  stri, ' = ''dioxygen use per dry weight ', labeli, ''';  units.VO_',  stri, ' = ''L/g.h'';        stat.VO_',  stri, ' = VO_',  stri, '; temp.VO_',  stri, ' = T;']); 
  eval(['label.p_t_', stri, ' = ''heat dissipation ',            labeli, ''';  units.p_t_', stri, ' = ''J/d'';          stat.p_t_', stri, ' = p_t_', stri, '; temp.p_t_', stri, ' = T;']); 
end


%%

% indices 
  
s_s = k_J * E_Hp * (p_M + p_T/ L_i)^2/ p_Am^3/ f^3/ s_M^3; % -, supply stress
s_s = log10(s_s);
s_H = log10(E_Hp/E_Hb); % altriciality index, log10 s_H^pb, - 

label.s_M = 'acceleration factor'; units.s_M = '-';   stat.s_M = s_M;
label.s_s = 'log 10 supply stress';       units.s_s = '-';   stat.s_s = s_s;
label.s_H = 'log 10 altriciality index';  units.s_H = '-'; stat.s_H = s_H;

% packing

stat.temp = temp;
txt_stat.units = units;
txt_stat.label = label;


