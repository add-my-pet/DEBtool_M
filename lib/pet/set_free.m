%% set_free
% sets free settings in a pars_init file

%%
function set_free(my_pet, mode)
  % created 2023/80/28 by Bas Kooijman
  %% Syntax
  % <../set_free.m *set_free*> (my_pet, mode)
  
  %% Description
  % Sets free settings in a local pars_init file, using mode-settings
  %
  % Input
  %
  % * my_pet: string with entry-name for loading/writing pars_init_my_pet
  % * mode: scalar with mode setting
  %
  %     - 0 all free settings are 0
  %     - 1 all free settings are 0, except f_*
  %     - 2 all free settings are 0, except core pars
  %     - 3 all free settings are 0, except f_* and core_pars
  %
  % Output
  %
  % * no explicit output, but  pars_init_my_pet is ovderwritten
  
  
  %% Examples
  % set_free('Daphnia_magna',0)

  core_pars = {'z','v','kap','p_M','E_G','E_H','h_a'};
  
  fnm = ['pars_init_', my_pet, '.m'];
  pars_init = fileread(fnm);
  ind = 4+strfind(pars_init, 'free.'); n = length(ind);
  for i=1:n
    ind_free = strfind(pars_init(ind(i):end), ';'); ind_free = ind(i)+ind_free(1)-2; % position of free setting
    ind_par = strfind(pars_init(ind(i):end), ' '); par = pars_init(ind(i)+(1:ind_par(1)-2)); % name of parameter
    pars_init(ind_free) = '0'; % set free.* = 0 for all pars
    switch mode
      case 1
        if contains(par,'f_'); pars_init(ind_free)='1'; end
      case 2
        if any(contains(par, core_pars)); pars_init(ind_free)='1'; end
      case 3
        if any(contains(par, [core_pars, 'f_'])); pars_init(ind_free)='1'; end
      otherwise
    end
  end
  
  % write pars_init
  fid_pars_init = fopen(fnm, 'w+'); fprintf(fid_pars_init, '%s', pars_init); fclose(fid_pars_init);

