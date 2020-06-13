%% AmPgui
% a GUI to create 4 structures

%%
function AmPgui(action)
% created 2020/06/05 by  Bas Kooijman

%% Syntax
% <../AmPgui.m *AmPgui*>

%% Description
% Like mydata_my_pet.m, it writes 4 data-structures from scratch
%
% * data: structure with data
% * auxData: structure with auxilirary data 
% * metaData: structure with metaData 
% * txtData: structure with text for data 
%
% Input: no explicit input (facultative input is set by the function itself in multiple calls) 
%
% Output: no explicit output, but global exit-flag infoAmPgui is set with
%
% * 0 stay in AmPgui
% * 1 stay in AmPeps
% * 2 stay quit AmPeps, and proceed to load files in Matlab editor

%% Remarks
%
% * Set metaData on global before use of this function.
% * Files will be saved in your local directory, which should not contain results_my_pet.mat files, other than written my this function 
% * Use the cd command to the dir of your choice BEFORE running this function to save files in the desired place.
% * All weights are set at default values in the resulting file; 
% * This function is called in AmPeps
% * Font colors in main AmPgui mean:
%
%   - red: editing required
%   - green: editing not necessary
%   - black: editing facultative
% 
% Notice that font colors only represent intennal consistency, ireespective of content.

global data auxData metaData txtData select_id id_links eco_types
global Hauthor Hemail Haddress Hspecies HK HD HDb HF HFb HT HL H0v H0T H0b H0c D1 
global Hclimate Hecozone Hhabitat Hembryo Hmigrate Hfood Hgender Hreprod

%% initiation

%UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize'); % 8
set(0, 'DefaultUIControlFontSize', 9);
%set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);

if ~isfield(data, 'data_0') 
  data.data_0 = [];
end   
if ~isfield(data, 'data_1') 
  data.data_1 = [];
end   
if ~isfield(auxData, 'temp') 
  auxData.temp = [];
end
if ~isfield(txtData, 'units')
  txtData.units = []; txtData.label = [];
end

if ~isfield(metaData, 'species') 
  metaData.species = [];
end   
if ~isfield(metaData, 'species_en') 
  metaData.species_en = [];
end  
if ~isfield(metaData, 'family') 
  metaData.family = [];
end   
if ~isfield(metaData, 'order') 
  metaData.order = [];
end  
if ~isfield(metaData, 'class') 
  metaData.class = [];
end  
if ~isfield(metaData, 'phylum') 
  metaData.phylum = [];
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
if ~isfield(metaData, 'T_typical')
  metaData.T_typical = [];
end
if ~isfield(metaData, 'bibkey')
  metaData.bibkey = [];
end
if ~isfield(metaData, 'comment') 
  metaData.comment = [];
end
if ~isfield(metaData, 'links') 
  metaData.links = [];
end
if ~isfield(metaData, 'author')
  metaData.author = [];
end
if ~isfield(metaData, 'email')
  metaData.email = [];
end
if ~isfield(metaData, 'address')
  metaData.address = [];
end
if ~isfield(metaData, 'discussion')
  metaData.discussion = []; metaData.discussion.D1 = []; metaData.bibkey.D1 = [];
end
if ~isfield(metaData, 'facts')
  metaData.facts = []; metaData.facts.F1 = []; metaData.bibkey.F1 = [];
end
if ~isfield(metaData, 'acknowledgment')
  metaData.acknowledgment = [];
end

if ~exist('color','var')
  color = []; % font colors for items in main AmPgui
end
if isempty(color)
  color.Hs = [1 0 0]; color.He = [1 0 0]; color.HT = [1 0 0]; color.Ha = [1 0 0]; color.Hc = [1 0 0];
  color.Hg = [0 0 0]; color.Hd = [0 0 0]; color.Hf = [0 0 0]; color.Hk = [0 0 0]; color.Hl = [1 0 0];
  color.Hb = [1 0 0]; color.H0 = [1 0 0]; color.H1 = [0 0 0]; color.Hr = [0 0 0]; color.Hp = [0 0 0];
end
if isempty(eco_types)
  get_eco_types;
end

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
  
        uicontrol('Parent',dmd, 'Callback','AmPgui 0varData',       'Position',[10 135 100 20], 'String','0-var data',     'Style','pushbutton');
        uicontrol('Parent',dmd, 'Callback','AmPgui 1varData',       'Position',[10 110 100 20], 'String','1-var data',     'Style','pushbutton');
  
        uicontrol('Parent',dmd, 'Callback','AmPgui resume',         'Position',[10  65 100 20], 'String','resume',         'Style','pushbutton');
        uicontrol('Parent',dmd, 'Callback','AmPgui pause',          'Position',[10  40 100 20], 'String','pause/save',     'Style','pushbutton');
        uicontrol('Parent',dmd, 'Callback',{@OKCb,dmd},             'Position',[50  15  20 20], 'String','OK',             'Style','pushbutton');
  
  set(hs, 'ForegroundColor', color.Hs); set(he, 'ForegroundColor', color.He); set(hT, 'ForegroundColor', color.HT); set(ha, 'ForegroundColor', color.Ha); 
  set(hc, 'ForegroundColor', color.Hc); set(hg, 'ForegroundColor', color.Hg); set(hd, 'ForegroundColor', color.Hd); set(hf, 'ForegroundColor', color.Hf); 
  set(hk, 'ForegroundColor', color.Hk); set(hl, 'ForegroundColor', color.Hl); set(hb, 'ForegroundColor', color.Hb);
    
else % perform action
%% fill fields
  switch(action)
      case 'species'
        dS = dialog('Position',[150 150 600 150], 'Name','species dlg');
        Hspecies = uicontrol('Parent',dS, 'Callback',{@speciesCb,dS}, 'Position',[110 30 350 20], 'Style','edit', 'String',metaData.species); 
         
      case 'ecoCode'
        dE = dialog('Position',[550 550 500 270], 'Name','ecoCode dlg');
        
        % climate
        uicontrol('Parent',dE, 'Position',[10 230 146 20], 'String','climate', 'Style','text');
        Hclimate = uicontrol('Parent',dE, 'Position',[110 230 250 20], 'String',cell2str(metaData.ecoCode.climate)); 
        uicontrol('Parent',dE, 'Callback',{@climateCb,Hclimate}, 'Position',[370 230 50 20], 'Style','pushbutton', 'String','edit'); 
        
        % ecozone
        uicontrol('Parent',dE, 'Position',[10 200 146 20], 'String','ecozone', 'Style','text');
        Hecozone = uicontrol('Parent',dE, 'Position',[110 200 250 20], 'String',cell2str(metaData.ecoCode.ecozone));
        uicontrol('Parent',dE, 'Callback',{@ecozoneCb,Hecozone}, 'Position',[370 200 50 20], 'Style','pushbutton', 'String','edit'); 

        % habitat
        uicontrol('Parent',dE, 'Position',[10 170 146 20], 'String','habitat', 'Style','text');
        Hhabitat = uicontrol('Parent',dE, 'Position',[110 170 250 20], 'String',cell2str(metaData.ecoCode.habitat)); 
        uicontrol('Parent',dE, 'Callback',{@habitatCb,Hhabitat}, 'Position',[370 170 50 20], 'Style','pushbutton', 'String','edit'); 

        % embryo
        uicontrol('Parent',dE, 'Position',[10 140 146 20], 'String','embryo', 'Style','text');
        Hembryo = uicontrol('Parent',dE, 'Position',[110 140 250 20], 'String',cell2str(metaData.ecoCode.embryo));
        uicontrol('Parent',dE, 'Callback',{@embryoCb,Hembryo}, 'Position',[370 140 50 20], 'Style','pushbutton', 'String','edit'); 

        % migrate
        uicontrol('Parent',dE, 'Position',[10 110 146 20], 'String','migrate', 'Style','text');
        Hmigrate = uicontrol('Parent',dE, 'Position',[110 110 250 20], 'String',cell2str(metaData.ecoCode.migrate)); 
        uicontrol('Parent',dE, 'Callback',{@migrateCb,Hmigrate}, 'Position',[370 110 50 20], 'Style','pushbutton', 'String','edit'); 

        % food
        uicontrol('Parent',dE, 'Position',[10 80 146 20], 'String','food', 'Style','text');
        Hfood = uicontrol('Parent',dE, 'Position',[110 80 250 20], 'String',cell2str(metaData.ecoCode.food)); 
        uicontrol('Parent',dE, 'Callback',{@foodCb,Hfood}, 'Position',[370 80 50 20], 'Style','pushbutton', 'String','edit'); 

        % gender
        uicontrol('Parent',dE, 'Position',[10 50 146 20], 'String','gender', 'Style','text');
        Hgender = uicontrol('Parent',dE, 'Position',[110 50 250 20], 'String',cell2str(metaData.ecoCode.gender)); 
        uicontrol('Parent',dE, 'Callback',{@genderCb,Hgender}, 'Position',[370 50 50 20], 'Style','pushbutton', 'String','edit'); 

        % reprod
        uicontrol('Parent',dE, 'Position',[10 20 146 20], 'String','reprod', 'Style','text');
        Hreprod = uicontrol('Parent',dE, 'Position',[110 20 250 20], 'String',cell2str(metaData.ecoCode.reprod)); 
        uicontrol('Parent',dE, 'Callback',{@reprodCb,Hreprod}, 'Position',[370 20 50 20], 'Style','pushbutton', 'String','edit'); 
        uicontrol('Parent',dE, 'Callback',{@OKCb,dE}, 'Position',[430 20 50 20], 'Style','pushbutton', 'String','OK'); 
        
      case 'T_typical'
        dT = dialog('Position',[300 250 300 100], 'Name','T_typical dlg');
        uicontrol('Parent',dT, 'Position',[10 50 200 20], 'String','Typical body temperature in C', 'Style','text');
        HT = uicontrol('Parent',dT, 'Callback',@T_typicalCb, 'Position',[200 50 50 20], 'Style','edit', 'String',num2str(K2C(metaData.T_typical))); 
        uicontrol('Parent',dT, 'Callback',{@OKCb,dT}, 'Position',[100 20 20 20], 'String','OK', 'Style','pushbutton');

      case 'author'
        Datevec = datevec(datenum(date)); metaData.date_subm = Datevec(1:3);
        dA = dialog('Position',[150 150 500 150], 'Name','author dlg');
        uicontrol('Parent',dA, 'Position',[10 95 146 20], 'String','Name', 'Style','text');
        Hauthor  = uicontrol('Parent',dA, 'Callback',@authorCb, 'Position',[110 95 350 20], 'Style','edit', 'String',metaData.author); 
        uicontrol('Parent',dA, 'Position',[10 70 146 20], 'String','email', 'Style','text');
        Hemail   = uicontrol('Parent',dA, 'Callback',@emailCb, 'Position',[110 70 350 20], 'Style','edit', 'String',metaData.email); 
        uicontrol('Parent',dA, 'Position',[10 45 146 20], 'String','address', 'Style','text');
        Haddress = uicontrol('Parent',dA, 'Callback',@addressCb, 'Position',[110 45 350 20], 'Style','edit', 'String',metaData.address); 
        uicontrol('Parent',dA, 'Callback',{@OKCb,dA}, 'Position',[110 20 20 20], 'String','OK', 'Style','pushbutton');

      case 'curator'
        curList = {'Starrlight Augustine', 'Dina Lika', 'Nina Marn', 'Mike Kearney', 'Bas Kooijman'};
        emailList = {'starrlight.augustine@akvaplan.niva.no', 'lika@uoc.gr' ,'nina.marn@gmail.com', 'mrke@unimelb.edu.au', 'salm.kooijman@gmail.com'};
        i_cur =  listdlg('ListString',curList, 'SelectionMode','single', 'Name','curator dlg', 'ListSize',[140 80], 'InitialValue',1);
        metaData.curator = curList{i_cur}; metaData.email_cur = emailList{i_cur}; 
        Datevec = datevec(datenum(date)); metaData.date_acc = Datevec(1:3);
        
      case 'grp'
 
      case 'discussion'
        dD = dialog('Position',[150 150 950 550], 'Name','discussion dlg');
        uicontrol('Parent',dD, 'Callback',{@OKCb,dD}, 'Position',[30 500 20 20], 'String','OK');
        uicontrol('Parent',dD, 'Callback',{@addDiscussionCb,dD}, 'Position',[110 500 150 20], 'String','add discussion point', 'Style','pushbutton');
        uicontrol('Parent',dD, 'Position',[790 500 146 20], 'String','bibkey', 'Style','text');
        
        if ~isempty(metaData.discussion)
          fld = fieldnames(metaData.discussion); n = length(fld);
          for i = 1:n
            hight = 475 - i * 25;
            uicontrol('Parent',dD, 'Position',[10, hight, 146, 20], 'String',fld{i}, 'Style','text');
            HD(i)  = uicontrol('Parent',dD, 'Callback',{@discussionCb, i}, 'Position',[110, hight, 650, 20], 'Style','edit', 'String',metaData.discussion.(fld{i})); 
            HDb(i) = uicontrol('Parent',dD, 'Callback',{@discussionCb, i}, 'Position',[850, hight, 80, 20], 'Style','edit', 'String',metaData.bibkey.(fld{i})); 
          end
        end

      case 'facts'
        dF = dialog('Position',[150 150 950 550], 'Name','facts dlg');
        uicontrol('Parent',dF, 'Callback',{@OKCb,dF}, 'Position',[30 500 20 20], 'String','OK');
        HF = uicontrol('Parent',dF, 'Callback',{@addFactCb,dF}, 'Position',[110 500 150 20], 'String','add fact', 'Style','pushbutton');
        uicontrol('Parent',dF, 'Position',[790 500 146 20], 'String','bibkey', 'Style','text');
        
        if ~isempty(metaData.discussion)
          fld = fieldnames(metaData.facts); n = length(fld);
          for i = 1:n
            hight = 475 - i * 25;
            uicontrol('Parent',dF, 'Position',[10, hight, 146, 20], 'String',fld{i}, 'Style','text');
            HF(i)  = uicontrol('Parent',dF, 'Callback',{@factsCb, i}, 'Position',[110, hight, 650, 20], 'Style','edit', 'String',metaData.facts.(fld{i})); 
            HFb(i) = uicontrol('Parent',dF, 'Callback',{@factsCb, i}, 'Position',[850, hight, 80, 20], 'Style','edit', 'String',metaData.facts.(fld{i})); 
          end
        end

      case 'acknowledgment'
        dK = dialog('Position',[150 150 700 150], 'Name','acknowledgment dlg');
        uicontrol('Parent',dK, 'Position',[10 95 146 20], 'String','Text', 'Style','text');
        uicontrol('Parent',dK, 'Callback',{@OKCb,dK}, 'Position',[110 70 20 20], 'String','OK');
        HK = uicontrol('Parent',dK, 'Callback',@acknowledgmentCb, 'Position',[110 95 550 20], 'Style','edit', 'String',metaData.acknowledgment); 
        
      case 'links'
        dL = dialog('Position',[150 150 350 350],'Name','links dlg');
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
      
        id_links = {'id_CoL', 'id_EoL', 'id_Wiki', 'id_ADW', 'id_Taxo', 'id_WoRMS', ...                                                
         'id_molluscabase', 'id_fishbase', 'id_amphweb', 'id_ReptileDB', 'id_avibase', 'id_birdlife', 'id_MSW3', 'id_AnAge'};
     
        if isempty(select_id)
          select_id = true(14,1);
          for i = 1:14
            metaData.links.(id_links{i}) = [];
          end
        end
        
        select_id(7:14) = false; % selection vector for links
        if isfield(metaData.links, 'id_EoL') && isempty(metaData.links.id_EoL)
          metaData.links.id_EoL =  'some number (replace)';
        end
        if isfield(metaData.links, 'id_Wiki') && isempty(metaData.links.id_Wiki)
          metaData.links.id_Wiki =  [metaData.species, '? (replace)'];
        end
        if isfield(metaData.links, 'id_ADW') && isempty(metaData.links.id_ADW)
          metaData.links.id_ADW =  [metaData.species, '? (replace)'];
        end
        if isfield(metaData.links, 'id_Taxo') && isempty(metaData.links.id_Taxo)
          metaData.links.id_Taxo =  'some number (replace)';
        end
        if isfield(metaData.links, 'id_WoRMS') && isempty(metaData.links.id_WoRMS)
          metaData.links.id_WoRMS =  'some number (replace)';
        end

        if strcmp(metaData.class, 'Mollusca')
          select_id(7) = true;
          if isfield(metaData.links, 'id_molluscabase') && isempty(metaData.links.id_molluscabase)
            metaData.links.id_molluscabase = 'some number (replace)';
          end
        end
        if ismember(metaData.class, {'Cyclostomata', 'Chondrichthyes', 'Actinopterygii', 'Actinistia', 'Dipnoi'})
          select_id(8) = true;
          if isfield(metaData.links, 'id_fishbase') && isempty(metaData.links.id_fishbase)
            metaData.links.id_molluscabase = [strrepl(metaData.species,'_','-'), '? (replace)'];
          end
        end
        if strcmp(metaData.class, 'Amphibia')
          select_id(9) = true;
          if isfield(metaData.links, 'id_amphweb') && isempty(metaData.links.id_amphweb)
            metaData.links.id_amphweb = [strrepl(metaData.species,'_','+'), '? (replace)'];
          end
        end
        if strcmp(metaData.class, 'Reptilia')
          select_id(10) = true;
          nm = strspilt(metaData.species);
          if isfield(metaData.links, 'id_ReptileDB') && isempty(metaData.links.id_ReptileDB)
            metaData.links.id_ReptileDB = ['genus=',nm{1}, '&species=', nm{2}, '? (replace)'];
          end
        end
        if strcmp(metaData.class, 'Aves')
          select_id(11:12) = true;
          if isfield(metaData.links, 'id_avibase') && isempty(metaData.links.id_avibase)
            metaData.links.id_avibase = 'some code (replace)';
          end
          if isfield(metaData.links, 'id_birdlife') && isempty(metaData.links.id_birdlife)
            metaData.links.id_birdlife = 'some sci. & common names (replace)';
          end
        end
        if strcmp(metaData.class, 'Mammalia')
          select_id(13) = true;
          if isfield(metaData.links, 'id_MSW3') && isempty(metaData.links.id_MSW3)
            metaData.links.id_MSW3 = 'some number (replace)';
          end
        end
        if ismember(metaData.class, {'Aves', 'Mammalia'})
          select_id(14) = true;
          if isfield(metaData.links, 'id_AnAge') && isempty(metaData.links.id_AnAge)
            metaData.links.id_AnAge = [metaData.species, '? (replace)'];
          end
        end

        selId_links = id_links(select_id); selLinks = links(select_id); n_selLinks = length(selId_links);
        for i= 1:n_selLinks 
          if i>1
            web(selLinks{i},'-browser');
          end
          hight = 275 - i * 25;
          if ~isfield(metaData.links, selId_links{i})
            metaData.links.(selId_links{i}) = [];
          end
          uicontrol('Parent',dL, 'Position',[0, hight, 146, 20], 'String',selId_links{i}, 'Style','text');
          uicontrol('Parent',dL, 'Callback',{@OKCb,dL}, 'Position',[110 10 20 20], 'Style','pushbutton', 'String','OK'); 
          if i == 1
            uicontrol('Parent',dL, 'Position',[110, hight, 210, 20], 'Style','text', 'String',metaData.links.(selId_links{i})); 
          else
            HL(i)  = uicontrol('Parent',dL, 'Callback',{@linksCb,selId_links}, 'Position',[110, hight, 210, 20], 'Style','edit', 'String',metaData.links.(selId_links{i})); 
          end
        end
        
    case 'biblist'
        
    case '0varData' 
        
      code0 = { ...
          'ah',   'd', 1, 'age at hatch';          
          'ab',   'd', 1, 'age at birth';
          'tx',   'd', 1, 'time since birth at weaning';
          'tp',   'd', 1, 'time since birth at puberty';
          'tpm',  'd', 1, 'time since birth at puberty for males'; 
          'tR',   'd', 1, 'time since birth at first egg production';
          'am',   'd', 1, 'life span';

          'Lh',  'cm', 0, 'length at hatch';
          'Lb',  'cm', 0, 'length at birth'
          'Lp',  'cm', 0, 'length at puberty';
          'Li',  'cm', 0, 'ultimate length';
          'Lim', 'cm', 0, 'ultimate length for males';

          'Ww0',  'g', 0, 'initial wet weight';
          'Wwh',  'g', 0, 'wet weight at hatch';
          'Wwb',  'g', 0, 'wet weight at birth';
          'Wwp',  'g', 0, 'wet weight at puberty';
          'Wwpm', 'g', 0, 'wet weight at puberty for males';
          'Wwi',  'g', 0, 'ultimate wet weight';
          'Wwim', 'g', 0, 'ultimate wet weight for males';

          'Wdh',  'g', 0, 'dry weight at hatch';
          'Wdb',  'g', 0, 'dry weight at birth';
          'Wdpm', 'g', 0, 'dry weight at puberty for males';
          'Wdi',  'g', 0, 'ultimate dry weight';
          'Wdim', 'g', 0, 'ultimate dry weight for males';
          
          'E0',   'J', 0, 'initial energy content';

          'Ri', '#/d', 1, 'ultimate reproduction rate';
          }; 
        
      d0 = dialog('Position',[150 35 1000 620], 'Name','0-variate data dlg');
      uicontrol('Parent',d0, 'Position',[ 60 580  50 20], 'Callback',{@OKCb,d0}, 'Style','pushbutton', 'String','OK'); 
      uicontrol('Parent',d0, 'Position',[400 580 150 20], 'Callback',{@add0Cb,code0,d0}, 'String','add 0-var data', 'Style','pushbutton');
      uicontrol('Parent',d0, 'Position',[ 60 550  70 20], 'String','name', 'Style','text');
      uicontrol('Parent',d0, 'Position',[140 550  70 20], 'String','value', 'Style','text');
      uicontrol('Parent',d0, 'Position',[200 550  70 20], 'String','units', 'Style','text');
      uicontrol('Parent',d0, 'Position',[260 550  70 20], 'String','temp in C', 'Style','text');
      uicontrol('Parent',d0, 'Position',[390 550  70 20], 'String','label', 'Style','text');
      uicontrol('Parent',d0, 'Position',[550 550  70 20], 'String','bibkey', 'Style','text');
      uicontrol('Parent',d0, 'Position',[640 550  70 20], 'String','comment', 'Style','text');

      if ~isempty(data.data_0)
        fld = fieldnames(data.data_0); n = size(fld);
        for i = 1:n
          hight = 550 - i * 25; 
          uicontrol('Parent',d0,                                  'Position',[ 60, hight,  70, 20], 'Style','text', 'String',fld{i}); % name
          H0v(i) = uicontrol('Parent',d0,   'Callback',{@d0Cb,i}, 'Position',[150, hight,  70, 20], 'Style','edit', 'String',num2str(data.data_0.(fld{i}))); % value
          H0u(i) = uicontrol('Parent',d0,                         'Position',[230, hight,  30, 20], 'Style','text', 'String',txtData.units.(fld{i})); % units
          if isfield(auxData.temp, fld{i})
            H0T(i) = uicontrol('Parent',d0, 'Callback',{@d0Cb,i}, 'Position',[270, hight,  40, 20], 'Style','edit', 'String',num2str(K2C(auxData.temp.(fld{i})))); % temp(C)
          else
            H0T(i) = uicontrol('Parent',d0,                       'Position',[270, hight,  40, 20], 'Style','text', 'String','');         
          end
          H0l(i) = uicontrol('Parent',d0,                         'Position',[320, hight, 220, 20], 'Style','text', 'String',txtData.label.(fld{i})); % label
          H0b(i) = uicontrol('Parent',d0,   'Callback',{@d0Cb,i}, 'Position',[550, hight,  70, 20], 'Style','edit', 'String',cell2str(metaData.bibkey.(fld{i}))); % bibkey
          H0c(i) = uicontrol('Parent',d0,   'Callback',{@d0Cb,i}, 'Position',[650, hight, 300, 20], 'Style','edit', 'String',txtData.comment.(fld{i})); % comment
        end
      end

    case '1varData' 

      code1 = { ...
          'tL',    {'d','cm'}, 1, {'time','length'}, '';
          'tL_f'   {'d','cm'}, 1, {'time','length'}, 'Data for females'; 
          'tL_m'   {'d','cm'}, 1, {'time','length'}, 'Data for males'; 
          
          'tWw',   {'d', 'g'}, 1, {'time','wet weight'}, ''; 
          'tWw_m', {'d', 'g'}, 1, {'time','wet weight'}, 'Data for females'; 
          'tWw_f', {'d', 'g'}, 1, {'time','wet weight'}, 'Data for males';
          
          'tWd',   {'d', 'g'}, 1, {'time','dry weight'}, ''; 
          'tWd_m', {'d', 'g'}, 1, {'time','dry weight'}, 'Data for females'; 
          'tWd_f', {'d', 'g'}, 1, {'time','dry weight'}, 'Data for males';
          
          'LWw',   {'cm','g'}, 0, {'length','wet weight'}, '';
          'LWw_f', {'cm','g'}, 0, {'length','wet weight'}, 'Data for females';
          'LWw_m', {'cm','g'}, 0, {'length','wet weight'}, 'Data for males';
          
          'LWd',   {'cm','g'}, 0, {'length','dry weight'}, '';
          'LWd_f', {'cm','g'}, 0, {'length','dry weight'}, 'Data for females';
          'LWd_m', {'cm','g'}, 0, {'length','dry weight'}, 'Data for males';
          
          'LdL',   {'cm','cm/d'}, 1, {'length','change in length'}, '';
          'LdL_f', {'cm','cm/d'}, 1, {'length','change in length'}, 'Data for females';
          'LdL_m', {'cm','cm/d'}, 1, {'length','change in length'}, 'Data for males';
          }; 
        
      d1 = dialog('Position',[150 35 500 400], 'Name','1-variate data dlg');
      uicontrol('Parent',d1, 'Position',[ 10 380  50 20], 'Callback',{@OKCb,d1}, 'Style','pushbutton', 'String','OK'); 
      uicontrol('Parent',d1, 'Position',[150 380 150 20], 'Callback',{@add1Cb,code1,d1}, 'String','add 1-var data', 'Style','pushbutton');
      uicontrol('Parent',d1, 'Position',[ 10 350  60 20], 'String','name', 'Style','text');
      uicontrol('Parent',d1, 'Position',[100 350  90 20], 'String','x-label', 'Style','text');
      uicontrol('Parent',d1, 'Position',[200 350  90 20], 'String','y-label', 'Style','text');

      if ~isempty(data.data_1)
        fld = fieldnames(data.data_1); n = size(fld);
        for i = 1:n
          hight = 350 - i * 25; 
          uicontrol('Parent',d1,  'Position',[ 10, hight,  70, 20], 'Style','text', 'String',fld{i}); % name
          label = txtData.label.(fld{i}); 
          uicontrol('Parent',d1,  'Position',[100, hight,  100, 20], 'Style','text', 'String',label{1}); % x-label
          uicontrol('Parent',d1,  'Position',[200, hight,  100, 20], 'Style','text', 'String',label{2}); % y-label
          D1(i) = uicontrol('Parent',d1, 'Callback',{@D1Cb,fld{i},i}, 'Position',[380, hight,  70 20], 'Style','pushbutton', 'String','edit');
        end
      end

    case 'resume'
      list = cellstr(ls);
      list = list(contains(list,'results_'));
      if length(list) == 1
        load(list);
      elseif isempty(list)
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
      uicontrol('Parent',dP, 'Position',[130 60 100 20], 'Callback',{@OKCb,dP,0},  'String','stay in AmPgui', 'Style','pushbutton');
      uicontrol('Parent',dP, 'Position',[250 60 100 20], 'Callback',{@OKCb,dP,1}, 'String','stay in AmPeps', 'Style','pushbutton');
  end
end
  % color settings
  
  if exist('hs', 'var') && ~isempty(metaData.species)
    color.Hs = [0 .6 0]; set(hs, 'ForegroundColor', color.Hs);
  end

  if exist('he', 'var') && any([isempty(metaData.ecoCode.climate), isempty(metaData.ecoCode.ecozone), isempty(metaData.ecoCode.habitat), ...
    isempty(metaData.ecoCode.embryo), isempty(metaData.ecoCode.food), isempty(metaData.ecoCode.gender), isempty(metaData.ecoCode.reprod)])
    color.He = [1 0 0]; set(he, 'ForegroundColor', color.He);
  elseif exist('he', 'var')
    color.He = [0 0.6 0]; set(he, 'ForegroundColor', color.He);
  end

  if exist('h0', 'var') && ~isempty(data.data_0)
    color.H0 = [0 0.6 0]; set(h0, 'ForegroundColor', color.H0);
  end
  
  if exist('hT', 'var') && isfield(metaData, 'T_typical') && ~isempty(metaData.T_typical)
    color.HT = [0 .6 0]; set(hT, 'ForegroundColor', color.HT);
  end

  if exist('ha', 'var') && isfield(metaData, 'author') && ~isempty(metaData.author)
    color.Ha = [0 .6 0]; set(ha, 'ForegroundColor', color.Ha);
  end
  
  if exist('hc', 'var') && isfield(metaData, 'curator') && ~isempty(metaData.curator)
    color.Hc = [0 .6 0]; set(hc, 'ForegroundColor', color.Hc);
  end
 
  if exist('hk', 'var') && isfield(metaData, 'acknowledgment') && ~isempty(metaData.acknowledgment)
    color.Hk = [0 .6 0]; set(hk, 'ForegroundColor', color.Hk);
  end

  if exist('hl', 'var') && exist('select_id','var')
    color.Hl = [0 .6 0]; set(hl, 'ForegroundColor', color.Hl)
  end
  
end

%% callback functions
function speciesCb(~, ~, dS)  
  global metaData Hspecies select_id infoAmpgui
   
  Hf  = uicontrol('Parent',dS, 'Position',[50 110 140 20], 'Style','text', 'String',['family: ',metaData.family]);
  Ho  = uicontrol('Parent',dS, 'Position',[200 110 140 20], 'Style','text', 'String',['order: ',metaData.order]);
  Hc  = uicontrol('Parent',dS, 'Position',[350 110 140 20], 'Style','text', 'String',['class: ',metaData.class]);
  Hp  = uicontrol('Parent',dS, 'Position',[50 80 140 20], 'Style','text', 'String',['phylum: ',metaData.phylum]);
  Hcn = uicontrol('Parent',dS, 'Position',[200 80 240 20], 'Style','text', 'String',['common name: ',metaData.species_en]);
  strWarn = ''; Hw = uicontrol('Parent',dS, 'Position',[110 70 350 20], 'Style','text', 'String',strWarn);
  select_id = true(14,1);
  my_pet = strrep(get(Hspecies, 'string'), ' ', '_'); metaData.species = my_pet;
  [id_CoL, my_pet] = get_id_CoL(my_pet); 
  if isempty(id_CoL)
    web('http://www.catalogueoflife.org/col/','-browser');
    set(Hf,'String',''); set(Ho,'String',''); set(Hc,'String',''); set(Hp,'String',''); set(Hcn,'String','');
    set(Hw, 'String','species not recognized, search CoL');
  elseif ismember(my_pet,select)
    set(Hf,'String',''); set(Ho,'String',''); set(Hc,'String',''); set(Hp,'String',''); set(Hcn,'String','');
    uicontrol('Parent',dS, 'Position',[110 95 350 20], 'Style','text', 'String','species is already in AmP');
    uicontrol('Parent',dS, 'Position',[110 75 350 20], 'Style','text', 'String','close and proceed to post-editing phase of AmPeps');
    set(Hw, 'String', ''); infoAmpgui = 2;
  else
    [lin, rank] = lineage_CoL(my_pet);
    metaData.links.id_CoL = id_CoL;
    metaData.species_en = get_common_CoL(id_CoL); set(Hcn,'String',['common name: ',metaData.species_en]);
    nm = lin(ismember(rank, 'Family')); metaData.family = nm{1}; set(Hf,'String',['family: ',metaData.family]);
    nm = lin(ismember(rank, 'Order'));  metaData.order = nm{1};  set(Ho,'String',['order: ',metaData.order]);
    nm = lin(ismember(rank, 'Class'));  metaData.class = nm{1};  set(Hc,'String',['class: ',metaData.class]);
    nm = lin(ismember(rank, 'Phylum')); metaData.phylum = nm{1}; set(Hp,'String',['phylum: ',metaData.phylum]); 
  end
  uicontrol('Parent',dS, 'Position',[40 45 20 20], 'Callback',{@OKCb,dS}, 'Style','pushbutton', 'String','OK');
end

function climateCb(~, ~, Hclimate)  
  global metaData eco_types 
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

function ecozoneCb(~, ~, Hecozone)  
  global metaData eco_types
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
 
function habitatCb(~, ~, Hhabitat)  
  global metaData eco_types
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

function embryoCb(~, ~, Hembryo)  
  global metaData eco_types
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

function migrateCb(~, ~, Hmigrate)  
  global metaData eco_types
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

function foodCb(~, ~, Hfood)  
  global metaData eco_types
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

function genderCb(~, ~, Hgender)  
  global metaData eco_types
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

function reprodCb(~, ~, Hreprod)  
  global metaData eco_types
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

function T_typicalCb(~, ~)  
   global metaData HT
   metaData.T_typical = C2K(str2double(get(HT, 'string')));
end
 
 function authorCb(~, ~)  
   global metaData Hauthor
   metaData.author = str2cell(get(Hauthor, 'string'));
 end
 
 function emailCb(~, ~) 
   global metaData Hemail
   metaData.email = get(Hemail, 'string');
 end
 
 function addressCb(~, ~)  
   global metaData Haddress
   metaData.address = get(Haddress, 'string');
 end

 function addDiscussionCb(~, ~, dD)
  global metaData 
  n = 1 + length(fieldnames(metaData.discussion)); nm = ['D', num2str(n)]; 
  metaData.discussion.(nm) = []; metaData.bibkey.(nm) = [];
  delete(dD)
  AmPgui('discussion')
 end
  
 function discussionCb(~, ~, i)
   global metaData HD HDb 
   nm = ['D', num2str(i)];
   metaData.discussion.(nm) = get(HD(i), 'string');
   metaData.bibkey.(nm) = str2cell(get(HDb(i), 'string'));
 end
 
 function addFactCb(~, ~, dF)
   global metaData 
   n = 1 + length(fieldnames(metaData.facts)); nm = ['F', num2str(n)]; 
   metaData.facts.(nm) = []; metaData.bibkey.(nm) = [];
   delete(dF)
   AmPgui('facts')
 end

 function factsCb(~, ~, i)  
   global metaData HF HFb
   nm = ['F', num2str(i)];
   metaData.facts.(nm) = get(HF(i), 'string');
   metaData.bibkey.(nm) = str2cell(get(HFb(i), 'string'));
 end
 
 function acknowledgmentCb(~, ~)  
   global metaData HK
   metaData.acknowledgment = get(HK, 'string');
 end
 
function linksCb(~, ~, id_links)  
  global metaData HL
  fldnm = fieldnames(metaData.links); n_links = length(fldnm);
  for i = 2:n_links
    metaData.links.(id_links{i}) = get(HL(i), 'string');
  end
end

function add0Cb(~, ~, code0, d0)
   global data txtData auxData metaData
   n_code0 = size(code0,1); codeList0 = code0(:,1);
   for i = 1:n_code0
     codeList0{i} = [code0{i,1}, ': ', code0{i,4}];
   end
   i_code0 =  listdlg('ListString',codeList0, 'Name','0-var data dlg', 'ListSize',[300 400], 'InitialValue',n_code0);
   code0 = code0(i_code0,:); 
   if ~isempty(data.data_0)
     data_0 = fieldnames(data.data_0); 
     code0 = code0(~ismember(code0(:,1), data_0),:);
   end
   n = size(code0,1);
   for i = 1:n
     data.data_0.(code0{i,1}) = []; 
     txtData.units.(code0{i,1}) = code0{i,2};
     txtData.label.(code0{i,1}) = code0{i,4};
     txtData.comment.(code0{i,1}) = '';
     if code0{i,3}
       auxData.temp.(code0{i,1}) = [];
     end
     metaData.bibkey.(code0{i,1}) = [];
   end
   delete(d0);
   AmPgui('0varData');
end 

% function d0NmCb(~, ~, i)
%    global data auxData txtData metaData H0n
%    fld = fieldnames(data.data_0); n = length(fld);
%    nm = get(H0n(i), 'string'); 
%    data.data_0 = renameStructField(data.data_0, fld{i}, nm); 
%    
%    if isfield(txtData.units, fld{i})
%      txtData.units = renameStructField(txtData.units, fld{i}, nm);  
%      txtData.label = renameStructField(txtData.label, fld{i}, nm);  
%    end
%    if isfield(auxData.temp, fld{i})
%      auxData.temp = renameStructField(auxData.temp, fld{i}, nm);  
%    end 
%    if isfield(metaData.bibkey, fld{i})
%      metaData.bibkey = renameStructField(metaData.bibkey, fld{i}, nm);  
%    end 
% 
% end

function d0Cb(~, ~, i)  
   global data auxData txtData metaData H0v H0T H0b H0c
   fld = fieldnames(data.data_0);
   data.data_0.(fld{i}) = str2double(get(H0v(i), 'string'));
   if isfield(auxData.temp, fld{i})
     auxData.temp.(fld{i}) = C2K(str2double(get(H0T(i), 'string')));
     txtData.units.temp = 'K';
     txtData.label.temp = 'temperature';
   end
   metaData.bibkey.(fld{i}) = str2cell(get(H0b(i), 'string'));
   txtData.comment.(fld{i}) = str2cell(get(H0c(i), 'string'));
end

function add1Cb(~, ~, code1, d1)
   global data txtData auxData metaData
   n_code1 = size(code1,1); codeList1 = code1(:,1);
   for i = 1:n_code1
     codeList1{i} = [code1{i,1}, ': ', cell2str(code1{i,4})];
   end
   i_code1 =  listdlg('ListString',codeList1, 'Name','1-var data dlg', 'ListSize',[300 350], 'InitialValue',n_code1);
   code1 = code1(i_code1,:); 
   if ~isempty(data.data_1)
     data_1 = fieldnames(data.data_1); 
     code1 = code1(~ismember(code1(:,1), data_1),:);
   end
   n = size(code1,1);
   for i = 1:n
     data.data_1.(code1{i,1}) = []; 
     txtData.units.(code1{i,1}) = code1{i,2};
     txtData.label.(code1{i,1}) = code1{i,4};
     txtData.comment.(code1{i,1}) = [];
     if code1{i,3}
       auxData.temp.(code1{i,1}) = [];
     end
     metaData.bibkey.(code1{i,1}) = [];
   end 
   delete(d1);
   AmPgui('1varData');
end 

function D1Cb(~, ~, fld, i)  
   global data auxData txtData metaData D1 H1v H1T H1b H1c
   D1(i) = dialog('Position',[150 35 475 500], 'Name','1-variate data set dlg');
   units = txtData.units.(fld); label = txtData.label.(fld); keyB = true;
   uicontrol('Parent',D1(i), 'Position',[ 20 480  50 20], 'Callback',{@OKCb,D1(i)}, 'Style','pushbutton', 'String','OK'); 
   uicontrol('Parent',D1(i), 'Position',[ 80 480 150 20], 'String',['name: ', fld], 'Style','text');
   uicontrol('Parent',D1(i), 'Position',[225 480 100 20], 'String',['units: ', units{1},' , ',units{2}], 'Style','text');
   H1v(i) = uicontrol('Parent',D1(i), 'Min',0, 'Max',300, 'Position',[20 20  200 450], 'Callback',{@d1Cb,fld,i}, 'String',num2str(data.data_1.(fld)), 'Style','edit');
   uicontrol('Parent',D1(i), 'Position',[225 400  100 20], 'String','x-label:', 'Style','text');
   uicontrol('Parent',D1(i), 'Position',[245 375  200 20], 'String',label{1}, 'Style','text');
   uicontrol('Parent',D1(i), 'Position',[225 350  100 20], 'String','y-label:', 'Style','text');
   uicontrol('Parent',D1(i), 'Position',[245 325  200 20], 'String',label{2}, 'Style','text');
   if isfield(auxData.temp,(fld))
     uicontrol('Parent',D1(i), 'Position',[225 300 100 20], 'String','temperature in C', 'Style','text');
     H1T(i) = uicontrol('Parent',D1(i), 'Position',[325 300  50 20], 'Callback',{@d1TCb,fld,i}, 'String',auxData.temp.(fld), 'Style','edit');
   end
   uicontrol('Parent',D1(i), 'Position',[225 275  100 20], 'String','bibkey', 'Style','text');
   H1b(i) = uicontrol('Parent',D1(i), 'Position',[300 275  100 20], 'Callback',{@d1bCb,fld,i}, 'String',metaData.bibkey.(fld), 'Style','edit');
   uicontrol('Parent',D1(i), 'Position',[225 250  70 20], 'String','comment', 'Style','text');
   H1c(i) = uicontrol('Parent',D1(i), 'Position',[225 225  240 20], 'Callback',{@d1cCb,fld,i}, 'String',txtData.comment.(fld), 'Style','edit');
end

function d1Cb(~, ~, fld, i)
  global data H1v
  persistent keyB
  if isempty(keyB) || keyB
    keyboard
    keyB = false;
  else
    data.data_1.(fld) = str2num(get(H1v(i), 'string'));
    keyB = true;
  end
end

  
function d1TCb(~, ~, fld, i)
  global auxData H1T 
  auxData.temp.(fld) = get(H1T(i), 'string');
end  

function d1bCb(~, ~, fld, i)
  global metaData H1b 
  metaData.bibkey.(fld) = get(H1b(i), 'string');
end  

function d1cCb(~, ~, fld, i)
  global metaData H1c
  metaData.comment.(fld) = get(H1c(i), 'string');
end  

function OKCb(~, ~, H, i) 
  global infoAmPgui
  if exist('i','var')
    infoAmPgui = i;
  end
  delete(H);
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

function [ch, tim] = getkey(N,nonascii)

% GETKEY - get a keypress
%   CH = GETKEY waits for a single keypress and returns the ASCII code. It
%   accepts all ascii characters, including backspace (8), space (32),
%   enter (13), etc, that can be typed on the keyboard.
%   Non-ascii keys (ctrl, alt, ..) return a NaN. CH is a double.
%
%   CH = GETKEY(N) waits for N keypresses and returns their ASCII codes.
%   GETKEY(1) is the same as GETKEY without arguments.
%
%   GETKEY('non-ascii') or GETKEY(N,'non-ascii') uses non-documented
%   matlab features to return a string describing the key pressed.
%   In this way keys like ctrl, alt, tab etc. can also distinguished.
%   The return is a string (when N = 1) or a cell array of strings.
%
%   [CH,T] = GETKEY(...) also returns the time between the start of the
%   function and each keypress. This is, however, not that accurate.
%
%   This function is kind of a workaround for getch in C. It uses a modal,
%   but non-visible window, which does show up in the taskbar.
%   C-language keywords: KBHIT, KEYPRESS, GETKEY, GETCH
%
%   Examples:
%
%    fprintf('\nPress any key: ') ;
%    ch = getkey ;
%    fprintf('%c\n',ch) ;
%
%    fprintf('\nPress the Ctrl-key within 3 presses: ') ;
%    ch = getkey(3,'non-ascii')
%    if ismemmber('control', ch),
%      fprintf('OK\n') ;
%    else
%      fprintf(' ... wrong keys ...\n') ;
%    end
%
%  See also INPUT, UIWAIT
%           GETKEYWAIT (File Exchange)

% for Matlab 6.5 and higher
% version 2.0 (jun 2012)
% author : Jos van der Geest
% email  : jos@jasen.nl
%
% History
% 1.0 2005 - creation
% 1.1 dec 2006 - modified lay-out and help
% 1.2 apr 2009 - tested for more recent MatLab releases
% 1.3 jan 2012 - modified a few properties, included check is figure still
%            exists (after comment on FEX by Andrew).
% 2.0 jun 2012 - added functionality to accept multiple key presses

t00 = tic ; % start time of this function

% check the input arguments
error(nargchk(0,2,nargin))
switch nargin
    case 0
        nonascii = '' ;
        N = 1 ;
    case 1
        if ischar(N),
            nonascii = N ;
            N = 1 ;
        else
            nonascii = '' ;
        end
end

if numel(N) ~= 1 || ~isnumeric(N) || N < 1 || fix(N) ~= N
    error('N should be a positive integer scalar.') ;
end

% Determine the callback string to use
if strcmpi(nonascii,'non-ascii'),
    % non-ascii characters are accepted
    nonascii = true ;
    callstr = 'set(gcbf,''Userdata'',get(gcbf,''Currentkey'')) ; uiresume ' ;
elseif isempty(nonascii)
    nonascii = false ;
    % only standard ascii characters are accepted
    callstr = 'set(gcbf,''Userdata'',double(get(gcbf,''Currentcharacter''))) ; uiresume ' ;
else
    error('String argument should be the string ''non-ascii''') ;
end

% Set up the figure
% May be the position property  should be individually tweaked to avoid visibility
fh = figure(...
    'name','Press a key', ...
    'keypressfcn',callstr, ...
    'windowstyle','modal',...
    'numbertitle','off', ...
    'position',[0 0  1 1],...
    'userdata','timeout') ;
try
    ch = cell(1,N) ;
    tim = zeros(1,N) ;
    
    % loop to get N keypresses
    for k=1:N
        % Wait for something to happen, usually a key press so uiresume is
        % executed
        uiwait ;
        tim(k) = toc(t00) ; % get the time of the key press
        ch{k} = get(fh,'Userdata') ;  % and the key itself
        if isempty(ch{k}),
            if nonascii
                ch{k} = NaN ;
            else
                ch{k} = '' ;
            end
        end
    end
    if ~nonascii
        ch = [ch{:}] ;
    else
        if N==1
            ch = ch{1} ; % return as a string
        end
        % return as a cell array of strings
    end
 catch
    % Something went wrong, return empty matrices.
    ch = [] ;
    tim = [] ;
end

% clean up the figure, if it still exists
if ishandle(fh)
    delete(fh) ;
end
end