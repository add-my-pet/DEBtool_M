%% Reads Species.xls and assigns parameters and variables
% see report_init for column number of variables
 
  % file = 'Species.xls'; file + path is set in sh-scripts
  
%% species_list

  % read TYPE, FIT, COMPLETE
  sheet = 1; % species_list; xlsread in new versions of Matlab cannot read names of sheets
  COMPLETE = xlsread(file, sheet, 'M2:M1000'); % read COMPLETE marks
  % TYPE: 0 = weird; 1 = standard DEB; 2 = foetus; 3 = acceleration; 4 = foetus + acceleration
  TYPE = xlsread(file, sheet, 'K2:K1000'); % read types
  FIT = xlsread(file, sheet, 'L2:L1000');  % read FIT marks
  n_species = size(COMPLETE,1); 
  
  % read taxa 
  txt_n = num2str(1+n_species); % xlsread in new versions of Matlab reads txt-columns till space-rows minus one
  [x phylum]  = xlsread(file, sheet, ['A2:A', txt_n]); % read phylum name
  [x class]   = xlsread(file, sheet, ['B2:B', txt_n]); % read class name
  [x order]   = xlsread(file, sheet, ['C2:C', txt_n]); % read order name
  [x family]  = xlsread(file, sheet, ['D2:D', txt_n]); % read family name
  [x species] = xlsread(file, sheet, ['E2:E', txt_n]); % read species name
    
  % identify taxa
  n0 = zeros(n_species,1); % number of species
  % initiate taxa
  superphylum = phylum; genus = species; spec = species;
  radiata = n0; bilateria = n0; platyzoa = n0; lophotrochozoa = n0; ecdysozoa = n0; 
  deuterostomata = n0; vertebrata = n0; endotherms = n0; fish = n0; Aves = n0; Mammalia = n0;
  % assign taxa spec, genus & superphylum as cells and some high taxa as boleans
  for i = 1:n_species
      radiata(i) =  ...
             strcmp(phylum{i}, 'Ctenophora')| ...
             strcmp(phylum{i}, 'Cnidaria');
      bilateria(i) =  ...
             strcmp(phylum{i}, 'Chaetognatha');
      platyzoa(i) =  ...
             strcmp(phylum{i}, 'Platyhelminthes')| ...
             strcmp(phylum{i}, 'Acanthocephala')| ...
             strcmp(phylum{i}, 'Rotifera')| ...
             strcmp(phylum{i}, 'Gastrotricha'); 
      lophotrochozoa(i) = ...
             strcmp(phylum{i}, 'Annelida')| ...
             strcmp(phylum{i}, 'Mollusca')| ...
             strcmp(phylum{i}, 'Bryozoa'); 
      ecdysozoa(i) = ...  
             strcmp(phylum{i}, 'Nematoda')| ...
             strcmp(phylum{i}, 'Tardigrada')| ...
             strcmp(phylum{i}, 'Arthropoda'); 
      deuterostomata(i) = ... 
             strcmp(phylum{i}, 'Echinodermata')| ...
             strcmp(phylum{i}, 'Chordata');
      vertebrata(i) = ...
             strcmp(class{i}, 'Myxini')| ....
             strcmp(class{i}, 'Cephalaspidomorphi')| ....
             strcmp(class{i}, 'Chondrichthyes')| ....
             strcmp(class{i}, 'Actinopterygii')| ....
             strcmp(class{i}, 'Sarcopterygii')| ....
             strcmp(class{i}, 'Amphibia')| ....
             strcmp(class{i}, 'Reptilia')| ....
             strcmp(class{i}, 'Aves')| ....
             strcmp(class{i}, 'Mammalia');
      fish(i) = ...
             strcmp(class{i}, 'Myxini')| ....
             strcmp(class{i}, 'Cephalaspidomorphi')| ....
             strcmp(class{i}, 'Chondrichthyes')| ....
             strcmp(class{i}, 'Actinopterygii')| ....
             strcmp(class{i}, 'Sarcopterygii');
      Chondrichthyes(i) = strcmp(class{i}, 'Chondrichthyes');
      Amphibia(i) = strcmp(class{i}, 'Amphibia');
      Reptilia(i) = strcmp(class{i}, 'Reptilia');
      endotherms(i) = ...;
             strcmp(class{i}, 'Aves')| ....
             strcmp(class{i}, 'Mammalia');
      Aves(i) = strcmp(class{i}, 'Aves');
      Mammalia(i) = strcmp(class{i}, 'Mammalia');
      if radiata(i) == 1
          superphylum{i} = 'radiata';
      elseif bilateria(i) == 1
          superphylum{i} = 'bilateria';
      elseif platyzoa(i) == 1
          superphylum{i} = 'platyzoa';
      elseif lophotrochozoa(i) == 1
          superphylum{i} = 'lophotrochozoa';
      elseif ecdysozoa(i) == 1
          superphylum{i} = 'ecdysozoa';
      elseif deuterostomata(i) == 1
          superphylum{i} = 'deuterostomata';
      end
      if strcmp(class{i}, 'Insecta')
          TYPE(i) = 0;
      end
      txt = species{i}; s = [findstr('_', txt), 1 + size(txt,2)];
      genus{i} = txt(1: s(1) - 1); spec{i} = txt(s(1) + 1 : s(2) - 1);
  end

  n_radi = sum(radiata); n_bila = sum(bilateria); n_plat = sum(platyzoa);
  n_loph = sum(lophotrochozoa); n_ecdy = sum(ecdysozoa); n_deut = sum(deuterostomata); n_vert = sum(vertebrata); n_endo = sum(endotherms);
  n_fish = sum(fish); n_Chon = sum(Chondrichthyes); n_Amph = sum(Amphibia); n_Rept = sum(Reptilia); n_Aves = sum(Aves); n_Mamm = sum(Mammalia);
  
  % set colours for taxa
  color = zeros(n_species,3);           % RGB colours, black by default
  col_radi = [0 0 1]; color(radiata == 1,:) = ones(n_radi,1) * col_radi; % blue 
  col_bila = [.8 .8 0]; color(bilateria == 1,:) = ones(n_bila,1) * col_bila;% dark blue 
  col_plat = [0 1 1]; color(platyzoa == 1, :) = ones(n_plat,1) * col_plat; % turquoise
  col_loph = [0 .8 .8]; color(lophotrochozoa == 1, :) = ones(n_loph,1) * col_loph;% dark turquoise
  col_ecdy = [0 1 0]; color(ecdysozoa == 1,:) = ones(n_ecdy,1) * col_ecdy; % green
  col_deut = [0 0 0]; % invertebrate deuterostomata, black
  col_vert = [1 0 1]; color(vertebrata == 1,:) = ones(n_vert,1) * col_vert; % magenta
  col_endo = [1 0 0]; color(endotherms == 1,:) = ones(n_endo,1) * col_endo; % red
  marker(1:n_species,1) = '*';
  taxa = {'radi'; 'bila'; 'plat'; 'loph'; 'ecdy'; 'deut'; 'vert'; 'endo'};
  col_taxa = [col_radi; col_bila; col_plat; col_loph; col_ecdy; col_deut; col_vert; col_endo];
  %
  col_fish = [0 0 1]; color(fish == 1,:) = ones(n_fish,1) * col_fish; % blue
  col_Chon = [.6 .6 1]; color(Chondrichthyes == 1,:) = ones(n_Chon,1) * col_Chon; % light blue
  col_Amph = [.6 1 .6]; color(Amphibia == 1,:) = ones(n_Amph,1) * col_Amph; % light green
  col_Rept = [0 1 0]; color(Reptilia == 1,:) = ones(n_Rept,1) * col_Rept; % green
  col_Aves = [1 .6 .6]; color(Aves == 1,:) = ones(n_Aves,1) * col_Aves; % light red
  col_Mamm = [1 0 0]; color(Mammalia == 1,:) = ones(n_Mamm,1) * col_Mamm; % red
  taxa_vert = {'fish'; 'Chon'; 'Amph'; 'Rept'; 'Aves'; 'Mamm'};
  col_vert = [col_fish; col_Chon; col_Amph; col_Rept; col_Aves; col_Mamm];
  % define selections for plotting
  sel_1 = (TYPE == 1 | TYPE == 2) & ~vertebrata;
  sel_2 = (TYPE == 1 | TYPE == 2) & vertebrata;
  sel_3 = (TYPE == 1 | TYPE == 2) & endotherms;
  sel_4 = (TYPE == 3 | TYPE == 4) & ~vertebrata;
  sel_5 = (TYPE == 3 | TYPE == 4) & vertebrata;
  sel_6 = (TYPE == 3 | TYPE == 4) & endotherms;
  col_sel_1 = [0 0 1]; col_sel_2 = [1 0 1]; col_sel_3 = [1 0 0];
  col_sel_4 = [0 0 1]; col_sel_5 = [1 0 1]; col_sel_6 = [1 0 0];
  taxa_loc = {'inve'; 'vert'; 'endo'}; 
  col_loc = [col_sel_1; col_sel_2; col_sel_3];

  % date; depends on Windows-setting in xls. Here: dd-mm-yyyy
  [x txt_date] = xlsread(file, sheet, ['H2:H', txt_n]);
  date_amp = zeros(n_species,1);
  for i = 1:n_species
    date_amp(i) = datenum(txt_date{i},'dd-mm-yyyy') - datenum([2009 02 12]);
  end
  
%% primary_parameters at T_ref

  sheet = 2; % primary_parameters: xlsread in new versions of Matlab cannot read names of sheets
  pars = xlsread(file, sheet , 'B2:AS1000'); % read parameters                             
  
  % unpack pars, z, pAm, v refer to neonate settings (in case of acceleration)
  TA   = pars(:,2);  % K, Arrhenius temp
  z    = pars(:,8);
  pAm  = pars(:,13); % pAm_j = pAm .* sM;
  v    = pars(:,14); % vj = v .* sM; % cm/d, energy conductance after metamorphosis
  kap  = pars(:,15);
  kapR = pars(:,16);
  pM   = pars(:,17);
  pT   = pars(:,18);
  kJ   = pars(:,19);
  EG   = pars(:,20);
  EHb  = pars(:,21);
  EHj  = pars(:,22);
  EHp  = pars(:,23);
  ha   = pars(:,24);
  sG   = pars(:,25);
  mu_E = pars(:,28);
  dV   = pars(:,31); 
  wV   = 12 + pars(:,37:39) * [1; 16; 14];
  wE   = 12 + pars(:,40:42) * [1; 16; 14];

  % compound parameters
  kM = pM ./ EG;                           % 1/d, somatic maintenance rate coefficient
  k = kJ ./ kM;                            % -, maintenance ratio
  Em = pAm ./ v;                           % J/cm^3, max reserve capacity
  g = EG ./ kap ./ Em;                     % -, energy investment ratio
  LT = pT ./ pM;                           % cm, heating length
  Lm = kap .* pAm ./ pM;                   % cm, max structural length: refers to neonate
  lT = LT ./ Lm;                           % -, scaled heating length
  U_Hb = EHb ./ pAm;                       % cm^2 d, scaled maturity at birth
  V_Hb = U_Hb ./ (1 - kap);                % cm^2 d, scaled maturity at birth
  v_Hb = V_Hb .* g.^2 .* kM.^3 ./ v.^2;    % -, scaled maturity at birth
  U_Hj = EHj ./ pAm;                       % cm^2 d, scaled maturity at metamorphosis 
  V_Hj = U_Hj ./ (1 - kap);                % cm^2 d, scaled maturity at metamorposis
  v_Hj = V_Hj .* g.^2 .* kM.^3 ./ v.^2;    % -, scaled maturity at metamorphosis
  U_Hp = EHp ./ pAm;                       % cm^2 d, scaled maturity at puberty 
  V_Hp = U_Hp ./ (1 - kap);                % cm^2 d, scaled maturity at puberty
  v_Hp = V_Hp .* g.^2 .* kM.^3 ./ v.^2;    % -, scaled maturity at puberty

%% statistics at T and f

  sheet = 3; % statistics: xlsread in new versions of Matlab cannot read names of sheets
  vars = xlsread(file, sheet, 'A2:DR1000'); % read statistics
  
  % z relates to before acceleration (birth), zj to after acceleration (metamorphosis)
  TC = vars(:,3);  % -, temp correction factor
  E0 = vars(:,8);  % J, initial (egg) reserve mass
  Lb = vars(:,11); % cm, structural length at birth
  Lj = vars(:,16); % cm, structural length at metamorphosis
  Lp = vars(:,21); % cm, structural length at puberty
  Li = vars(:,27); % cm, ultimate structural length (after metam)
  Li(TYPE==0) = Lj(TYPE==0); % set ultimate length to length at metam for insects

  s_M = vars(:,96);  % -, acceleration
  vj = v .* s_M;    % cm/d, energy conductance after metamorphosis
  pAmj = pAm .* s_M;% J/d.cm^2, max spec assim rate after metamorphosis
  
  l_b = Lb ./ Li;  % -, scaled length at birth
  l_p = Lp ./ Li;  % -, determinateness
  zj = z .* s_M;   % -, zoom factor for late juveniles and adults
  zj3 = zj .* zj .* zj; % -, cubed zj

  M_E0_min = vars(:,4); 
  M_E0_max = vars(:,7); 
  twin = M_E0_max ./ M_E0_min;
  s_E = log10(twin);     % -, yolkiness
  Wwb = vars(:,14) ./ dV;% g, wet weight at birth
  Wdm = vars(:,30);      % g, max dry weight
  Wwm = Wdm ./ dV;       % g, max wet weight
  
  fmin = vars(:,44);     % -, f at which growth and mat ceases at p 
  VO = vars(:,88) .* Wdm ./ TC; % L/h, respiration at 20 C
  kapG = vars(:,91);     % -, growth efficiency                     
  rB = vars(:,93) ./ TC; % 1/d, von Bertalanffy growth rate
  Ri = vars(:,94) ./ TC; % #/d, reprod rate at 20 C
  pRm = Ri .* E0 ./ kapR; % J/d, investment into reprod
  pJ = kJ .* EHp;        % J/d, investment into mat maintenance
  pC = (pRm + pJ) ./ (1 - kap); % J/d, mobilisation rate
  s_H = vars(:,97);      % -, altriciality index
  s_s = vars(:,98);      % -, supply stress 
  ab = vars(:,99) .* TC; % d, age at birth at 20 C
  ap = vars(:,101) .* TC; % d, age at puberty at 20 C
  am = vars(:,103) .* TC; % d, age at death at 20 C
  rm = max(1e-10, vars(:,113)) ./ TC; % 1/d, population growth rate at 20 C
