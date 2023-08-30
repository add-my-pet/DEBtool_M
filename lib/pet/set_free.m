%% set_free
% sets free settings in a pars_init file

%%
function set_free(my_pet, mode, pars_free)
  % created 2023/80/28 by Bas Kooijman
  %% Syntax
  % <../set_free.m *set_free*> (my_pet, mode)
  
  %% Description
  % Sets free settings in a local pars_init file, using mode-settings. 
  % The parameters listed in pars_free will have free = 1, independent of the mode setting.
  %
  % Input
  %
  % * my_pet: string with entry-name for loading/writing pars_init_my_pet
  % * mode: optional scalar (default 0) with 
  %
  %     - 0 all free settings are 0
  %     - 1 all free settings are 0, except f_*
  %     - 2 all free settings are 0, except pars_core
  %     - 3 all free settings are 0, except f_* and core_pars
  %
  % * pars_free: optional cell-string with parameters to set free, all others will be fixed
  %
  % Output
  %
  % * no explicit output, but  pars_init_my_pet is ovderwritten
  
  
  %% Examples
  % set_free('Daphnia_magna',0) on the assumption that pars_init_Daphia_magna.m is in the current dir

  if ~exist('mode','var'); mode = 0; end
  if ~exist('pars_free','var'); pars_free = {}; end
  
  pars_core = {'z','v','kap','p_M','E_G','E_Hh','E_Hb','E_Hs','E_Hj','E_Hp','E_Hpm','E_He','h_a'};
  
  fnm = ['pars_init_', my_pet, '.m'];
  pars_init = fileread(fnm);
  ind = 4+strfind(pars_init, 'free.'); n = length(ind);
  for i=1:n
    ind_free = strfind(pars_init(ind(i):end), ';'); ind_free = ind(i)+ind_free(1)-2; % position of free setting
    ind_par = strfind(pars_init(ind(i):end), ' '); par = pars_init(ind(i)+(1:ind_par(1)-2)); % name of parameter
    pars_init(ind_free) = '0'; % set free.* = 0 for all pars
    switch mode
      case 0
        if any(strcmp(par,pars_free)); pars_init(ind_free)='1'; end
      case 1
        if any(contains(par,'f_')) || any(strcmp(par,pars_free)); pars_init(ind_free)='1'; end
      case 2
        if any(strcmp(par,[pars_core,pars_free])); pars_init(ind_free)='1'; end
      case 3
        if any(contains(par,'f_')) || any(strcmp(par,[pars_core,pars_free])); pars_init(ind_free)='1'; end
      otherwise
    end
  end
  
  % write pars_init
  fid_pars_init = fopen(fnm, 'w+'); fprintf(fid_pars_init, '%s', pars_init); fclose(fid_pars_init);

