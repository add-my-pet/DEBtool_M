%% AmPgui
% a GUI to create 4 structures

%%
function info = AmPgui(action)
% created 2020/06/05 by  Bas Kooijman

%% Syntax
% [data, auxData, metaData, txtData] = <../AmPgui.m *AmPgui*>

%% Description
% Like mydata_my_pet.m, it writes 4 data-structures from scratch
%
% * data: structure with data
% * auxData: structure with auxilirary data 
% * metaData: structure with metaData 
% * txtData: structure with text for data 
%
% Input: will be entered during the GUI session
%
% Output:
% 
% info: boolean with exit info

%% Remarks
%
% * set metaData on global before use of this function.
% * Files will be saved in your local directory, which should not contain results_my_pet.mat files, other than written my this function 
% * Use the cd command to the dir of your choice BEFORE running this function to save files in the desired place.
% * All weights are set at default values in the resulting file; 
% * This function is called in run_AmPeps

global data auxData metaData txtData color select_id id_links eco_types
global hs he hT ha hc hg hd hf hk hb dS dmd dD dF dP d0
global Hauthor Hemail Haddress Hspecies Hacknowledgment HD HDb HF HFb HT HL H0e H0n H0v H0u H0T H0l H0b H0c
global Hclimate Hecozone Hhabitat Hembryo Hmigrate Hfood Hgender Hreprod

%% initiation

%UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize'); % 8
set(0, 'DefaultUIControlFontSize', 9);
%set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);

if ~isfield('data', 'data_0') 
  data.data_0 = [];
end   
if ~isfield('auxData', 'temp') 
  auxData.temp = [];
end
if ~isfield('txtData', 'units')
  txtData.units = []; txtData.label = [];
end

if ~isfield(metaData, 'ecoCode')
  metaData.ecoCode = [];
end
if ~isfield(metaData.ecoCode, 'climate')
  metaData.ecoCode.climate = [];
end
if ~isfield(metaData.ecoCode, 'ecozone')
   metaData.ecoCode.ecozone = [];
end
if ~isfield(metaData.ecoCode, 'habitat')
   metaData.ecoCode.habitat = [];
end
if ~isfield(metaData.ecoCode, 'embryo')
  metaData.ecoCode.embryo = [];
end
if ~isfield(metaData.ecoCode, 'migrate')
  metaData.ecoCode.migrate = [];
end
if ~isfield(metaData.ecoCode, 'food')
  metaData.ecoCode.food = [];
end
if ~isfield(metaData.ecoCode, 'gender')
  metaData.ecoCode.gender = [];
end
if ~isfield(metaData.ecoCode, 'reprod')
  metaData.ecoCode.reprod = [];
end
if ~isfield(metaData, 'bibkey')
  metaData.bibkey = [];
end
if ~isfield('metaData', 'comment') 
  metaData.comment = [];
end

if isempty(color)
  color.hs = [1 0 0]; color.he = [1 0 0]; color.hT = [1 0 0]; color.ha = [1 0 0]; color.hc = [1 0 0];
  color.hg = [0 0 0]; color.hd = [0 0 0]; color.hf = [0 0 0]; color.hk = [0 0 0]; color.hl = [1 0 0];
  color.hb = [1 0 0]; color.h0 = [1 0 0]; color.h1 = [0 0 0]; color.hr = [0 0 0]; color.hp = [0 0 0];
end

if isempty(eco_types)
  get_eco_types;
end

info = 1; % exit info

if nargin == 0 % create the GUI
%% setup gui
  dmd = dialog('Position',[150 100 120 460], 'Name','AmPgui');
  hs  = uicontrol('Parent',dmd, 'Callback','AmPgui species',        'Position',[10 430 100 20], 'String','species',        'Style','pushbutton');
  he  = uicontrol('Parent',dmd, 'Callback','AmPgui ecoCode',        'Position',[10 405 100 20], 'String','ecoCode',        'Style','pushbutton');
  hT  = uicontrol('Parent',dmd, 'Callback','AmPgui T_typical',      'Position',[10 380 100 20], 'String','T_typical',      'Style','pushbutton');
  ha  = uicontrol('Parent',dmd, 'Callback','AmPgui author',         'Position',[10 355 100 20], 'String','author',         'Style','pushbutton');
  hc  = uicontrol('Parent',dmd, 'Callback','AmPgui curator',        'Position',[10 330 100 20], 'String','curator',        'Style','pushbutton');
  hg  = uicontrol('Parent',dmd, 'Callback','AmPgui grp',            'Position',[10 305 100 20], 'String','grp',            'Style','pushbutton');
  hd  = uicontrol('Parent',dmd, 'Callback','AmPgui discussion',     'Position',[10 280 100 20], 'String','discussion',     'Style','pushbutton');
  hf  = uicontrol('Parent',dmd, 'Callback','AmPgui facts',          'Position',[10 255 100 20], 'String','facts',          'Style','pushbutton');
  hk  = uicontrol('Parent',dmd, 'Callback','AmPgui acknowledgment', 'Position',[10 230 100 20], 'String','acknowledgment', 'Style','pushbutton');
  hl  = uicontrol('Parent',dmd, 'Callback','AmPgui links',          'Position',[10 205 100 20], 'String','links',          'Style','pushbutton');
  hb  = uicontrol('Parent',dmd, 'Callback','AmPgui biblist',        'Position',[10 180 100 20], 'String','biblist',        'Style','pushbutton');
  
  h0  = uicontrol('Parent',dmd, 'Callback','AmPgui 0varData',       'Position',[10 135 100 20], 'String','0-var data',     'Style','pushbutton');
  h1  = uicontrol('Parent',dmd, 'Callback','AmPgui 1varData',       'Position',[10 110 100 20], 'String','1-var data',     'Style','pushbutton');
  
  hr  = uicontrol('Parent',dmd, 'Callback','AmPgui resume',         'Position',[10  65 100 20], 'String','resume',         'Style','pushbutton');
  hp  = uicontrol('Parent',dmd, 'Callback','AmPgui pause',          'Position',[10  40 100 20], 'String','pause/save',     'Style','pushbutton');
  
  set(hs, 'ForegroundColor', color.hs); set(he, 'ForegroundColor', color.he); set(hT, 'ForegroundColor', color.hT); set(ha, 'ForegroundColor', color.ha); 
  set(hc, 'ForegroundColor', color.hc); set(hg, 'ForegroundColor', color.hg); set(hd, 'ForegroundColor', color.hd); set(hf, 'ForegroundColor', color.hf); 
  set(hk, 'ForegroundColor', color.hk); set(hl, 'ForegroundColor', color.hl); set(hb, 'ForegroundColor', color.hb);
    
else % perform action
%% fill fields
  switch(action)
      case 'species'
        if ~isfield(metaData, 'species')
          metaData.species = [];
        end
        if ~isfield(metaData, 'links')
          metaData.links = [];
        end
        dS = dialog('Position',[150 150 500 150], 'Name','species dlg');
        Hspecies = uicontrol('Parent',dS, 'Callback',@speciesCb, 'Position',[110 45 350 20], 'Style','edit', 'String',metaData.species); 
         
      case 'ecoCode'
        dE = dialog('Position',[550 550 500 270], 'Name','ecoCode dlg');
        
        % climate
        uicontrol('Parent',dE, 'Position',[10 230 146 20], 'String','climate', 'Style','text');
        Hclimate = uicontrol('Parent',dE, 'Position',[110 230 250 20], 'String',cell2str(metaData.ecoCode.climate)); 
        uicontrol('Parent',dE, 'Callback',@climateCb, 'Position',[370 230 50 20], 'Style','pushbutton', 'String','edit'); 
        
        % ecozone
        uicontrol('Parent',dE, 'Position',[10 200 146 20], 'String','ecozone', 'Style','text');
        Hecozone = uicontrol('Parent',dE, 'Position',[110 200 250 20], 'String',cell2str(metaData.ecoCode.ecozone));
        uicontrol('Parent',dE, 'Callback',@ecozoneCb, 'Position',[370 200 50 20], 'Style','pushbutton', 'String','edit'); 

        % habitat
        uicontrol('Parent',dE, 'Position',[10 170 146 20], 'String','habitat', 'Style','text');
        Hhabitat = uicontrol('Parent',dE, 'Position',[110 170 250 20], 'String',cell2str(metaData.ecoCode.habitat)); 
        uicontrol('Parent',dE, 'Callback',@habitatCb, 'Position',[370 170 50 20], 'Style','pushbutton', 'String','edit'); 

        % embryo
        uicontrol('Parent',dE, 'Position',[10 140 146 20], 'String','embryo', 'Style','text');
        Hembryo = uicontrol('Parent',dE, 'Position',[110 140 250 20], 'String',cell2str(metaData.ecoCode.embryo));
        uicontrol('Parent',dE, 'Callback', @embryoCb,'Position', [370 140 50 20], 'Style','pushbutton', 'String','edit'); 

        % migrate
        uicontrol('Parent',dE, 'Position',[10 110 146 20], 'String','migrate', 'Style','text');
        Hmigrate = uicontrol('Parent',dE, 'Position',[110 110 250 20], 'String',cell2str(metaData.ecoCode.migrate)); 
        uicontrol('Parent',dE, 'Callback',@migrateCb, 'Position',[370 110 50 20], 'Style','pushbutton', 'String','edit'); 

        % food
        uicontrol('Parent',dE, 'Position',[10 80 146 20], 'String','food', 'Style','text');
        Hfood = uicontrol('Parent',dE, 'Position',[110 80 250 20], 'String',cell2str(metaData.ecoCode.food)); 
        uicontrol('Parent',dE, 'Callback',@foodCb, 'Position',[370 80 50 20], 'Style','pushbutton', 'String','edit'); 

        % gender
        uicontrol('Parent',dE, 'Position',[10 50 146 20], 'String','gender', 'Style','text');
        Hgender = uicontrol('Parent',dE, 'Position',[110 50 250 20], 'String',cell2str(metaData.ecoCode.gender)); 
        uicontrol('Parent',dE, 'Callback',@genderCb, 'Position',[370 50 50 20], 'Style','pushbutton', 'String','edit'); 

        % reprod
        uicontrol('Parent',dE, 'Position',[10 20 146 20], 'String','reprod', 'Style','text');
        Hreprod = uicontrol('Parent',dE, 'Position',[110 20 250 20], 'String',cell2str(metaData.ecoCode.reprod)); 
        uicontrol('Parent',dE, 'Callback',@reprodCb, 'Position',[370 20 50 20], 'Style','pushbutton', 'String','edit'); 
        
      case 'T_typical'
        if ~isfield(metaData, 'T_typical')
          metaData.T_typical = [];
        end
        dT = dialog('Position',[300 250 300 100], 'Name','T_typical dlg');
        uicontrol('Parent',dT, 'Position',[10 50 200 20], 'String','Typical body temperature in C', 'Style','text');
        HT = uicontrol('Parent',dT, 'Callback',@T_typicalCb, 'Position',[200 50 50 20], 'Style','edit', 'String',num2str(K2C(metaData.T_typical))); 

      case 'author'
        if ~isfield(metaData, 'author')
          metaData.author = [];
        end
        if ~isfield(metaData, 'email')
          metaData.email = [];
        end
        if ~isfield(metaData, 'address')
          metaData.address = [];
        end
        Datevec = datevec(datenum(date)); metaData.date_subm = Datevec(1:3);
        dA = dialog('Position',[150 150 500 150], 'Name','author dlg');
        uicontrol('Parent',dA, 'Position',[10 95 146 20], 'String','Name', 'Style','text');
        Hauthor  = uicontrol('Parent',dA, 'Callback',@authorCb, 'Position',[110 95 350 20], 'Style','edit', 'String',metaData.author); 
        uicontrol('Parent',dA, 'Position',[10 70 146 20], 'String','email', 'Style','text');
        Hemail   = uicontrol('Parent',dA, 'Callback',@emailCb, 'Position',[110 70 350 20], 'Style','edit', 'String',metaData.email); 
        uicontrol('Parent',dA, 'Position',[10 45 146 20], 'String','address', 'Style','text');
        Haddress = uicontrol('Parent',dA, 'Callback',@addressCb, 'Position',[110 45 350 20], 'Style','edit', 'String',metaData.address); 
        
      case 'curator'
        curList = {'Starrlight Augustine', 'Dina Lika', 'Nina Marn', 'Mike Kearney', 'Bas Kooijman'};
        emailList = {'starrlight.augustine@akvaplan.niva.no', 'lika@uoc.gr' ,'nina.marn@gmail.com', 'mrke@unimelb.edu.au', 'salm.kooijman@gmail.com'};
        i_cur =  listdlg('ListString',curList, 'SelectionMode','single', 'Name','curator dlg', 'ListSize',[140 80], 'InitialValue', 5);
        metaData.curator = curList{i_cur}; metaData.email_cur = emailList{i_cur}; 
        Datevec = datevec(datenum(date)); metaData.date_acc = Datevec(1:3);
        color.hc = [0 .6 0]; set(hc, 'ForegroundColor', color.hc);
        
      case 'grp'
 
      case 'discussion'
        if ~isfield(metaData, 'discussion')
          metaData.discussion = []; metaData.discussion.D1 = []; metaData.bibkey.D1 = [];
        end
        dD = dialog('Position',[150 150 950 550], 'Name','discussion dlg');
        uicontrol('Parent',dD, 'Callback',@addDiscussionCb, 'Position',[110 500 150 20], 'String','add discussion point', 'Style','pushbutton');
        uicontrol('Parent',dD, 'Position',[790 500 146 20], 'String','bibkey', 'Style','text');
        
        fldnm = fieldnames(metaData.discussion); n = length(fldnm);
        for i = 1:n
          hight = 475 - i * 25; nm = ['D', num2str(n)];
          uicontrol('Parent',dD, 'Position',[10, hight, 146, 20], 'String',nm, 'Style','text');
          HD(i)  = uicontrol('Parent',dD, 'Callback',@discussionCb, 'Position',[110, hight, 650, 20], 'Style','edit', 'String',metaData.discussion.(nm)); 
          HDb(i) = uicontrol('Parent',dD, 'Callback',@discussionCb, 'Position',[850, hight, 80, 20], 'Style','edit', 'String',metaData.bibkey.(nm)); 
        end

      case 'facts'
        if ~isfield(metaData, 'facts')
          metaData.facts = []; metaData.facts.F1 = []; metaData.bibkey.F1 = [];
        end
        dF = dialog('Position',[150 150 950 550], 'Name','facts dlg');
        HF = uicontrol('Parent', dF, 'Callback',@addFactCb, 'Position',[110 500 150 20], 'String','add fact', 'Style','pushbutton');
        uicontrol('Parent',dF, 'Position',[790 500 146 20], 'String','bibkey', 'Style','text');
        
        fldnm = fieldnames(metaData.facts); n = length(fldnm);
        for i = 1:n
          hight = 475 - i * 25; nm = ['F', num2str(n)];
          uicontrol('Parent',dF, 'Position',[10, hight, 146, 20], 'String',nm, 'Style','text');
          HF(i)  = uicontrol('Parent',dF, 'Callback',@factsCb, 'Position',[110, hight, 650, 20], 'Style','edit', 'String',metaData.facts.(nm)); 
          HFb(i) = uicontrol('Parent',dF, 'Callback',@factsCb, 'Position',[850, hight, 80, 20], 'Style','edit', 'String',metaData.facts.(nm)); 
        end

      case 'acknowledgment'
        if ~isfield(metaData, 'acknowledgment')
          metaData.acknowledgment = [];
        end
        dK = dialog('Position',[150 150 700 150], 'Name','acknowledgment dlg');
        uicontrol('Parent',dK, 'Position',[10 95 146 20], 'String','Text', 'Style','text');
        Hacknowledgment = uicontrol('Parent',dK, 'Callback',@acknowledgmentCb, 'Position',[110 95 550 20], 'Style','edit', 'String',metaData.acknowledgment); 
        
      case 'links'
        if ~isfield(metaData, 'links')
          metaData.links = [];
        end
        dL = dialog('Position',[150 150 350 350],'Name','links dlg');
        id_links = {'id_CoL','id_EoL','id_Wiki','id_ADW','id_Taxo','id_WoRMS', ...
          'id_molluscabase','id_fishbase','id_amphweb','id_ReptileDB','id_avibase','id_birdlife','id_MSW3','id_AnAge'};
        links = {...
          'http://www.catalogueoflife.org/col/'; ...
          'http://eol.org/'; ...
          'http://en.wikipedia.org/wiki/'; ...
          'http://animaldiversity.org/'; ...
          'http://taxonomicon.taxonomy.nl/'; ...
          'http://marinespecies.org/'; ...
          % taxon-specific links
          'http://www.molluscabase.org/'; ...
          'http://www.fishbase.org/'; ...
          'http://amphibiaweb.org/search/'; ...
          'http://reptile-database.reptarium.cz/'; ...
          'https://avibase.bsc-eoc.org/'; ...
          'http://datazone.birdlife.org/'; ...
          'https://www.departments.bucknell.edu/biology/resources/msw3/'; ...
          'http://genomics.senescence.info/'};
        id_links = id_links(select_id); links = links(select_id); n_links = length(id_links);
        for i= 1:n_links 
          web(links{i},'-browser');
          hight = 275 - i * 25;
          if ~isfield(metaData.links, id_links{i})
            metaData.links.(id_links{i}) = [];
          end
          uicontrol('Parent',dL, 'Position',[0, hight, 146, 20], 'String',id_links{i}, 'Style','text');
          HL(i)  = uicontrol('Parent',dL, 'Callback',@linksCb, 'Position',[110, hight, 210, 20], 'Style','edit', 'String',metaData.links.(id_links{i})); 
        end
        
    case 'biblist'
        
    case '0varData' 
      d0 = dialog('Position',[150 150 1000 620], 'Name','0-variate data dlg');
      uicontrol('Parent',d0, 'Position',[300 580 150 20], 'Callback',@add0Cb, 'String','add 0-var data', 'Style','pushbutton');
      uicontrol('Parent',d0, 'Position',[ 60 550 70 20], 'String','name', 'Style','text');
      uicontrol('Parent',d0, 'Position',[150 550 70 20], 'String','value', 'Style','text');
      uicontrol('Parent',d0, 'Position',[250 550 70 20], 'String','units', 'Style','text');
      uicontrol('Parent',d0, 'Position',[325 550 70 20], 'String','temp in C', 'Style','text');
      uicontrol('Parent',d0, 'Position',[450 550 70 20], 'String','label', 'Style','text');
      uicontrol('Parent',d0, 'Position',[550 550 70 20], 'String','bibkey', 'Style','text');
      uicontrol('Parent',d0, 'Position',[650 550 70 20], 'String','comment', 'Style','text');

      if ~isempty(data.data_0)
        fld = fieldnames(data.data_0); n = length(fld);
        for i = 1:n
          hight = 550 - i * 25; 
          H0n(i) = uicontrol('Parent',d0, 'Callback',{@d0NmCb, i}, 'Position',[ 60, hight,  70, 20], 'Style','edit', 'String',fld{i}); 
          H0v(i) = uicontrol('Parent',d0, 'Callback',{@d0Cb, i},   'Position',[150, hight,  70, 20], 'Style','edit', 'String',num2str(data.data_0.(fld{i}))); 
          H0u(i) = uicontrol('Parent',d0, 'Callback',{@d0Cb, i},   'Position',[250, hight,  70, 20], 'Style','edit', 'String',txtData.units.(fld{i})); 
          H0T(i) = uicontrol('Parent',d0, 'Callback',{@d0Cb, i},   'Position',[350, hight,  40, 20], 'Style','edit', 'String',num2str(K2C(auxData.temp.(fld{i})))); 
          H0l(i) = uicontrol('Parent',d0, 'Callback',{@d0Cb, i},   'Position',[410, hight, 120, 20], 'Style','edit', 'String',txtData.label.(fld{i})); 
          H0b(i) = uicontrol('Parent',d0, 'Callback',{@d0Cb, i},   'Position',[550, hight,  70, 20], 'Style','edit', 'String',metaData.bibkey.(fld{i})); 
          H0c(i) = uicontrol('Parent',d0, 'Callback',{@d0Cb, i},   'Position',[650, hight, 300, 20], 'Style','edit', 'String',metaData.comment.(fld{i})); 
        end
      end

    case '1varData' 

    case 'resume'
      list = cellstr(ls);
      list = list(contains(list,'results_'));
      if length(list) == 1
        load(list);
      elseif length(list) == 0
        fprintf('Warning from AmPgui: no results_my_pet.mat found\n');
      else
        fprintf('Warning from AmPgui: more than a single file results_my_pet.mat found, remove the wrong ones first\n');
      end
      
    case 'pause'
      nm = ['results_', metaData.species, '.mat'];
      list = cellstr(ls);
      list = list(contains(list,'results_'));
      if length(list) > 1
        fprintf('Warning from AmPgui: more than one file results_my_pet.mat found; this will give problems when resuming\n');
      elseif length(list) == 1 && strcmp(list{1}, nm)
        fprintf(['Warning from AmPgui: file ', list{1}, ' found; this will give problems when resuming\n']);
      end
      save(nm, 'data', 'auxData', 'metaData', 'txtData', 'color', 'select_id', 'id_links', 'eco_types');
      dP = dialog('Position',[150 150 500 150],'Name','pause dlg');
      uicontrol('Parent',dP, 'Position',[ 50 95 400 20], 'String',['File ', nm, ' has been written'], 'Style','text');
      uicontrol('Parent',dP, 'Position',[130 60 100 20], 'Callback',@returnCb, 'String','quit AmPeps', 'Style','pushbutton');
      uicontrol('Parent',dP, 'Position',[250 60 100 20], 'Callback',@saveCb, 'String','stay in AmPeps', 'Style','pushbutton');
  end
  
  if any([isempty(metaData.ecoCode.climate), isempty(metaData.ecoCode.ecozone), isempty(metaData.ecoCode.habitat), ...
          isempty(metaData.ecoCode.embryo), isempty(metaData.ecoCode.food), isempty(metaData.ecoCode.gender), isempty(metaData.ecoCode.reprod)])
    color.he = [1 0 0]; set(he, 'ForegroundColor', color.he);
  else
    color.he = [0 0.6 0]; set(he, 'ForegroundColor', color.he);
  end

  if isempty(data)
    color.h0 = [1 0 0]; set(he, 'ForegroundColor', color.h0);
  else
    color.h0 = [0 0.6 0]; set(he, 'ForegroundColor', color.h0);
  end
end
end

%% callback functions
function speciesCb(source, eventdata)  
  global metaData Hspecies dS hs color select_id
   
  spnm = get(Hspecies, 'string');
  if ~isempty(spnm)
    color.hs = [0 .6 0]; set(hs, 'ForegroundColor', color.hs);
  end
  select_id = false(14,1);
  spnm = strrep(spnm, ' ', '_'); 
  [id_CoL, my_pet] = get_id_CoL(spnm); 
  if isempty(id_CoL)
    web('http://www.catalogueoflife.org/col/','-browser');
    uicontrol('Parent',dS, 'Position',[110 70 350 20], 'Style','text', 'String','species not recognized, search CoL');
  elseif ismember(my_pet,select)
    uicontrol('Parent',dS, 'Position',[110 95 350 20], 'Style','text', 'String','species is already in AmP');
    uicontrol('Parent',dS, 'Position',[110 75 350 20], 'Style','text', 'String','close and proceed to post-editing phase of AmPeps');
  else
    [lin, rank] = lineage_CoL(my_pet);
    metaData.species = my_pet; metaData.links.id_CoL = id_CoL;
    metaData.species_en = get_common_CoL(id_CoL);
    nm = lin(ismember(rank, 'Family')); metaData.family = nm{1};
    nm = lin(ismember(rank, 'Order'));  metaData.order = nm{1};
    nm = lin(ismember(rank, 'Class'));  metaData.class = nm{1};
    nm = lin(ismember(rank, 'Phylum')); metaData.phylum = nm{1};
    select_id(1:6) = true; % selection vector for links
    if strcmp(metaData.class, 'Mollusca')
      select_id(7) = true;
    end
    if ismember(metaData.class, {'Cyclostomata', 'Chondrichthyes', 'Actinopterygii', 'Actinistia', 'Dipnoi'})
      select_id(8) = true;
    end
    if strcmp(metaData.class, 'Amphibia')
      select_id(9) = true;
    end
    if strcmp(metaData.class, 'Reptilia')
      select_id(10) = true;
    end
    if strcmp(metaData.class, 'Aves')
      select_id(11:12) = true;
    end
    if strcmp(metaData.class, 'Mammalia')
      select_id(13) = true;
    end
    if ismember(metaData.class, {'Aves', 'Mammalia'})
      select_id(14) = true;
    end
  end
end
 
function climateCb(source, eventdata)  
  global metaData color eco_types Hclimate
  climateCode = fieldnames(eco_types.climate); n_climate = length(climateCode); i_climate = 1:n_climate;
  if isempty(metaData.ecoCode.climate)
    i_climate = 1;
  else
    sel_climate = ismember(climateCode,metaData.ecoCode.climate); i_climate = i_climate(sel_climate);
  end
  i_climate =  listdlg('ListString',climateCode, 'Name','climate dlg', 'ListSize',[100 600], 'InitialValue',i_climate);
   
  metaData.ecoCode.climate = climateCode(i_climate); 
  set(Hclimate, 'String', cell2str(metaData.ecoCode.climate)); 
end

function ecozoneCb(source, eventdata)  
  global metaData eco_types Hecozone
  ecozoneCode = fieldnames(eco_types.ecozone); n_ecozone = length(ecozoneCode); i_ecozone = 1:n_ecozone;
  ecozoneCodeList = ecozoneCode;
   for i=1:n_ecozone
     ecozoneCodeList{i} = [ecozoneCodeList{i}, ': ', eco_types.ecozone.(ecozoneCode{i})];
   end
   if isempty(metaData.ecoCode.ecozone)
     i_ecozone = 1;
   else
     sel_ecozone = ismember(ecozoneCode,metaData.ecoCode.ecozone); i_ecozone = i_ecozone(sel_ecozone);
   end
   i_ecozone =  listdlg('ListString', ecozoneCodeList,'Name', 'ecozone dlg','ListSize',[450 500], 'InitialValue',i_ecozone);
   metaData.ecoCode.ecozone = ecozoneCode(i_ecozone); 
   set(Hecozone, 'String', cell2str(metaData.ecoCode.ecozone)); 
end
 
function habitatCb(source, eventdata)  
  global metaData eco_types Hhabitat
  habitatCode = fieldnames(eco_types.habitat); n_habitat = length(habitatCode); 
  habitatCodeList = habitatCode;
  for i=1:n_habitat
    habitatCodeList{i} = [habitatCodeList{i}, ': ', eco_types.habitat.(habitatCode{i})];
  end
  if isempty(metaData.ecoCode.habitat)
    i_habitat = 1;
  else
    i_habitat = 1:n_habitat;
    i_habitat = i_habitat(i_habitat(ismember(habitatCode,metaData.ecoCode.habitat)));
  end
  i_habitat =  listdlg('ListString',habitatCodeList, 'Name','habitat dlg', 'ListSize',[400 500], 'InitialValue',i_habitat);
  habitatCode = prependStage(habitatCode(i_habitat));
  metaData.ecoCode.habitat = habitatCode; 
  set(Hhabitat, 'String', cell2str(metaData.ecoCode.habitat)); 
end

function embryoCb(source, eventdata)  
  global metaData eco_types Hembryo
  embryoCode = fieldnames(eco_types.embryo); n_embryo = length(embryoCode); 
  embryoCodeList = embryoCode;
  for i=1:n_embryo
    embryoCodeList{i} = [embryoCodeList{i}, ': ', eco_types.embryo.(embryoCode{i})];
  end
  if isempty(metaData.ecoCode.embryo)
    i_embryo = 1;
  else
    i_embryo = 1:n_embryo;
    i_embryo = i_embryo(i_embryo(ismember(embryoCode,metaData.ecoCode.embryo)));
  end
  i_embryo =  listdlg('ListString',embryoCodeList, 'Name','embryo dlg', 'ListSize',[450 500], 'InitialValue',i_embryo);
  metaData.ecoCode.embryo = embryoCode(i_embryo); 
  set(Hembryo, 'String', cell2str(metaData.ecoCode.embryo)); 
end

function migrateCb(source, eventdata)  
  global metaData eco_types Hmigrate
  migrateCode = fieldnames(eco_types.migrate); n_migrate = length(migrateCode); 
  migrateCodeList = migrateCode;
  for i=1:n_migrate
    migrateCodeList{i} = [migrateCodeList{i}, ': ', eco_types.migrate.(migrateCode{i})];
  end
  if isempty(metaData.ecoCode.migrate)
    i_migrate = 1;
  else
    i_migrate = 1:n_migrate;
    i_migrate = i_migrate(i_migrate(ismember(migrateCode,metaData.ecoCode.migrate)));
  end
  i_migrate =  listdlg('ListString',migrateCodeList, 'Name','migrate dlg', 'ListSize',[550 140], 'InitialValue',i_migrate);
  metaData.ecoCode.migrate = migrateCode(i_migrate); 
  set(Hmigrate, 'String', cell2str(metaData.ecoCode.migrate)); 
end

function foodCb(source, eventdata)  
  global metaData eco_types Hfood
  foodCode = fieldnames(eco_types.food); n_food = length(foodCode); 
  foodCodeList = foodCode;
  for i=1:n_food
    foodCodeList{i} = [foodCodeList{i}, ': ', eco_types.food.(foodCode{i})];
  end
  if isempty(metaData.ecoCode.food)
    i_food = 1;
  else
    i_food = 1:n_food;
    i_food = i_food(i_food(ismember(foodCode,metaData.ecoCode.food)));
  end
  i_food =  listdlg('ListString',foodCodeList, 'Name','food dlg', 'ListSize',[450 500], 'InitialValue',i_food);
  foodCode = prependStage(foodCode(i_food));
  metaData.ecoCode.food = foodCode; 
  set(Hfood, 'String', cell2str(metaData.ecoCode.food)); 
end

function genderCb(source, eventdata)  
  global metaData eco_types Hgender
  genderCode = fieldnames(eco_types.gender); n_gender = length(genderCode); 
  genderCodeList = genderCode;
  for i=1:n_gender
    genderCodeList{i} = [genderCodeList{i}, ': ', eco_types.gender.(genderCode{i})];
  end
  if isempty(metaData.ecoCode.gender)
    i_gender = 1;
  else
    i_gender = 1:n_gender;
    i_gender = i_gender(i_gender(ismember(genderCode,metaData.ecoCode.gender)));
  end
  i_gender =  listdlg('ListString',genderCodeList, 'Name','gender dlg', 'ListSize',[450 190], 'InitialValue',i_gender);
  metaData.ecoCode.gender = genderCode(i_gender); 
  set(Hgender, 'String', cell2str(metaData.ecoCode.gender)); 
end

function reprodCb(source, eventdata)  
  global metaData eco_types Hreprod
  reprodCode = fieldnames(eco_types.reprod); n_reprod = length(reprodCode); 
  reprodCodeList = reprodCode;
  for i=1:n_reprod
    reprodCodeList{i} = [reprodCodeList{i}, ': ', eco_types.reprod.(reprodCode{i})];
  end
  if isempty(metaData.ecoCode.reprod)
    i_reprod = 1;
  else
    i_reprod = 1:n_reprod;
    i_reprod = i_reprod(i_reprod(ismember(reprodCode,metaData.ecoCode.reprod)));
  end
  i_reprod =  listdlg('ListString',reprodCodeList, 'Name','reprod dlg', 'ListSize',[450 120], 'InitialValue',i_reprod);
  metaData.ecoCode.reprod = reprodCode(i_reprod); 
  set(Hreprod, 'String', cell2str(metaData.ecoCode.reprod)); 
end

function T_typicalCb(source, eventdata)  
   global metaData HT hT color
   metaData.T_typical = C2K(str2double(get(HT, 'string')));
   if ~isempty(metaData.T_typical)
     color.hT = [0 .6 0]; set(hT, 'ForegroundColor', color.hT);
   end
 end
 
 function authorCb(source, eventdata)  
   global metaData Hauthor ha color
   metaData.author = str2cell(get(Hauthor, 'string'));
   if ~isempty(metaData.author)
     color.ha = [0 .6 0]; set(ha, 'ForegroundColor', color.ha);
   end
 end
 
 function emailCb(source, eventdata) 
   global metaData Hemail
   metaData.email = get(Hemail, 'string');
 end
 
 function addressCb(source, eventdata)  
   global metaData Haddress
   metaData.address = get(Haddress, 'string');
 end

 function addDiscussionCb(source, eventdata)
  global metaData HD HDb dD
  n = 1 + length(fieldnames(metaData.discussion)); nm = ['D', num2str(n)]; hight = 475 - n * 25;
  metaData.discussion.(nm) = []; metaData.bibkey.(nm) = [];
  uicontrol('Parent',dD, 'Position', [10, hight, 146, 20], 'String',nm, 'Style','text');
  HD(n)  = uicontrol('Parent',dD, 'Callback',@discussionCb, 'Position',[110, hight, 650, 20], 'Style','edit', 'String',metaData.discussion.(nm)); 
  HDb(n) = uicontrol('Parent',dD, 'Callback',@discussionCb, 'Position',[850, hight, 80, 20],  'Style','edit', 'String',metaData.bibkey.(nm)); 
 end
  
 function discussionCb(source, eventdata)
   global metaData hd HD HDb 
   fldnm = fieldnames(metaData.discussion); n = length(fldnm);
   for i = 1:n
     nm = ['D', num2str(n)];
     metaData.discussion.(nm) = get(HD(i), 'string');
     metaData.bibkey.(nm) = str2cell(get(HDb(i), 'string'));
   end
   if ~isempty(metaData.discussion.D1)
     color.hd = [0 .6 0]; set(hd, 'ForegroundColor', color.hd);
   end
 end
 
 function addFactCb(source, eventdata)
   global metaData HF HFb dF
   n = 1 + length(fieldnames(metaData.facts)); nm = ['F', num2str(n)]; hight = 475 - n * 25; 
   metaData.facts.(nm) = []; metaData.bibkey.(nm) = [];
   uicontrol('Parent', dF, 'Position', [10, hight, 146, 20], 'String', nm, 'Style', 'text');
   HF(n)  = uicontrol('Parent',dF, 'Callback',@factsCb, 'Position',[110, hight, 650, 20], 'Style','edit', 'String',metaData.facts.(nm)); 
   HFb(n) = uicontrol('Parent',dF, 'Callback',@factsCb, 'Position',[850, hight, 80, 20],  'Style','edit', 'String',metaData.facts.(nm)); 
 end

 function factsCb(source, eventdata)  
   global metaData hf HF HFb 
   fldnm = fieldnames(metaData.facts); n = length(fldnm);
   for i = 1:n
     nm = ['F', num2str(n)];
     metaData.facts.(nm) = get(HF(i), 'string');
     metaData.bibkey.(nm) = str2cell(get(HFb(i), 'string'));
   end
   if ~isempty(metaData.facts.F1)
     color.hf = [0 .6 0]; set(hf, 'ForegroundColor', color.hf);
   end
 end
 
 function acknowledgmentCb(source, eventdata)  
   global metaData Hacknowledgment hk color
   metaData.acknowledgment = get(Hacknowledgment, 'string');
   if ~isempty(metaData.acknowledgment)
     color.hk = [0 .6 0]; set(hk, 'ForegroundColor', color.hk);
   end
 end
 
function linksCb(source, eventdata)  
  global metaData hl HL id_links
  fldnm = fieldnames(metaData.links); n_links = length(fldnm);
  for i = 1:n_links
    metaData.links.(id_links{i}) = get(HL(i), 'string');
  end
  color.hl = [0 .6 0]; set(hl, 'ForegroundColor', color.hl);
end

function add0Cb(source, eventdata)
   global data d0 H0n H0v H0u H0T H0l H0b H0c
   if isempty(data.data_0)
     n = 1;
   else
     n = 1 + length(fieldnames(data.data_0));
   end
   data.data_0.new = []; hight = 550 - n * 25; 
   H0n(n) = uicontrol('Parent',d0, 'Callback',{@d0NmCb, n}, 'Position',[ 60, hight,  70, 20], 'Style','edit', 'String','');
   H0v(n) = uicontrol('Parent',d0, 'Callback',{@d0Cb, n},   'Position',[150, hight,  70, 20], 'Style','edit', 'String',''); 
   H0u(n) = uicontrol('Parent',d0, 'Callback',{@d0Cb, n},   'Position',[250, hight,  70, 20], 'Style','edit', 'String',''); 
   H0T(n) = uicontrol('Parent',d0, 'Callback',{@d0Cb, n},   'Position',[350, hight,  40, 20], 'Style','edit', 'String',''); 
   H0l(n) = uicontrol('Parent',d0, 'Callback',{@d0Cb, n},   'Position',[410, hight, 120, 20], 'Style','edit', 'String',''); 
   H0b(n) = uicontrol('Parent',d0, 'Callback',{@d0Cb, n},   'Position',[550, hight,  70, 20], 'Style','edit', 'String',''); 
   H0c(n) = uicontrol('Parent',d0, 'Callback',{@d0Cb, n},   'Position',[650, hight, 300, 20], 'Style','edit', 'String',''); 
end 

function d0NmCb(source, eventdata, i)
   global data auxData txtData metaData d0 H0e H0n 
   fld = fieldnames(data.data_0); n = length(fld);
   nm = get(H0n(i), 'string'); 
   data.data_0 = renameStructField(data.data_0, fld{i}, nm); 
   
   if isfield(txtData.units, fld{i})
     txtData.units = renameStructField(txtData.units, fld{i}, nm);  
     txtData.label = renameStructField(txtData.label, fld{i}, nm);  
   end
   if isfield(auxData.temp, fld{i})
     auxData.temp = renameStructField(auxData.temp, fld{i}, nm);  
   end 
   if isfield(metaData.bibkey, fld{i})
     metaData.bibkey = renameStructField(metaData.bibkey, fld{i}, nm);  
   end 

end

function d0Cb(source, eventdata, i)  
   global data auxData txtData metaData H0v H0u H0T H0l H0b H0c
   fld = fieldnames(data.data_0);
   data.data_0.(fld{i}) = str2double(get(H0v(i), 'string'));
   txtData.units.(fld{i}) = get(H0u(i), 'string'); 
   auxData.temp.(fld{i}) = C2K(str2double(get(H0T(i), 'string')));
   txtData.label.(fld{i}) = get(H0l(i), 'string'); 
   metaData.bibkey.(fld{i}) = str2cell(get(H0b(i), 'string'));
   txtData.comment.(fld{i}) = str2cell(get(H0c(i), 'string'));
end
 
function returnCb(source, eventdata) 
  global dmd dP
  close(dP);   % close pause dialog
  delete(dmd); 
  return       % quite AmPgui
end

function saveCb(source, eventdata)  
  global dP
  delete(dP);
end

%% other support functions
function str = cell2str(cell)
  if isempty(cell)
    str = []; return
  end
  n = length(cell); str = [];
  for i=1:n
    str = [str, cell{i}, ','];
  end
  str(end) = [];
end

function c = str2cell(str)
  if isempty(str)
    c = []; return
  end
  str = strsplit(str, ',');
  n = length(str); 
  if n == 1
    c = str;
  else
    c = cell(1,n);
    for i=1:n
      c{i} = str(i);
     end
  end
end

function code = prependStage(code)
  stageList = {'0b', '0j', '0x', '0p', '0i', 'bj', 'bx', 'bp', 'bi', 'jp', 'ji', 'xp', 'xi', 'pi'};
  n = length(code);
  for i = 1:n
    fprintf(['Prepend stage for code ', code{i},'\n']);
    i_stage =  listdlg('ListString',stageList, 'Name','stage dlg', 'SelectionMode','single', 'ListSize',[150 150], 'InitialValue',2);
    code{i} = [stageList{i_stage}, code{i}];
  end
end
