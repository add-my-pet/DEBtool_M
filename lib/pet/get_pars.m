%% get_pars
% Gets some parameters, based on zero-variate data

%%
function [par, metaPar, txtPar, flag] = get_pars(data, auxData, metaData)
  % created 2015/01/15 by Bas Kooijman and Goncalo Marques; modified 2015/03/07
  % modified 2015/07/29
  
  %% Syntax 
  % [par, metaPar, txtPar, flag] = <../get_pars.m *get_pars*> (data, auxData, metaData)

  %% Description
  % Overwrites some parameters set by pars_init
  % Gets these parameters based on zero-variate data, assuming that 
  %
  % * standard units have been used (d, cm, g, J)
  % * zero-variate data in mydata refer to condition f = 1 
  % * weights Wb, Wj, Wp and/or Wm as set in mydata_my_pet are wet weights
  % * chemical pars w_V, w_E, mu_V, mu_E, T_ref exist in structure par in pars_init
  %
  % Possible input data, read from structure data
  %
  %    d_V, ab, aj, ap, am, Lb, Lj, Lp, Lm, Ri,
  %    Wb, Wj, Wp, Wm, Wb, Wwj, Wwp, Wwm, Wdb, Wdj, Wdp, Wdm
  %
  % Possible targets: 
  %
  %    del_M, z, v, kap, p_M, E_G, E_Hb, E_Hj, E_Hp, h_a
  %    the values set in pars_init can be overwritted
  %
  % Input
  %
  % * data: structure with values of data (only zero-variate data are used)
  % * auxData: structure with auxiliary data (includes temperatures) 
  % * metaData: structure with info about data, which is only passed to pars_init
  %  
  % Output
  %
  % * par: structure with values for parameters
  % * txtPar: as set in pars_init (not modified by this function)
  % * flag: identifier for the type of get_pars that has been used
  % 
  %     9: data: d_V, a_b, a_p, a_m, W_b, W_j, W_p, W_m, R_m
  %        par: {p_Am}, v, kap, [p_M], [E_G], E_Hb, E_Hj, E_Hp, h_a
  %     9_foetus: data: d_V, t_b, t_x, t_p, t_m, W_b, W_x, W_m, R_m
  %        par: {p_Am} , v, kap, [p_M], [E_G], E_Hb, E_Hx, E_Hp, h_a
  %     98:data: d_V, a_b, a_p, a_m, W_b, W_p, W_m, R_m
  %        par: {p_Am}, v, kap, [p_M], [E_G], E_Hb, E_Hj, E_Hp, h_a
  %     8: data: d_V, a_b, a_p, a_m, W_b, W_p, W_m, R_m
  %        par: {p_Am}, v, kap, [p_M], [E_G], E_Hb, E_Hp, h_a
  %     7: data: d_V, a_b, a_p, a_m, W_b, W_p, W_m, R_m
  %        par: {p_Am}, v, kap, [p_M], [E_G], E_Hb, E_Hp
  %     6: data: d_V, t_p, W_b, W_p, W_m, R_m
  %        par: {p_Am}, kap, [p_M], [E_G], E_Hb, E_Hp
  %     6a:data: d_V, a_b, W_b, W_p, W_m, R_m
  %        par: {p_Am}, v, kap, [E_G], E_Hb, E_Hp
  %     5: data: d_V, W_b, W_p, W_m, R_m
  %        par: {p_Am}, kap, [E_G], E_Hb, E_Hp
  %     4: data: d_V, W_b, W_p, W_m
  %        par: {p_Am}, [E_G], E_Hb, E_Hp
  %     3: data: d_V, W_b, W_m
  %        par: {p_Am}, [E_G], E_Hb
  %     2: data: d_V, W_m
  %        par: {p_Am}, [E_G]

  
  %% Remarks
  % Called by <estim_pars.html *estim_pars*> if pars_init_method = 0.
  % txt_par is set in <pars_init_my_pet.html *pars_init_my_pet*>.
  % Theory behind the mapping of data on parameters is given in
  % <http://eee.bio.vu.nl/thb/research/bib/LikaAugu2014.html *Lika et al 2014*>.

  %% Example of use
  % See <../mydata_get_pars_2_9.m *mydata_get_pars_2_9*> for application of functions called by this one. 

[par, metaPar, txtPar] = feval(['pars_init_', metaData.species], metaData); % set pars and chem 
% some elements of par will be overwritten below
% T_ref is in chem, T_A in par; these are used for temp corrections

v2struct(par); v2struct(metaPar);         % unpack par, metaPar
cpar = parscomp_st(par); v2struct(cpar);  % unpack cpar

% Correct data for temperature
v2struct(data); v2struct(auxData);   % unpack data and auxData
if exist('ab', 'var')  % age at birth
  TC_ab = tempcorr(T_ref, temp.ab, T_A); % -, temp correction coefficient
  ab = ab/ TC_ab; % d, ab at T_ref
end
if exist('ap', 'var') % age at puberty
  TC_ap = tempcorr(T_ref, temp.ap, T_A); % -, temp correction coefficient
  ap = ap/ TC_ap; % d, ap at T_ref
end
if exist('am', 'var')  % age at death
  TC_am = tempcorr(temp.am, T_ref, T_A); % -, temp correction coefficient
  am = am/ TC_am; % d, am at T_ref
end
if exist('Ri', 'var')  % max reprod rate
  TC_Ri = tempcorr(T_ref, temp.Ri, T_A); % -, temp correction coefficient
  Ri = Ri * TC_Ri; % 1/d, Rm at T_ref
end

% if W-data does not exist, try to get it from Wd, Ww or L-data

if exist('Wwm', 'var')
    Wm = Wwm;
elseif exist('Wwi', 'var')
    Wm = Wwi;
elseif exist('Wdm', 'var')
    Wm = Wdm/ d_V;
elseif exist('Wdi', 'var')
    Wm = Wdi/ d_V;
end

if exist('Wwp', 'var')
    Wp = Wwp;
elseif exist('Wdp', 'var')
    Wp = Wdp/ d_V;
end

if exist('Wwj', 'var')
    Wj = Wwj;
elseif exist('Wdj', 'var')
    Wj = Wdj/ d_V;
end

if exist('Wwb', 'var')
    Wb = Wwb;
elseif exist('Wdb', 'var')
    Wb = Wdb/ d_V;
end

% if Wm does not exist, try to get Wm from L-data
if ~exist('Wm', 'var') && exist('Wp', 'var') && exist('Lp', 'var') && exist('Li', 'var')
  Wm = Wp * (Li/ Lp)^3;
elseif ~exist('Wm', 'var') && exist('Wj', 'var') && exist('Lj', 'var') && exist('Li', 'var')
  Wm = Wj * (Li/ Lj)^3;
elseif ~exist('Wm', 'var') && exist('Wb', 'var') && exist('Lb', 'var') && exist('Li', 'var')
  Wm = Wb * (Li/ Lb)^3;
end

% if Wp does not exist, try to get Wp from L-data
if ~exist('Wp', 'var') && exist('Wm', 'var') && exist('Li', 'var') && exist('Lp', 'var')
  Wp = Wm * (Lp/ Li)^3;
elseif ~exist('Wp', 'var') && exist('Wj', 'var') && exist('Lj', 'var') && exist('Lp', 'var')
  Wp = Wj * (Lp/ Lj)^3;
elseif ~exist('Wp', 'var') && exist('Wb', 'var') && exist('Lb', 'var') && exist('Lp', 'var')
  Wp = Wb * (Lp/ Lb)^3;
end

% if Wx does not exist, try to get Wx from L-data
if ~exist('Wx', 'var') && exist('Wm', 'var') && exist('Li', 'var') && exist('Lx', 'var')
  Wx = Wm * (Lx/ Li)^3;
elseif ~exist('Wx', 'var') && exist('Wp', 'var') && exist('Lp', 'var') && exist('Lx', 'var')
  Wx = Wp * (Lx/ Lp)^3;
elseif ~exist('Wx', 'var') && exist('Wb', 'var') && exist('Lb', 'var') && exist('Lx', 'var')
  Wj = Wm * (Lx/ Lb)^3;
end

% if Wj does not exist, try to get Wj from L-data
if ~exist('Wj', 'var') && exist('Wm', 'var') && exist('Li', 'var') && exist('Lj', 'var')
  Wj = Wm * (Lj/ Li)^3;
elseif ~exist('Wj', 'var') && exist('Wp', 'var') && exist('Lp', 'var') && exist('Lj', 'var')
  Wj = Wp * (Lj/ Lp)^3;
elseif ~exist('Wj', 'var') && exist('Wb', 'var') && exist('Lb', 'var') && exist('Lj', 'var')
  Wj = Wm * (Lj/ Lb)^3;
end

% if Wb does not exist, try to get Wb from L-data
if ~exist('Wb', 'var') && exist('Wj', 'var') && exist('Lj', 'var') && exist('Lb', 'var')
  Wb = Wj * (Lb/ Lj)^3;
elseif ~exist('Wb', 'var') && exist('Wp', 'var') && exist('Lp', 'var') && exist('Lb', 'var')
  Wb = Wp * (Lb/ Lp)^3;
elseif ~exist('Wb', 'var') && exist('Wm', 'var') && exist('Li', 'var') && exist('Lb', 'var')
  Wb = Wm * (Lb/ Li)^3;
end

% run appropriate get_pars_i, depending on availability of zero-variate data
  free = par.free; % reduce typing

  % for a single food level (= abundant food), 9 parameters can be estimated at maximum
  chem_par = [w_V; w_E; mu_V; mu_E];                   % pack chem parameters
  if exist('d_V', 'var') && exist('ab', 'var') && exist('ap', 'var') && ... 
     exist('am', 'var')  && exist('Wb', 'var') && exist('Wj', 'var') && ...
     exist('Wp', 'var')  && exist('Wm', 'var') && exist('Ri', 'var') && strncmp(model,'abj',3)

    if free.z   && free.v    && free.kap  && free.p_M && ...
       free.E_G && free.E_Hb && free.E_Hj && free.E_Hp && free.h_a
  
      fixed_par_9 = [k_J; s_G; kap_R; kap_G];            % pack fixed par 
      data_9 = [d_V; ab; ap; am; Wb; Wj; Wp; Wm; Ri];    % pack data 
      pars_9 = get_pars_9(data_9, fixed_par_9, chem_par);% get parameters
      p_Am = pars_9(1); v    = pars_9(2); kap  = pars_9(3);
      p_M  = pars_9(4); E_G  = pars_9(5); E_Hb = pars_9(6);
      E_Hj = pars_9(7); E_Hp = pars_9(8); h_a  = pars_9(9); % unpack
      z = kap * p_Am/ p_M;                               % -, zoom factor
      flag = '9';                                        % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_9 are free\n');
    end
  
  % Wj is not available, but large ab indicates acceleration
  elseif exist('d_V', 'var') && exist('ab', 'var') && exist('ap', 'var') && ... 
         exist('am', 'var')  && exist('Wb', 'var') && exist('E_Hj', 'var') && ...
         exist('Wp', 'var')  && exist('Wm', 'var') && exist('Ri', 'var') && strncmp(model,'abj',3)

    if free.z   && free.v    && free.kap  && free.p_M && ...
       free.E_G && free.E_Hb && free.E_Hj && free.E_Hp && free.h_a
  
      fixed_par_9 = [k_J; s_G; kap_R; kap_G];               % pack fixed par 
      data_8 = [d_V; ab; ap; am; Wb; Wp; Wm; Ri];           % pack data 
      pars_9 = get_pars_98(data_8, fixed_par_9, chem_par);  % get parameters
      p_Am = pars_9(1); v    = pars_9(2); kap  = pars_9(3);
      p_M  = pars_9(4); E_G  = pars_9(5); E_Hb = pars_9(6);
      E_Hj = pars_9(7); E_Hp = pars_9(8); h_a  = pars_9(9); % unpack
      z = kap * p_Am/ p_M;                               % -, zoom factor
      flag = '98';                                        % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_98 are free\n');
    end

  % all further get_pars assume absence of acceleration
  elseif exist('d_V', 'var')&& exist('a_0', 'var')&& exist('tb', 'var') && exist('tx', 'var') && ...
         exist('tp', 'var') && exist('am', 'var') && exist('Wb', 'var') && ...
         exist('Wx', 'var') && exist('Wp', 'var') && exist('Wm', 'var') && exist('Ri', 'var')

    if free.z    && free.v    && free.kap  && free.p_M  && ...
       free.E_G  && free.E_Hb && free.E_Hx && free.E_Hp && free.h_a

      fixed_par_9 = [k_J; s_G; kap_R; kap_G];             % pack fixed par 
      data_9 = [d_V; tb; tx; tp; am; Wb; Wx; Wm; Ri];     % pack data 
      pars_9 = get_pars_9_foetus(data_9, a_0, fixed_par_9, chem_par); % get parameters
      p_Am = pars_9(1); v    = pars_9(2); kap  = pars_9(3);
      p_M  = pars_9(4); E_G  = pars_9(5); E_Hb = pars_9(6); E_Hx = pars_9(7);
      E_Hj = E_Hb;      E_Hp = pars_9(8); h_a  = pars_9(9);% unpack
      z = kap * p_Am/ p_M;                                 % -, zoom factor
      flag = '9_foetus';                                   % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_9_foetus are free\n');
    end

  elseif exist('d_V', 'var')&& exist('ab', 'var') && exist('ap', 'var') && ... 
         exist('am', 'var') && exist('Wb', 'var') && exist('Wp', 'var') && ...
         exist('Wm', 'var') && exist('Ri', 'var')

    if free.z    && free.v    && free.kap  && free.p_M && ...
       free.E_G  && free.E_Hb && free.E_Hp && free.h_a

      fixed_par_8 = [k_J; s_G; kap_R; kap_G];             % pack fixed par 
      data_8 = [d_V; ab; ap; am; Wb; Wp; Wm; Ri];         % pack data 
      pars_8 = get_pars_8(data_8, fixed_par_8, chem_par); % get parameters
      p_Am = pars_8(1); v    = pars_8(2); kap  = pars_8(3);
      p_M  = pars_8(4); E_G  = pars_8(5); E_Hb = pars_8(6);
      E_Hj = E_Hb;      E_Hp = pars_8(7); h_a  = pars_8(8);% unpack
      z = kap * p_Am/ p_M;                                % -, zoom factor
      flag = '8';                                         % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_8 are free\n');
    end

  % all further get_pars assume absence of life-span data
  elseif exist('d_V', 'var') && exist('ab', 'var') && exist('ap', 'var') && ... 
         exist('Wb', 'var')  && exist('Wp', 'var') && exist('Wm', 'var') && ...
         exist('Ri', 'var') 

    if free.z    && free.v    && free.kap && free.p_M && ...
       free.E_G  && free.E_Hb && free.E_Hp 
 
      fixed_par_7 = [k_J; kap_R; kap_G];                  % pack fixed par 
      data_7 = [d_V; ab; ap; Wb; Wp; Wm; Ri];             % pack data 
      pars_7 = get_pars_7(data_7, fixed_par_7, chem_par); % get parameters
      p_Am = pars_7(1); v    = pars_7(2); kap  = pars_7(3);
      p_M  = pars_7(4); E_G  = pars_7(5); E_Hb = pars_7(6);
      E_Hj = E_Hb;      E_Hp = pars_7(7);                 % unpack
      z = kap * p_Am/ p_M;                                % -, zoom factor
      flag = '7';                                         % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_7 are free\n');
    end

   elseif exist('d_V', 'var') && exist('tp', 'var') && exist('Wb', 'var') && ...
          exist('Wp', 'var')  && exist('Wm', 'var') && exist('Ri', 'var')
          % tp = ap - ab; d, time since birth at puberty

    if free.z && free.kap && free.p_M && free.E_G && free.E_Hb && free.E_Hp 
  
      fixed_par_6 = [v; k_J; kap_R; kap_G];               % pack fixed par 
      data_6 = [d_V; tp; Wb; Wp; Wm; Ri];                 % pack data 
      pars_6 = get_pars_6(data_6, fixed_par_6, chem_par); % get parameters
      p_Am = pars_6(1); kap  = pars_6(2); p_M  = pars_6(3); 
      E_G  = pars_6(4); E_Hb = pars_6(5); E_Hp = pars_6(6); % unpack
      z = kap * p_Am/ p_M;                                % -, zoom factor
      E_Hj = E_Hb;                                        % J, E_H^j, maturity at metamorphosis
      flag = '6';                                         % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_6 are free\n');
    end

   elseif exist('d_V', 'var') && exist('ab', 'var') && exist('Wb', 'var') && ...
          exist('Wp', 'var')  && exist('Wm', 'var') && exist('Ri', 'var')

    if free.z && free.v && free.kap && free.E_G && free.E_Hb && free.E_Hp 
  
      fixed_par_6a = [p_M; k_J; kap_R; kap_G];            % pack fixed par 
      data_6a = [d_V; ab; Wb; Wp; Wm; Ri];                % pack data 
      pars_6a = get_pars_6a(data_6a, fixed_par_6a, chem_par); % get parameters
      p_Am = pars_6a(1); v    = pars_6a(2); kap  = pars_6a(3);  
      E_G  = pars_6a(4); E_Hb = pars_6a(5); E_Hp = pars_6a(6); % unpack
      z = kap * p_Am/ p_M;                                % -, zoom factor
      E_Hj = E_Hb;                                        % J, E_H^j, maturity at metamorphosis
      flag = '6a';                                        % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_6a are free\n');
    end

  % all further get_pars assume absence of time-data    
  elseif exist('d_V', 'var') && exist('Wb', 'var') && exist('Wp', 'var') && ... 
         exist('Wm', 'var')  && exist('Ri', 'var')

    if free.z && free.kap && free.E_G && free.E_Hb && free.E_Hp 
  
      fixed_par_5 = [v; p_M; k_J; kap_R; kap_G];          % pack fixed par 
      data_5 = [d_V; Wb; Wp; Wm; Ri];                     % pack data 
      pars_5 = get_pars_5(data_5, fixed_par_5, chem_par); % get parameters
      p_Am = pars_5(1); kap  = pars_5(2); E_G = pars_5(3); 
      E_Hb = pars_5(4); E_Hp = pars_5(5);                 % unpack
      z = kap * p_Am/ p_M;                                % -, zoom factor
      E_Hj = E_Hb;                                        % J, E_H^j, maturity at metamorphosis
      flag = '5';                                         % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_5 are free\n');
    end

  % all further get_pars assume absence of reprod-data    
  elseif exist('d_V', 'var') && exist('Wb', 'var') && exist('Wp', 'var') && ...
         exist('Wm', 'var')
      
    if free.z && free.E_G  && free.E_Hb && free.E_Hp 
  
      fixed_par_4 = [v; kap; p_M; k_J; kap_G];            % pack fixed par 
      data_4 = [d_V; Wb; Wp; Wm];                         % pack data 
      pars_4 = get_pars_4(data_4, fixed_par_4, chem_par); % get parameters
      p_Am = pars_4(1); E_G = pars_4(2); E_Hb = pars_4(3); E_Hp = pars_4(4); % unpack
      z = kap * p_Am/ p_M;                                % -, zoom factor
      E_Hj = E_Hb;                                        % J, E_H^j, maturity at metamorphosis
      flag = '4';                                         % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_4 are free\n');
    end

  elseif exist('d_V', 'var') && exist('Wb', 'var') && exist('Wm', 'var')
      
    if free.z && free.E_G  && free.E_Hb
  
      fixed_par_3 = [v; kap; p_M; k_J; kap_G];            % pack fixed par 
      data_3 = [d_V; Wb; Wm];                             % pack data 
      pars_3 = get_pars_3(data_3, fixed_par_3, chem_par); % get parameters
      p_Am = pars_3(1); E_G = pars_3(2); E_Hb = pars_3(3);% unpack
      z = kap * p_Am/ p_M;                                % -, zoom factor
      E_Hj = E_Hb;                                        % J, E_H^j, maturity at metamorphosis
      E_Hp = 50 * z^3;                                    % J, E_H^p, maturity at puberty
      flag = '3';                                         % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_3 are free\n');
    end

  % only max weight and d_V are available
  elseif exist('d_V', 'var') && exist('Wm', 'var') % only W_m exists  
          
    if free.z && free.E_G
  
      fixed_par_2 = [v; kap; p_M; kap_G];                 % pack fixed par 
      data_2 = [d_V; Wm];                                 % pack data 
      pars_2 = get_pars_2(data_2, fixed_par_2, chem_par); % get parameters  
      p_Am = pars_2(1); E_G = pars_2(2);                  % unpack
      z = kap * p_Am/ p_M;                                % -, zoom factor
      E_Hb = .275 * z^3;                                  % J, E_H^b, maturity at birth 
      E_Hj = E_Hb;                                        % J, E_H^j, maturity at metamorphosis
      E_Hp = 50 * z^3;                                    % J, E_H^p, maturity at puberty
      flag = '2';                                         % set flag
    else
      fprintf('warning from get_pars: not all parameters in get_pars_2 are free\n');
    end
   
  else % no parameter to improve
    fprintf('Warning from get_pars: initial par estimates do not depend on data \n')
    flag = '0';                                  % set flag
  end  
  
% store parameters in structure
par.z = z;       par.v = v;       par.kap = kap;
par.p_M = p_M;   par.E_G = E_G;   
par.E_Hb = E_Hb; par.E_Hp = E_Hp; par.h_a = h_a;

if isfield(par, 'E_Hj') && par.free.E_Hj % only set in case of acceleration
  par.E_Hj = E_Hj;
end
if isfield(par, 'E_Hx') && par.free.E_Hx % only set in case of weaning
  par.E_Hj = E_Hx;
end
    
% get del_M (relates structural to physical length)
cpar = parscomp_st(par); % compute compound parameters
v2struct(cpar);

if isfield(par, 'del_M') && free.del_M
  if isfield(par, 'E_Hj') % in case of acceleration
    pars_tj = [g; k; l_T; v_Hb; v_Hj; v_Hp]; % compose parameter vector for get_tj
    [t_j, t_p, t_b, l_j, l_p, l_b, l_i] = get_tj(pars_tj, 1);
    if exist ('Lj', 'var') 
      del_M = l_j * L_m/ Lj; % -, structural/ measured length at metam
    elseif exist ('Li', 'var') 
      del_M = l_i * L_m/ Li; % -, ultimate structural/ measured length 
    elseif exist ('Lp', 'var')
      del_M = l_p * L_m/ Lp; % -, structural/ measured length at puberty
    elseif exist ('Lb', 'var')
      del_M = l_b * L_m/ Lb; % -, structural/ measured length at birth
    end
  else
    pars_tp = [g; k; l_T; v_Hb; v_Hp];                % compose parameter vector
    [t_p, t_b, l_p, l_b] = get_tp(pars_tp, 1); % -, scaled length at birth at f
    if exist ('Li', 'var')
      del_M = L_m/ Li; % -, ultimate structural/ measured length 
    elseif exist ('Lp', 'var')
      del_M = l_p * L_m/ Lp; % -, structural/ measured length at puberty
    elseif exist ('Lb', 'var')
      del_M = l_b * L_m/ Lb; % -, structural/ measured length at birth
    end
  end
  par.del_M = del_M; % store del_M in structure
end

