%% AmPgui
% a GUI to create 4 data-structures
%%
function AmPgui(action)
% created 2020/06/05 by  Bas Kooijman, modified 2020/08/14, 2021/08/03, 2021/08/21

%% Syntax
% <../AmPgui.m *AmPgui*>

%% Description
% It writes 4 data-structures from scratch
%
% * data: structure with data
% * auxData: structure with auxiliary data 
% * metaData: structure with metaData 
% * txtData: structure with text for data 
%
% Input: no explicit input (facultative input is set by the function itself in multiple calls) 
%
% Output: no explicit output, but global exit-flag infoAmPgui is set with
%
%   - 0, species is in AmP, skip writing 4 source files
%   - 1, writing 4 source files with species in Taxo
%   - 2, writing 4 source files with species not in Taxo, but genus is in AmP
%   - 3, writing 4 source files with species not in Taxo, genus is not in AmP, but family is
%   - 4, writing 4 source files with species not in Taxo, family is not in AmP, but order is
%   - 5, writing 4 source files with species not in Taxo, order is not in AmP, but class is
%   - 6, writing 4 source files with species not in Taxo, class is not in AmP, but phylum is
%   - 7, writing 4 source files with species not in Taxo, phylum is not in AmP

%% Remarks
%
% * Set metaData on global before use of this function.
% * Files will be saved in your local directory, which should not contain results_my_pet.mat files, other than written by this function 
% * Use the cd command to the dir of your choice BEFORE running this function to save files in the desired place.
% * All weights are set at default values in the resulting file; 
% * The first call to "species" in the gui uses automatised completions,
% subsequent calls use handfilling;
% * This function is called in AmPeps
% * Font colors in main AmPgui mean:
%
%   - red: editing required
%   - green: editing not necessary
%   - black: editing facultative
% 
% Notice that font colors only represent internal consistency, irrespective of content.
% txtData.bibkey.data_id specifies the bibkey for dataset data_id; metaData.biblist.bibkey specifies the bibitem for bibkey.
% metaData.bibkey.Fi and Ci specify the bibkeys for facts Fi and discussion Di

persistent dmydata hspecies hecoCode hT_typical hauthor hcurator hgrp hdiscussion hfacts hacknowledgment hlinks hbiblist hdata_0 hCOMPLETE   
global data auxData metaData txtData select_id id_links eco_types color infoAmPgui list_spec handfilled
global dspecies Hspecies Hfamily Horder Hclass Hphylum Hcommon Hwarning HwarningOK HCOMPLETE Hwait
global Hauthor Hemail Haddress HK HD HDb HF HFb HT Hlinks H0v H0T H0b H0c D1 Hb ddata_0 Db 
global Hclimate Hecozone Hhabitat Hembryo Hmigrate Hfood Hgender Hreprod

%UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize'); % 8
set(0, 'DefaultUIControlFontSize', 9);
%set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);


if nargin == 0 % initiate structures and create the GUI

  % initiation
  handfilled = false; % taxonomy is not handfilled; links set automatically

  if ~isfield(data, 'data_0'); data.data_0 = []; end   
  if ~isfield(data, 'data_1'); data.data_1 = []; end  
  if ~isfield(auxData, 'temp'); auxData.temp = []; end
  if ~isfield(txtData, 'units'); txtData.units = []; txtData.units.temp = []; end
  if ~isfield(txtData, 'label'); txtData.label = []; txtData.label.temp = []; end
  if ~isfield(txtData, 'bibkey'); txtData.bibkey = []; end % for data
  if ~isfield(metaData, 'species'); metaData.species = ''; end   
  if ~isfield(metaData, 'species_en'); metaData.species_en = ''; end  
  if ~isfield(metaData, 'family'); metaData.family = ''; end   
  if ~isfield(metaData, 'order'); metaData.order = ''; end  
  if ~isfield(metaData, 'class'); metaData.class = ''; end  
  if ~isfield(metaData, 'phylum'); metaData.phylum = ''; end  
  ecoCode = {'climate', 'ecozone', 'habitat', 'embryo', 'migrate', 'food', 'gender', 'reprod'};
  if ~isfield(metaData, 'ecoCode'); metaData.ecoCode = []; n = length(ecoCode);
    for i=1:n
      metaData.ecoCode.(ecoCode{i}) = [];
    end
  end
  if ~isfield(metaData, 'T_typical'); metaData.T_typical = []; end
  if ~isfield(metaData, 'data_0'); metaData.data_0 = {}; end
  if ~isfield(metaData, 'data_1'); metaData.data_1 = {}; end
  if ~isfield(metaData, 'bibkey'); metaData.bibkey = []; end % for discussion, facts
  id_links = {'id_CoL', 'id_ITIS', 'id_EoL', 'id_Wiki', 'id_ADW', 'id_Taxo', 'id_WoRMS', ...                                                
    'id_molluscabase', 'id_scorpion', 'id_spider', 'id_collembola', 'id_orthoptera', 'id_phasmida', 'id_aphid', 'id_diptera', 'id_lepidoptera', ... 
    'id_fishbase', 'id_amphweb', 'id_ReptileDB', 'id_avibase', 'id_birdlife', 'id_MSW3', 'id_AnAge'};
  if ~isfield(metaData, 'links'); metaData.links = []; n_id = length(id_links);
    for i=1:n_id; metaData.links.(id_links{i}) = ''; end
    select_id = true(1,n_id);
  end

  if ~isfield(metaData, 'author'); metaData.author = []; end
  if ~isfield(metaData, 'email'); metaData.email = []; end
  if ~isfield(metaData, 'address'); metaData.address = []; end
  if ~isfield(metaData, 'curator'); metaData.curator = []; end
  if ~isfield(metaData, 'COMPLETE'); metaData.COMPLETE = []; end
  if ~isfield(metaData, 'discussion'); metaData.discussion = []; end
  if ~isfield(metaData, 'facts'); metaData.facts = []; end
  if ~isfield(metaData, 'acknowledgment'); metaData.acknowledgment = []; end
  if ~isfield(metaData, 'biblist'); metaData.biblist = []; end
  if isempty(eco_types); get_eco_types; end
  if isempty(list_spec); list_spec = select; end % lists of taxon names in AmP

  if isempty(color)
    color.species = [1 0 0]; color.ecoCode = [1 0 0];    color.T_typical = [1 0 0];  color.author = [1 0 0];         color.curator = [1 0 0];
    color.grp = [0 0 0];     color.discussion = [0 0 0]; color.facts = [0 0 0];      color.acknowledgment = [0 0 0]; color.links = [1 0 0];
    color.biblist = [1 0 0]; color.data_0 = [1 0 0];     color.discussion = [0 0 0]; color.facts = [0 0 0];          color.COMPLETE = [1 0 0];
  end

  if isempty(infoAmPgui)
    infoAmPgui = ~isempty(metaData.species); % AmPgui exit flag
  end

  % setup gui
  dmydata = dialog('Position',[30 550 250 275], 'Name','AmPgui');
  hspecies  = uicontrol('Parent',dmydata, 'Callback','AmPgui species',        'Position',[10 230 100 20], 'String','species',        'Style','pushbutton');
  hecoCode  = uicontrol('Parent',dmydata, 'Callback','AmPgui ecoCode',        'Position',[10 205 100 20], 'String','ecoCode',        'Style','pushbutton');
  hT_typical= uicontrol('Parent',dmydata, 'Callback','AmPgui T_typical',      'Position',[10 180 100 20], 'String','T_typical',      'Style','pushbutton');

  hauthor   = uicontrol('Parent',dmydata, 'Callback','AmPgui author',         'Position',[10 135 100 20], 'String','author',         'Style','pushbutton');
  hcurator  = uicontrol('Parent',dmydata, 'Callback','AmPgui curator',        'Position',[10 110 100 20], 'String','curator',        'Style','pushbutton');

  hgrp      = uicontrol('Parent',dmydata, 'Callback','AmPgui grp',            'Position',[10  65 100 20], 'String','group plots',    'Style','pushbutton');
  hdiscussion  = uicontrol('Parent',dmydata, 'Callback','AmPgui discussion',  'Position',[10  40 100 20], 'String','discussion',     'Style','pushbutton');
  hfacts    = uicontrol('Parent',dmydata, 'Callback','AmPgui facts',          'Position',[10  15 100 20], 'String','facts',          'Style','pushbutton');

  hlinks    = uicontrol('Parent',dmydata, 'Callback','AmPgui links',          'Position',[130 230 100 20], 'String','links',          'Style','pushbutton');
  hbiblist  = uicontrol('Parent',dmydata, 'Callback','AmPgui biblist',        'Position',[130 205 100 20], 'String','biblist',        'Style','pushbutton');
  hacknowledgment = uicontrol('Parent',dmydata, 'Callback','AmPgui acknowledgment', 'Position',[130 180 100 20], 'String','acknowledgment', 'Style','pushbutton');
  
  hdata_0   = uicontrol('Parent',dmydata, 'Callback','AmPgui data_0',         'Position',[130 135 100 20], 'String','0-var data',     'Style','pushbutton');
              uicontrol('Parent',dmydata, 'Callback','AmPgui data_1',         'Position',[130 110 100 20], 'String','1-var data',     'Style','pushbutton');
  
  hCOMPLETE = uicontrol('Parent',dmydata, 'Callback','AmPgui COMPLETE',       'Position',[130  65 100 20], 'String','COMPLETE',       'Style','pushbutton');
              uicontrol('Parent',dmydata, 'Callback','AmPgui resume',         'Position',[130  40 100 20], 'String','resume',         'Style','pushbutton');
              uicontrol('Parent',dmydata, 'Callback','AmPgui pause',          'Position',[130  15 100 20], 'String','pause/save',     'Style','pushbutton');
        
  % set default colors
  set(hspecies, 'ForegroundColor', color.species);       set(hecoCode, 'ForegroundColor', color.ecoCode); 
  set(hT_typical, 'ForegroundColor', color.T_typical);   set(hauthor, 'ForegroundColor', color.author); 
  set(hcurator, 'ForegroundColor', color.curator);       set(hgrp, 'ForegroundColor', color.grp); 
  set(hdiscussion, 'ForegroundColor', color.discussion); set(hfacts, 'ForegroundColor', color.facts); 
  set(hlinks, 'ForegroundColor', color.links);           set(hbiblist, 'ForegroundColor', color.biblist);
  set(hacknowledgment, 'ForegroundColor', color.acknowledgment); set(hdata_0, 'ForegroundColor', color.data_0);
    
else % fill fields
  switch(action)
      case 'species'
        dspecies = dialog('Position',[150 150 600 150], 'Name','species dlg');
        Warning = ''; Hwarning = uicontrol('Parent',dspecies, 'Position',[110 60 350 20], 'Style','text', 'String',Warning);
        WarningOK = ''; HwarningOK = uicontrol('Parent',dspecies, 'Position',[110 40 350 20], 'Style','text', 'String',WarningOK);
        Hfamily  = uicontrol('Parent',dspecies, 'Position',[ 50 110 150 20], 'Style','text', 'String',['family: ',metaData.family]);
        Horder   = uicontrol('Parent',dspecies, 'Position',[200 110 150 20], 'Style','text', 'String',['order: ', metaData.order]);
        Hclass   = uicontrol('Parent',dspecies, 'Position',[350 110 150 20], 'Style','text', 'String',['class: ', metaData.class]);
        Hphylum  = uicontrol('Parent',dspecies, 'Position',[ 50  80 150 20], 'Style','text', 'String',['phylum: ',metaData.phylum]);
        Hcommon  = uicontrol('Parent',dspecies, 'Position',[200  80 240 20], 'Style','text', 'String',['common name: ',metaData.species_en]);
        if ~handfilled
          Hspecies = uicontrol('Parent',dspecies, 'Callback',{@speciesCb,dspecies}, 'Position',[110 15 350 20], 'Style','edit', 'String',metaData.species); 
        else
          set(Hfamily, 'String',''); set(Horder, 'String',''); set(Hclass, 'String',''); set(Hphylum, 'String',''); set(Hcommon, 'String',''); 
          Hspecies = uicontrol('Parent',dspecies, 'Callback',{@OKspeciesCb,dspecies}, 'Position',[110 15 350 20], 'Style','edit', 'String',metaData.species); 
        end
        
      case 'ecoCode'
        decoCode = dialog('Position',[550 250 500 270], 'Name','ecoCode dlg');
        
        % climate
        uicontrol('Parent',decoCode, 'Position',[10 230 146 20], 'String','climate', 'Style','text');
        Hclimate = uicontrol('Parent',decoCode, 'Position',[110 230 250 20], 'String',cell2str(metaData.ecoCode.climate)); 
        uicontrol('Parent',decoCode, 'Callback',{@climateCb,Hclimate}, 'Position',[370 230 50 20], 'Style','pushbutton', 'String','edit'); 
        
        % ecozone
        uicontrol('Parent',decoCode, 'Position',[10 200 146 20], 'String','ecozone', 'Style','text');
        Hecozone = uicontrol('Parent',decoCode, 'Position',[110 200 250 20], 'String',cell2str(metaData.ecoCode.ecozone));
        uicontrol('Parent',decoCode, 'Callback',{@ecozoneCb,Hecozone}, 'Position',[370 200 50 20], 'Style','pushbutton', 'String','edit'); 

        % habitat
        uicontrol('Parent',decoCode, 'Position',[10 170 146 20], 'String','habitat', 'Style','text');
        Hhabitat = uicontrol('Parent',decoCode, 'Position',[110 170 250 20], 'String',cell2str(metaData.ecoCode.habitat)); 
        uicontrol('Parent',decoCode, 'Callback',{@habitatCb,Hhabitat}, 'Position',[370 170 50 20], 'Style','pushbutton', 'String','edit'); 

        % embryo
        uicontrol('Parent',decoCode, 'Position',[10 140 146 20], 'String','embryo', 'Style','text');
        Hembryo = uicontrol('Parent',decoCode, 'Position',[110 140 250 20], 'String',cell2str(metaData.ecoCode.embryo));
        uicontrol('Parent',decoCode, 'Callback',{@embryoCb,Hembryo}, 'Position',[370 140 50 20], 'Style','pushbutton', 'String','edit'); 

        % migrate
        uicontrol('Parent',decoCode, 'Position',[10 110 146 20], 'String','migrate', 'Style','text');
        Hmigrate = uicontrol('Parent',decoCode, 'Position',[110 110 250 20], 'String',cell2str(metaData.ecoCode.migrate)); 
        uicontrol('Parent',decoCode, 'Callback',{@migrateCb,Hmigrate}, 'Position',[370 110 50 20], 'Style','pushbutton', 'String','edit'); 

        % food
        uicontrol('Parent',decoCode, 'Position',[10 80 146 20], 'String','food', 'Style','text');
        Hfood = uicontrol('Parent',decoCode, 'Position',[110 80 250 20], 'String',cell2str(metaData.ecoCode.food)); 
        uicontrol('Parent',decoCode, 'Callback',{@foodCb,Hfood}, 'Position',[370 80 50 20], 'Style','pushbutton', 'String','edit'); 

        % gender
        uicontrol('Parent',decoCode, 'Position',[10 50 146 20], 'String','gender', 'Style','text');
        Hgender = uicontrol('Parent',decoCode, 'Position',[110 50 250 20], 'String',cell2str(metaData.ecoCode.gender)); 
        uicontrol('Parent',decoCode, 'Callback',{@genderCb,Hgender}, 'Position',[370 50 50 20], 'Style','pushbutton', 'String','edit'); 

        % reprod
        uicontrol('Parent',decoCode, 'Position',[10 20 146 20], 'String','reprod', 'Style','text');
        Hreprod = uicontrol('Parent',decoCode, 'Position',[110 20 250 20], 'String',cell2str(metaData.ecoCode.reprod)); 
        uicontrol('Parent',decoCode, 'Callback',{@reprodCb,Hreprod}, 'Position',[370 20 50 20], 'Style','pushbutton', 'String','edit'); 
        uicontrol('Parent',decoCode, 'Callback',{@OKCb,decoCode}, 'Position',[430 20 50 20], 'Style','pushbutton', 'String','OK'); 
        
      case 'T_typical'
        dT_typical = dialog('Position',[300 250 300 100], 'Name','T_typical dlg');
        uicontrol('Parent',dT_typical, 'Position',[10 50 200 20], 'String','Typical body temperature in C', 'Style','text');
        HT = uicontrol('Parent',dT_typical, 'Callback',@T_typicalCb, 'Position',[200 50 50 20], 'Style','edit', 'String',num2str(K2C(metaData.T_typical))); 
        uicontrol('Parent',dT_typical, 'Callback',{@OKCb,dT_typical}, 'Position',[100 20 20 20], 'String','OK', 'Style','pushbutton');

      case 'author'
        Datevec = datevec(datenum(date)); metaData.date_subm = Datevec(1:3);
        dauthor = dialog('Position',[150 150 500 150], 'Name','author dlg');
        uicontrol('Parent',dauthor, 'Position',[10 95 146 20], 'String','Name', 'Style','text');
        Hauthor  = uicontrol('Parent',dauthor, 'Callback',@authorCb, 'Position',[110 95 350 20], 'Style','edit', 'String',metaData.author); 
        uicontrol('Parent',dauthor, 'Position',[10 70 146 20], 'String','email', 'Style','text');
        Hemail   = uicontrol('Parent',dauthor, 'Callback',@emailCb, 'Position',[110 70 350 20], 'Style','edit', 'String',metaData.email); 
        uicontrol('Parent',dauthor, 'Position',[10 45 146 20], 'String','address', 'Style','text');
        Haddress = uicontrol('Parent',dauthor, 'Callback',@addressCb, 'Position',[110 45 350 20], 'Style','edit', 'String',metaData.address); 
        uicontrol('Parent',dauthor, 'Callback',{@OKCb,dauthor}, 'Position',[110 20 20 20], 'String','OK', 'Style','pushbutton');

      case 'curator'         
        curList = {'Starrlight Augustine', 'Mike Kearney', 'Bas Kooijman', 'Romain Lavaud', 'Dina Lika', 'Nina Marn', 'Goncalo Marques', 'Laure Peçquerie','Tan Tjui-Yeuw'};
        emailList = {'starrlight@ecotechnics.edu', 'mrke@unimelb.edu.au', 'salm.kooijman@gmail.com', 'RLavaud@agcenter.lsu.edu', 'lika@uoc.gr' ,'nina.marn@gmail.com', 'goncalo.marques@tecnico.ulisboa.pt', 'laure.pecquerie@ird.fr', 'tan.tjuiyeuw@wur.nl'};
        if ~isempty(metaData.curator)
          i = 1:5; i = i(ismember(curList, metaData.curator));
        else
          i = 1;
        end
        i_cur =  listdlg('ListString',curList, 'SelectionMode','single', 'Name','curator dlg', 'ListSize',[140 80], 'InitialValue',i);
        metaData.curator = curList{i_cur}; metaData.email_cur = emailList{i_cur}; 
        Datevec = datevec(datenum(date)); metaData.date_acc = Datevec(1:3);
        
      case 'grp'
        sets = {{'tL_f', 'tL_m'}, {'tWw_f', 'tWw_m'}, {'tWd_f', 'tLWd_m'}, {'LWw_f', 'LWw_m'}, ...
            {'LWd_f', 'tWd_m'}, {'LdL_f', 'LdL_m'}}; 
        comment = {'Data for females, males', 'Data for females, males', 'Data for females, males', 'Data for females, males', ...
            'Data for females, males', 'Data for females, males'};
        
        n_sets = length(sets); setsList = sets; sel_sets = false(n_sets,1);
        for i = 1:n_sets
          setsList{1} = cell2str(sets{i});
          seti = sets{i};
          if isfield(data.data_1, seti{1}) && isfield(data.data_1, seti{2})
            sel_sets(1) = true;
          end
        end
                
        dgrp = dialog('Position',[150 150 350 250], 'Name','grp dlg');
        uicontrol('Parent',dgrp, 'Position',[20 210 30 20], 'Callback',{@OKCb,dgrp}, 'String','OK');
        
        if isempty(data.data_1)
          uicontrol('Parent',dgrp, 'Position',[70 210 250 20], 'String','no 1-variate data found');
          
        elseif any(sel_sets)
          setsList = setsList(sel_sets);
          i_sets =  listdlg('ListString',setsList,  'Name','grp dlg', 'ListSize',[200 80], 'InitialValue',1);
          n_sets = length(i_sets);
          for i=1:n_sets
            hight = 180 - i * 25;
            uicontrol('Parent',dgrp, 'Position',[ 20 hight 150 20], 'String',['set', num2str(i), ': ', setsList{i}]);  
            uicontrol('Parent',dgrp, 'Position',[170 hight 175 20], 'String',['comment', num2str(i), ': ', comment{i}]); 
          end
          metaData.grp.sets = sets(sel_sets);
          metaData.grp.comment = comment(sel_sets);

        else
          uicontrol('Parent',dgrp, 'Position',[70 210 250 20], 'String','no 1-variate data found that can be grouped');
        end
 
      case 'discussion'
        ddiscussion = dialog('Position',[150 150 1000 550], 'Name','discussion dlg');
        uicontrol('Parent',ddiscussion, 'Callback',{@OKCb,ddiscussion}, 'Position',[30 500 20 20], 'String','OK');
        uicontrol('Parent',ddiscussion, 'Callback',{@addDiscussionCb,ddiscussion}, 'Position',[110 500 150 20], 'String','add discussion point', 'Style','pushbutton');
        uicontrol('Parent',ddiscussion, 'Position',[790 500 146 20], 'String','bibkey', 'Style','text');
        
        if ~isempty(metaData.discussion)
          fld = fields(metaData.discussion); n = length(fld);
          for i = 1:n
            hight = 475 - i * 25;
            uicontrol('Parent',ddiscussion, 'Position',[10, hight, 146, 20], 'String',fld{i}, 'Style','text');
            HD(i)  = uicontrol('Parent',ddiscussion, 'Callback',{@discussionCb, i}, 'Position',[110, hight, 650, 20], 'Style','edit', 'String',metaData.discussion.(fld{i}));
            if ~isfield(metaData.bibkey, fld{i})
              metaData.bibkey.(fld{i}) = [];
            end
            HDb(i) = uicontrol('Parent',ddiscussion, 'Callback',{@discussionCb, i}, 'Position',[800, hight, 80, 20], 'Style','edit', 'String',metaData.bibkey.(fld{i})); 
            uicontrol('Parent',ddiscussion, 'Callback',{@deleteCb,'discussion',i,ddiscussion}, 'Position',[920, hight, 20, 20], 'String','X', 'ForegroundColor',[1 0 0], 'FontWeight','bold');
          end
        end

      case 'facts'
        dfacts = dialog('Position',[150 150 1000 550], 'Name','facts dlg');
        uicontrol('Parent',dfacts, 'Callback',{@OKCb,dfacts}, 'Position',[30 500 20 20], 'String','OK');
        HF = uicontrol('Parent',dfacts, 'Callback',{@addFactCb,dfacts}, 'Position',[110 500 150 20], 'String','add fact', 'Style','pushbutton');
        uicontrol('Parent',dfacts, 'Position',[760 500 146 20], 'String','bibkey', 'Style','text');
        
        if ~isempty(metaData.facts)
          fld = fields(metaData.facts); n = length(fld);
          for i = 1:n
            hight = 475 - i * 25;
            uicontrol('Parent',dfacts, 'Position',[10, hight, 146, 20], 'String',fld{i}, 'Style','text');
            HF(i)  = uicontrol('Parent',dfacts, 'Callback',{@factsCb, i}, 'Position',[110, hight, 650, 20], 'Style','edit', 'String',metaData.facts.(fld{i})); 
            HFb(i) = uicontrol('Parent',dfacts, 'Callback',{@factsCb, i}, 'Position',[800, hight, 80, 20], 'Style','edit', 'String',metaData.bibkey.(fld{i}));
            uicontrol('Parent',dfacts, 'Callback',{@deleteCb,'facts',i,dfacts}, 'Position',[920, hight, 20, 20], 'String','X', 'ForegroundColor',[1 0 0], 'FontWeight','bold');
          end
        end

      case 'acknowledgment'
        dacknowledgment = dialog('Position',[150 150 700 150], 'Name','acknowledgment dlg');
        uicontrol('Parent',dacknowledgment, 'Position',[10 95 146 20], 'String','Text', 'Style','text');
        uicontrol('Parent',dacknowledgment, 'Callback',{@OKCb,dacknowledgment}, 'Position',[110 70 20 20], 'String','OK');
        HK = uicontrol('Parent',dacknowledgment, 'Callback',@acknowledgmentCb, 'Position',[110 95 550 20], 'Style','edit', 'String',metaData.acknowledgment); 
        
      case 'links'
        dlinks = dialog('Position',[150 150 350 350],'Name','links dlg');
        links = {...
          % general links
          'https://www.catalogueoflife.org/col/'
          'https://www.itis.gov/'
          'https://eol.org/'
          'https://en.wikipedia.org/wiki/'
          'https://animaldiversity.org/'
          'http://taxonomicon.taxonomy.nl/'
          'https://marinespecies.org/'
          % taxon-specific links
          'https://www.molluscabase.org/'
          'https://www.ntnu.no/ub/scorpion-files/'
          'https://wsc.nmbe.ch/'
          'https://www.collembola.org/'
          'http://Orthoptera.SpeciesFile.org'
          'http://phasmida.speciesfile.org/'
          'http://aphid.speciesfile.org/'
          'https://diptera.info/'
          'http://www.nhm.ac.uk/our-science/data/lepindex/'
          'https://www.fishbase.org/'
          'https://amphibiaweb.org/search/'
          'https://reptile-database.reptarium.cz/'
          'https://avibase.bsc-eoc.org/'
          'http://datazone.birdlife.org/'
          'https://www.departments.bucknell.edu/biology/resources/msw3/'
          'https://genomics.senescence.info/'};   
         
        if ~handfilled % if taxonomy is handfilled include all websites and fill with empty       
          select_id(1:7) = true; % general websites
          if isfield(metaData.links, 'id_ITIS') && isempty(metaData.links.id_ITIS)
            % metaData.links.id_ITIS = get_id_ITIS(metaData.species);
            % the ITIS website is frequently not responding and holds progress
          end
          if isfield(metaData.links, 'id_EoL') && isempty(metaData.links.id_EoL)
            metaData.links.id_EoL = get_id_EoL(metaData.species);
          end
          if isfield(metaData.links, 'id_Wiki') && isempty(metaData.links.id_Wiki)
            metaData.links.id_Wiki = get_id_Wiki(metaData.species);
          end
          if isfield(metaData.links, 'id_ADW') && isempty(metaData.links.id_ADW)
            metaData.links.id_ADW = get_id_ADW(metaData.species);
          end
          if isfield(metaData.links, 'id_Taxo') && isempty(metaData.links.id_Taxo)
            metaData.links.id_Taxo = get_id_Taxo(metaData.species);
          end
          if isfield(metaData.links, 'id_WoRMS') && isempty(metaData.links.id_WoRMS)
            metaData.links.id_WoRMS = get_id_WoRMS(metaData.species);
          end
        
          select_id(8:23) = false; % taxon-specific websites
          if ~isempty(metaData.phylum) & ismember(metaData.phylum, 'Mollusca') & isempty(metaData.links.id_molluscabase)
            select_id(8) = true;
            metaData.links.id_molluscabase = get_id_molluscabase(metaData.species);
          end
          if ~isempty(metaData.order) & ismember(metaData.order, 'Scorpiones') & isempty(metaData.links.id_scorpion)
            select_id(9) = true;
            metaData.links.id_scorpion = get_id_scorpion(metaData.species);
          end
          if ~isempty(metaData.order) & ismember(metaData.order, 'Araneae') & isempty(metaData.links.id_spider)
            select_id(10) = true;
            metaData.links.id_spider = get_id_spider(metaData.species);
          end
          if ~isempty(metaData.class) & ismember(metaData.class, 'Entognatha') & isempty(metaData.links.id_collembola)
            select_id(11) = true;
            metaData.links.id_collembola = get_id_collembola(metaData.species);
          end
          if ~isempty(metaData.order) & ismember(metaData.order, 'Orthoptera') & isempty(metaData.links.id_orthoptera)
            select_id(12) = true;
            metaData.links.id_orthoptera = get_id_orthoptera(metaData.species);
          end
          if ~isempty(metaData.order) & ismember(metaData.order, 'Phasmatodea') & isempty(metaData.links.id_phasmida)
            select_id(13) = true;
            metaData.links.id_phasmida = get_id_phasmida(metaData.species);
          end
          if ~isempty(metaData.family) & ismember(metaData.family, 'Aphididae') & isempty(metaData.links.id_aphid)
            select_id(14) = true;
            metaData.links.id_aphid = get_id_aphid(metaData.species);
          end
          if ~isempty(metaData.order) & ismember(metaData.order, 'Diptera') & isempty(metaData.links.id_diptera)
            select_id(15) = true;
            metaData.links.id_diptera = get_id_diptera(metaData.species);
          end
          if ~isempty(metaData.order) & ismember(metaData.order, 'Lepidoptera') & isempty(metaData.links.id_lepidoptera)
            select_id(16) = true;
            metaData.links.id_lepidoptera = get_id_lepidoptera(metaData.species);
          end
          if ~isempty(metaData.class) & ismember(metaData.class, {'Cyclostomata', 'Chondrichthyes', 'Actinopterygii', 'Actinistia', 'Dipnoi'}) & isempty(metaData.links.id_fishbase)
            select_id(17) = true;
            metaData.links.id_fishbase = get_id_fishbase(metaData.species);
          end
          if ~isempty(metaData.class) & ismember(metaData.class, 'Amphibia') & isempty(metaData.links.id_amphweb)
            select_id(18) = true;
            metaData.links.id_amphweb = get_id_amphweb(metaData.species);
          end
          if ~isempty(metaData.class) & ismember(metaData.class, {'Reptilia','Squamata','Testudines','Crocodilia'}) & isempty(metaData.links.id_ReptileDB)
            select_id(19) = true;
            metaData.links.id_ReptileDB = get_id_ReptileDB(metaData.species);
          end
          if ~isempty(metaData.class) & ismember(metaData.class, 'Aves') & isempty(metaData.links.id_avibase)
            select_id(20) = true;
            metaData.links.id_avibase = get_id_avibase(metaData.species);
          end
          if ~isempty(metaData.class) & ismember(metaData.class, 'Aves') & isempty(metaData.links.id_birdlife)
            select_id(21) = true;
            metaData.links.id_birdlife = get_id_birdlife(metaData.species);
          end
          if ~isempty(metaData.class) && ismember(metaData.class, 'Mammalia') & isempty(metaData.links.id_MSW3)
            select_id(22) = true;
            metaData.links.id_MSW3 = get_id_MSW3(metaData.species);
          end
          if ~isempty(metaData.class) & ismember(metaData.class, {'Amphibia','Reptilia','Squamata','Testudines','Crocodilia','Aves','Mammalia'}) & isempty(metaData.links.id_AnAge)
            select_id(23) = true;
            metaData.links.id_AnAge = get_id_AnAge(metaData.species);
          end
        end
        
        select_id = logical(select_id); ID_links = id_links(select_id); Links = links(select_id); n_Links = length(ID_links);
        for i= 1:n_Links 
          if i>1 && ~handfilled
            web(Links{i},'-browser');
          end
          hight = 275 - i * 25;
          if ~isfield(metaData.links, ID_links{i})
            metaData.links.(ID_links{i}) = [];
          end
          uicontrol('Parent',dlinks, 'Position',[0, hight, 146, 20], 'String',ID_links{i}, 'Style','text');
          uicontrol('Parent',dlinks, 'Callback',{@OKCb,dlinks}, 'Position',[110 10 20 20], 'Style','pushbutton', 'String','OK'); 
          if i == 1 && ~handfilled
            Hlinks(1) = uicontrol('Parent',dlinks, 'Position',[110, hight, 210, 20], 'Style','text', 'String',metaData.links.(ID_links{i})); 
          else
            Hlinks(i)  = uicontrol('Parent',dlinks, 'Callback',{@linksCb,ID_links,i}, 'Position',[110, hight, 210, 20], 'Style','edit', 'String',metaData.links.(ID_links{i})); 
          end
       end
        
    case 'biblist'
      bibTypeList.article =       {'author', 'title', 'journal',     'year', 'volume', 'pages', 'doi', 'url'};
      bibTypeList.book =          {'author', 'title', 'publisher',   'year', 'series', 'volume', 'isbn', 'url'};
      bibTypeList.incollection =  {'author', 'title', 'editor', 'booktitle', 'publisher', 'year', 'series', 'volume', 'isbn', 'url'};
      bibTypeList.mastersthesis = {'author', 'title', 'school',      'year', 'address', 'doi', 'isbn', 'url'};
      bibTypeList.phdthesis =     {'author', 'title', 'school',      'year', 'address', 'doi', 'isbn', 'url'};
      bibTypeList.techreport =    {'author', 'title', 'institution', 'year', 'address', 'series', 'volume', 'doi', 'isbn', 'url'};
      bibTypeList.misc =          {'author', 'note',                 'year', 'doi', 'isbn', 'url'};
        
      dbiblist = dialog('Position',[150 100 250 700], 'Name','biblist dlg');
      uicontrol('Parent',dbiblist, 'Position',[ 10 670  50 20], 'Callback',{@OKCb,dbiblist}, 'Style','pushbutton', 'String','OK'); 
      uicontrol('Parent',dbiblist, 'Position',[70 670 100 20], 'Callback',{@addBibCb,dbiblist}, 'String','add bib item', 'Style','pushbutton');
      
      if ~isempty(metaData.biblist)
        fld = fields(metaData.biblist); n = length(fld);
        for i = 1:n
          hight = 650 - i * 25;
          Hb(i) = uicontrol('Parent',dbiblist,  'Position',[ 10, hight,  100, 20], 'Style','text', 'String',fld{i}); % name
          uicontrol('Parent',dbiblist, 'Callback',{@DbCb,bibTypeList,i}, 'Position',[100, hight,  70 20], 'Style','pushbutton', 'String','edit');
          uicontrol('Parent',dbiblist, 'Callback',{@deleteCb,'biblist',fld{i},dbiblist}, 'Position',[200, hight, 20, 20], 'String','X', 'ForegroundColor',[1 0 0], 'FontWeight','bold');
        end          
      end
        
    case 'data_0' 
        
      code0 = { ... % code-name, units, temp-dependence, description
          'ah',   'd', 1, 'age at hatch';          
          'ab',   'd', 1, 'age at birth';
          'tx',   'd', 1, 'time since birth at weaning';
          't1',   'd', 1, 'time since birth at 1st instar';
          't2',   'd', 1, 'time since 1st instar at 2nd instar';
          't3',   'd', 1, 'time since 2nd instar at 3rd instar';
          't4',   'd', 1, 'time since 3rd instar at 4th instar';
          't5',   'd', 1, 'time since 4th instar at 5th instar';
          't6',   'd', 1, 'time since 5th instar at 6th instar';
          'tj',   'd', 1, 'time since birth at end acceleration';
          'tp',   'd', 1, 'time since birth at puberty';
          'tpm',  'd', 1, 'time since birth at puberty for males'; 
          'tR',   'd', 1, 'time since birth at first egg production';
          'te',   'd', 1, 'time since pupation at emergence';
          'am',   'd', 1, 'life span';

          'Lh',  'cm', 0, 'length at hatch';
          'Lb',  'cm', 0, 'length at birth'
          'L1',  'cm', 0, 'length at 1st instar after birth'
          'L2',  'cm', 0, 'length at 2nd instar'
          'L3',  'cm', 0, 'length at 3rd instar'
          'L4',  'cm', 0, 'length at 4th instar'
          'L5',  'cm', 0, 'length at 5th instar'
          'L6',  'cm', 0, 'length at 6th instar'
          'Lx',  'cm', 0, 'length at weanig/fledging'
          'Ls',  'cm', 0, 'length at start acceleration'
          'Lj',  'cm', 0, 'length at end acceleration'
          'Lp',  'cm', 0, 'length at puberty';
          'Lpm', 'cm', 0, 'length at puberty for males';
          'Li',  'cm', 0, 'ultimate length';
          'Lim', 'cm', 0, 'ultimate length for males';
          'Le',  'cm', 0, 'length of imago';

          'Ww0',  'g', 0, 'initial wet weight';
          'Wwh',  'g', 0, 'wet weight at hatch';
          'Wwb',  'g', 0, 'wet weight at birth';
          'Ww1',  'g', 0, 'wet weight at 1st instar after birth';
          'Ww2',  'g', 0, 'wet weight at 2nd instar';
          'Ww3',  'g', 0, 'wet weight at 3rd instar';
          'Ww4',  'g', 0, 'wet weight at 4th instar';
          'Ww5',  'g', 0, 'wet weight at 5th instar';
          'Ww6',  'g', 0, 'wet weight at 6th instar';
          'Wwx',  'g', 0, 'wet weight at weanig/fledging'
          'Wws',  'g', 0, 'wet weight at start acceleration'
          'Wwj',  'g', 0, 'wet weight at end acceleration';
          'Wwp',  'g', 0, 'wet weight at puberty';
          'Wwpm', 'g', 0, 'wet weight at puberty for males';
          'Wwi',  'g', 0, 'ultimate wet weight';
          'Wwim', 'g', 0, 'ultimate wet weight for males';
          'Wwe',  'g', 0, 'wet weight of imago';

          'Wdh',  'g', 0, 'dry weight at hatch';
          'Wdb',  'g', 0, 'dry weight at birth';
          'Wd1',  'g', 0, 'dry weight at 1st instar after birth';
          'Wd2',  'g', 0, 'dry weight at 2nd instar';
          'Wd3',  'g', 0, 'dry weight at 3rd instar';
          'Wd4',  'g', 0, 'dry weight at 4th instar';
          'Wd5',  'g', 0, 'dry weight at 5th instar';
          'Wd6',  'g', 0, 'dry weight at 6th instar';
          'Wdx',  'g', 0, 'dry weight at weanig/fledging'
          'Wds',  'g', 0, 'dry weight at start acceleration'
          'Wdj',  'g', 0, 'dry weight at end acceleration';
          'Wdp',  'g', 0, 'dry weight at puberty';
          'Wdpm', 'g', 0, 'dry weight at puberty for males';
          'Wdi',  'g', 0, 'ultimate dry weight';
          'Wdim', 'g', 0, 'ultimate dry weight for males';
          'Wde',  'g', 0, 'dry weight of imago';
          
          'E0',   'J', 0, 'initial energy content';

          'Ri', '#/d', 1, 'ultimate reproduction rate';
          'GSI', 'mol E_R/mol W', 1, 'Gonado-Somatic Index as fraction'
          }; 
        
      ddata_0 = dialog('Position',[150 35 1050 620], 'Name','0-variate data dlg');
      uicontrol('Parent',ddata_0, 'Position',[ 60 580  50 20], 'Callback',{@OKCb,ddata_0}, 'Style','pushbutton', 'String','OK'); 
      uicontrol('Parent',ddata_0, 'Position',[400 580 150 20], 'Callback',{@add0Cb,code0,ddata_0}, 'String','add 0-var data', 'Style','pushbutton');
      uicontrol('Parent',ddata_0, 'Position',[ 60 550  70 20], 'String','name', 'Style','text');
      uicontrol('Parent',ddata_0, 'Position',[140 550  70 20], 'String','value', 'Style','text');
      uicontrol('Parent',ddata_0, 'Position',[200 550  70 20], 'String','units', 'Style','text');
      uicontrol('Parent',ddata_0, 'Position',[260 550  70 20], 'String','temp in C', 'Style','text');
      uicontrol('Parent',ddata_0, 'Position',[390 550  70 20], 'String','label', 'Style','text');
      uicontrol('Parent',ddata_0, 'Position',[550 550  70 20], 'String','bibkey', 'Style','text');
      uicontrol('Parent',ddata_0, 'Position',[640 550  70 20], 'String','comment', 'Style','text');

      if ~isempty(data.data_0)
        fld = fields(data.data_0); n = size(fld);
        for i = 1:n
          hight = 550 - i * 25; 
          uicontrol('Parent',ddata_0,                                  'Position',[ 60, hight,  70, 20], 'Style','text', 'String',fld{i}); % name
          H0v(i) = uicontrol('Parent',ddata_0,   'Callback',{@d0Cb,i}, 'Position',[150, hight,  70, 20], 'Style','edit', 'String',num2str(data.data_0.(fld{i}))); % value
          H0u(i) = uicontrol('Parent',ddata_0,                         'Position',[230, hight,  30, 20], 'Style','text', 'String',txtData.units.(fld{i})); % units
          if isfield(auxData.temp, fld{i})
            H0T(i) = uicontrol('Parent',ddata_0, 'Callback',{@d0Cb,i}, 'Position',[270, hight,  40, 20], 'Style','edit', 'String',num2str(K2C(auxData.temp.(fld{i})))); % temp(C)
          else
            H0T(i) = uicontrol('Parent',ddata_0,                       'Position',[270, hight,  40, 20], 'Style','text', 'String','');         
          end
          H0l(i) = uicontrol('Parent',ddata_0,                         'Position',[320, hight, 220, 20], 'Style','text', 'String',txtData.label.(fld{i})); % label
          H0b(i) = uicontrol('Parent',ddata_0,   'Callback',{@d0Cb,i}, 'Position',[550, hight,  70, 20], 'Style','edit', 'String',cell2str(txtData.bibkey.(fld{i}))); % bibkey
%           if ~isfield(txtData.comment, fld{i})
%             txtData.comment.(fld{i}) = [];
%           end          
          H0c(i) = uicontrol('Parent',ddata_0,   'Callback',{@d0Cb,i}, 'Position',[650, hight, 300, 20], 'Style','edit', 'String',txtData.comment.(fld{i})); % comment
          uicontrol('Parent',ddata_0, 'Callback',{@deleteCb,'data_0',fld{i},ddata_0}, 'Position',[1000, hight, 20, 20], 'String','X', 'ForegroundColor',[1 0 0], 'FontWeight','bold');
        end
      end

    case 'data_1' 

      code1 = { ... % column 3 stands for yes-or-no temperature
          'LWw',   {'cm','g'}, 0, {'length','wet weight'}, '';
          'LWw_f', {'cm','g'}, 0, {'length','wet weight'}, 'Data for females';
          'LWw_m', {'cm','g'}, 0, {'length','wet weight'}, 'Data for males';
          
          'LWd',   {'cm','g'}, 0, {'length','dry weight'}, '';
          'LWd_f', {'cm','g'}, 0, {'length','dry weight'}, 'Data for females';
          'LWd_m', {'cm','g'}, 0, {'length','dry weight'}, 'Data for males';
          
          'tL',    {'d','cm'}, 1, {'time','length'}, '';
          'tL_f'   {'d','cm'}, 1, {'time','length'}, 'Data for females'; 
          'tL_m'   {'d','cm'}, 1, {'time','length'}, 'Data for males'; 
          
          'tWw',   {'d', 'g'}, 1, {'time','wet weight'}, ''; 
          'tWw_m', {'d', 'g'}, 1, {'time','wet weight'}, 'Data for females'; 
          'tWw_f', {'d', 'g'}, 1, {'time','wet weight'}, 'Data for males';
          
          'tWd',   {'d', 'g'}, 1, {'time','dry weight'}, ''; 
          'tWd_f', {'d', 'g'}, 1, {'time','dry weight'}, 'Data for males';
          'tWd_m', {'d', 'g'}, 1, {'time','dry weight'}, 'Data for females'; 
                    
          'LdL',   {'cm','cm/d'}, 1, {'length','change in length'}, '';
          'LdL_f', {'cm','cm/d'}, 1, {'length','change in length'}, 'Data for females';
          'LdL_m', {'cm','cm/d'}, 1, {'length','change in length'}, 'Data for males';
          
          'LN',    {'cm','#'}, 1, {'length','yearly fecundity'},     '';
          'WwN',   {'g','#'},  1, {'wet weight','yearly fecundity'}, '';
          'WdN',   {'g','#'},  1, {'dry weight','yearly fecundity'}, '';

          'LR',    {'cm','#/d'}, 1, {'length','reproduction rate'},     '';
          'WwR',   {'g','#/d'},  1, {'wet weight','reproduction rate'}, '';
          'WdR',   {'g','#/d'},  1, {'dry weight','reproduction rate'}, '';

          'LJO',   {'cm','mol/d'}, 1, {'length','O2 consumption'},     '';
          'WwJO',  {'g','mol/d'},  1, {'wet weight','O2 consumption'}, '';
          'WdJO',  {'g','mod/d'},  1, {'dry weight','O2 consumption'}, '';

          }; 
        
      ddata_1 = dialog('Position',[150 35 520 800], 'Name','1-variate data dlg');
      uicontrol('Parent',ddata_1, 'Position',[ 10 780  50 20], 'Callback',{@OKCb,ddata_1}, 'Style','pushbutton', 'String','OK'); 
      uicontrol('Parent',ddata_1, 'Position',[150 780 150 20], 'Callback',{@add1Cb,code1,ddata_1}, 'String','add 1-var data', 'Style','pushbutton');
      uicontrol('Parent',ddata_1, 'Position',[ 10 750  60 20], 'String','name', 'Style','text');
      uicontrol('Parent',ddata_1, 'Position',[100 750  90 20], 'String','x-label', 'Style','text');
      uicontrol('Parent',ddata_1, 'Position',[200 750  90 20], 'String','y-label', 'Style','text');

      if ~isempty(data.data_1)
        fld = fields(data.data_1); n = size(fld);
        for i = 1:n
          hight = 750 - i * 25; 
          uicontrol('Parent',ddata_1,  'Position',[ 10, hight,  70, 20], 'Style','text', 'String',fld{i}); % name
          label = txtData.label.(fld{i}); 
          uicontrol('Parent',ddata_1,  'Position',[100, hight, 100, 20], 'Style','text', 'String',label{1}); % x-label
          uicontrol('Parent',ddata_1,  'Position',[200, hight, 100, 20], 'Style','text', 'String',label{2}); % y-label
          D1(i) = uicontrol('Parent',ddata_1, 'Callback',{@D1Cb,fld{i},i}, 'Position',[380, hight,  70 20], 'Style','pushbutton', 'String','edit');
          uicontrol('Parent',ddata_1, 'Callback',{@deleteCb,'data_1',fld{i},ddata_0}, 'Position',[480, hight, 20, 20], 'String','X', 'ForegroundColor',[1 0 0], 'FontWeight','bold');
        end
      end
            
    case 'COMPLETE'
        
        c   = 'COMPLETE levels for data: Each level includes previous levels (from LikaKear2011)';
        c0  = ' 0  Maximum length and body weight; weight as function of length';
        c1  = ' 1  Age, length and weight at birth and puberty for one food level; mean life span (due to ageing)';
        c2  = ' 2  Growth (curve) at one food level: length and weight as functions of age at constant (or abundant) food level';
        c3  = ' 3  Reproduction and feeding as functions of age, length and/or weight at one food level';
        c4  = ' 4  Growth (curve) at several (>1) food levels; age, length and weight at birth and puberty at several food levels';
        c5  = ' 5  Reproduction and feeding as functions of age, length and/or weight at several (>1) food levels';
        c6  = ' 6  Respiration as function of length or weight and life span at several (>1) food levels';
        c7  = ' 7  Elemental composition at one food level, survival due to ageing as function of age';
        c8  = ' 8  Elemental composition at several (>1) food levels, including composition of food';
        c9  = ' 9  Elemental balances for C, H, O and N at several body sizes and several food levels';
        c10 = '10 Energy balance at several body sizes and several food levels (including heat)';
        
      dCOMPLETE = dialog('Position',[450 200 620 400], 'Name','COMPLETE dlg');
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 365 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c, 'FontSize',11); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 325 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c0); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 300 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c1); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 275 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c2); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 250 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c3); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 225 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c4); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 200 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c5); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 175 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c6); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 150 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c7); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 125 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c8); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10 100 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c9); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 10  75 600 20], 'Style','text', 'HorizontalAlignment','left', 'String',c10); 
      HCOMPLETE = uicontrol('Parent',dCOMPLETE, 'Position',[ 10 40  50 20], 'Callback',@COMPLETECb, 'Style','edit', 'String',metaData.COMPLETE); 
      uicontrol('Parent',dCOMPLETE, 'Position',[ 110 40  50 20], 'Callback',{@OKCb,dCOMPLETE}, 'Style','pushbutton', 'String','OK'); 

    case 'resume'
      if ismac || isunix
        list = strsplit(ls); list(end) = [];
      else
        list = cellstr(ls);
      end
      list_res = list(Contains(list,'results_')); n_res = length(list_res);
      list_backup = list_res(Contains(list_res,'_backup')); n_backup = length(list_backup);
      if n_backup > 0
        load(list_backup{1})  
        AmPgui('setColors')
      elseif (n_res - n_backup) == 1
        load(list_res{1});
        AmPgui('setColors')
      elseif n_res == 0
        fprintf('Warning from AmPgui: no results_my_pet.mat found\n');
      else
        fprintf('Warning from AmPgui: more than a single file results_my_pet.mat found, remove the wrong ones first\n');
      end
      
    case 'pause'
      nm = ['results_', metaData.species, '.mat'];
      %save(nm, 'data', 'auxData', 'metaData', 'txtData', 'color', 'select_id', 'id_links', 'eco_types');
      save(nm, 'data', 'auxData', 'metaData', 'txtData', 'color', 'select_id', 'id_links', 'handfilled');
      dpause = dialog('Position',[150 150 500 150],'Name','pause dlg');
      uicontrol('Parent',dpause, 'Position',[ 50 95 400 20], 'String',['File ', nm, ' has been written'], 'Style','text');
      uicontrol('Parent',dpause, 'Position',[80 60 150 20], 'Callback',{@stayCb,dpause},  'String','stay in AmPgui', 'Style','pushbutton');
      HAmPeps = uicontrol('Parent',dpause, 'Position',[250 60 200 20], 'Callback',{@proceedCb,dpause}, 'String','quit AmPgui, continue with AmPeps', 'Style','pushbutton');
      Hquit = uicontrol('Parent',dpause, 'Position',[140 30 200 20], 'Callback',{@quitCb,{dpause,dmydata}}, 'String','quit AmPgui and AmPeps', 'Style','pushbutton');
      set(HAmPeps, 'ForegroundColor',[0 0.6 0]); set(Hquit, 'ForegroundColor',[1 0 0]);
  end
end
  % color settings: run this part only with AmPgui('setColors')
  try; close(Hwait); catch; end % close any wait warnings; function isvalid requires Toolbox Image Acquisition, Instrument control or OPC
  figure(dmydata); % bring the main dialog window to the front
  
  if ~any([isempty(metaData.species), isempty(metaData.family), isempty(metaData.order), isempty(metaData.class), isempty(metaData.phylum)])
    color.species = [0 .6 0]; set(hspecies, 'ForegroundColor', color.species);
  end

  if any([isempty(metaData.ecoCode.climate), isempty(metaData.ecoCode.ecozone), isempty(metaData.ecoCode.habitat), ...
    isempty(metaData.ecoCode.embryo), isempty(metaData.ecoCode.food), isempty(metaData.ecoCode.gender), isempty(metaData.ecoCode.reprod)])
    color.ecoCode = [1 0 0]; set(hecoCode, 'ForegroundColor', color.ecoCode);
  else
    color.ecoCode = [0 0.6 0]; set(hecoCode, 'ForegroundColor', color.ecoCode);
  end

  if ~isempty(metaData.T_typical)
    color.T_typical = [0 .6 0]; set(hT_typical, 'ForegroundColor', color.T_typical);
  end

  if isfield(metaData, 'author') && ~isempty(metaData.author)
    color.author = [0 .6 0]; set(hauthor, 'ForegroundColor', color.author);
  end
  
  if isfield(metaData, 'curator') && ~isempty(metaData.curator)
    color.curator = [0 .6 0]; set(hcurator, 'ForegroundColor', color.curator);
  end
            
  fld_male_0 = {'tpm', 'Lpm', 'Lim', 'Wwpm', 'Wwim', 'Wdpm', 'Wdim'};
  fld_male_1 = {'tL_m', 'tWw_m', 'tWd_m', 'LWw_m', 'LWd_m', 'LdL_m'};
  if isempty(metaData.discussion)
    if ~isempty(data.data_0) & ismember(fields(data.data_0),fld_male_0) 
      color.discussion = [1 0 0];
    elseif ~isempty(data.data_1) & ismember(fields(data.data_1),fld_male_1)
     color.discussion = [1 0 0];
    else
      color.discussion = [0 0 0]; 
    end
  else
     color.discussion = [0 0.6 0]; 
  end
  set(hdiscussion, 'ForegroundColor', color.discussion);

  if isfield(metaData, 'facts') && ~isempty(metaData.facts)
    fld = fields(metaData.facts); n_fld = length(fld); 
    color.facts = [0 .6 0]; 
    for i = 1:n_fld
       if ~isfield(metaData.bibkey, fld{i}) && ~isempty(metaData.bibkey,(fld{i}))
         color.facts = [1 0 0]; 
       end
    end
  end
  set(hfacts, 'ForegroundColor', color.facts);
 
  if isfield(metaData, 'acknowledgment') && ~isempty(metaData.acknowledgment)
    color.acknowledgment = [0 .6 0]; set(hacknowledgment, 'ForegroundColor', color.acknowledgment);
  end

  if ~isempty(select_id)
    color.links = [0 .6 0]; set(hlinks, 'ForegroundColor', color.links)
  end
  
  if ~isempty(data.data_0)
    color.data_0 = [0 0.6 0]; set(hdata_0, 'ForegroundColor', color.data_0);
  end
  
  if ~isempty(metaData.COMPLETE)
    color.COMPLETE = [0 0.6 0]; set(hCOMPLETE, 'ForegroundColor', color.COMPLETE);
  end
 
  if isfield(metaData, 'biblist') && ~isempty(metaData.biblist)
    bibitems = fields(metaData.biblist);
  else
    bibitems = {};
  end
  bibkeys = {};
  if ~isempty(data.data_0)
    fld = fields(data.data_0); n_fld = length(fld);
    for i=1:n_fld
      addbibkey = txtData.bibkey.(fld{i});
      if iscell(addbibkey)
        bibkeys = [bibkeys, addbibkey{:}];
      else
        bibkeys = [bibkeys, addbibkey];
      end
    end
    bibkeys = unique(bibkeys);
  end
  if ~isempty(data.data_1)
    fld = fields(data.data_1); n_fld = length(fld);
    for i=1:n_fld
      addbibkey = txtData.bibkey.(fld{i});
      if iscell(addbibkey)
        bibkeys = [bibkeys, addbibkey{:}];
      else
        bibkeys = [bibkeys, addbibkey];
      end
    end
    bibkeys = unique(bibkeys);
  end 
  if ~isempty(metaData.bibkey)
    fld = fields(metaData.bibkey); n_fld = length(fld);
    for i=1:n_fld
      addbibkey = metaData.bibkey.(fld{i});
      if iscell(addbibkey)
        bibkeys = [bibkeys, addbibkey{:}];
      else
        bibkeys = [bibkeys, addbibkey];
      end
    end
    bibkeys = unique(bibkeys);
  end
  bibkeys = unique(bibkeys);
  bibkeys_missing = bibkeys(~ismember(bibkeys,[bibitems; 'guess']));
  if ~isempty(bibkeys_missing)
    color.biblist = [1 0 0];
    fprintf(['Warning from AmPgui: missing bibitems are ', cell2str(bibkeys_missing),'\n']);
  else
    color.biblist = [0 0.6 0];
  end
  set(hbiblist, 'ForegroundColor', color.biblist);
end

%% callback functions
function speciesCb(~, ~, dspecies)  % fill lineage automatically, see OKspeciesCb
  global metaData Hspecies hspecies Hfamily Horder Hclass Hphylum Hcommon Hwarning HwarningOK 
  global color dmydata infoAmPgui list_spec handfilled  lin % my_pet_lineage

  my_pet = strrep(get(Hspecies, 'string'), ' ', '_'); metaData.species = my_pet;
  handfilled = true; % don't call speciesCb again, but OKspeciesCb instead

  if ismember(my_pet,list_spec) % species is already in AmP
    set(Hfamily,'String',''); set(Horder,'String',''); set(Hclass,'String',''); set(Hphylum,'String',''); set(Hcommon,'String','');
    set(Hwarning, 'String', 'species is already in AmP');
    set(HwarningOK, 'String','OK proceeds to post-editing phase of AmPeps');
    hleave = uicontrol('Parent',dspecies, 'Position',[40 15 20 20], 'Callback',{@leaveCb,{dspecies,dmydata}}, 'Style','pushbutton', 'String','OK');
    infoAmPgui = 0;
    set(hleave, 'ForegroundColor', [1 0 0]); 
    return
  end
  
  [~, ~, lin, rank, id_Taxo] = lineage_Taxo(my_pet);
  genus = strsplit(my_pet,'_'); genus = genus{1};
  id_Taxo_genus = get_id_Taxo(genus); % identification code of the genus
  if isempty(id_Taxo)
    metaData.links.id_Taxo = id_Taxo_genus;
  else
    metaData.links.id_Taxo = id_Taxo;
  end
  if isempty(rank) && isempty(id_Taxo_genus)
    fprintf('Warning from AmPgui: species %s and genus %s are not recognized by Taxo\n', my_pet, genus);
    return
  end
  
  if ~isempty(lin)
    metaData.family = lin{ismember(rank,'Family')};  
    metaData.order  = lin{ismember(rank,'Order')};  
    metaData.class  = lin{ismember(rank,'Class')};  
    metaData.phylum = lin{ismember(rank,'Phylum')};  
  end
  
  nms = get_common_Taxo(id_Taxo); 
  if isempty(nms)
    metaData.species_en = 'no_english_name'; 
  else
    metaData.species_en = nms{1}; 
  end
  set(Hfamily, 'String',metaData.family); set(Horder, 'String',metaData.order); 
  set(Hclass, 'String',metaData.class); set(Hphylum, 'String',metaData.phylum); set(Hcommon, 'String',metaData.species_en);
  color.species = [0 0.6 0]; set(hspecies, 'ForegroundColor', color.species);
  frames = java.awt.Frame.getFrames(); frames(end).setAlwaysOnTop(1); frames(end-1).setAlwaysOnTop(1);
  infoAmPgui = 1;
  close(dspecies); 
  AmPgui('setColors')
  AmPgui('species') % repeat case species, but now with run OKspeciesCb because handfilled is true
end

function OKspeciesCb(~, ~, dspecies)  % fill/correct lineage manually
  global metaData Hspecies Hfamily Horder Hclass Hphylum Hcommon Hwarning HwarningOK %handfilled
  
  %handfilled = true; % taxonomy handfilled, links also filled manually
  my_pet = strrep(get(Hspecies, 'string'), ' ', '_'); metaData.species = my_pet;
  uicontrol('Parent',dspecies, 'Position',[10 110 60 20], 'Style','text', 'String','family: ');
  Hfamily  = uicontrol('Parent',dspecies, 'Callback',@familyCb, 'Position',[70 110 90 20], 'Style','edit', 'String',metaData.family);
  uicontrol('Parent',dspecies, 'Position',[160 110 60 20], 'Style','text', 'String','order: ');
  Horder  = uicontrol('Parent',dspecies, 'Callback',@orderCb, 'Position',[220 110 90 20], 'Style','edit', 'String',metaData.order);
  uicontrol('Parent',dspecies, 'Position',[310 110 60 20], 'Style','text', 'String','class: ');
  Hclass  = uicontrol('Parent',dspecies, 'Callback',@classCb, 'Position',[370 110 140 20], 'Style','edit', 'String',metaData.class);
  uicontrol('Parent',dspecies, 'Position',[10 80 60 20], 'Style','text', 'String','phylum: ');
  Hphylum  = uicontrol('Parent',dspecies, 'Callback',@phylumCb, 'Position',[80 80 90 20], 'Style','edit', 'String',metaData.phylum);
  uicontrol('Parent',dspecies, 'Position',[200 80 120 20], 'Style','text', 'String','common name: ');
  Hcommon = uicontrol('Parent',dspecies, 'Callback',@species_enCb, 'Position',[350 80 160 20], 'Style','edit', 'String',metaData.species_en);
  Hspecies = uicontrol('Parent',dspecies, 'Callback',{@speciesCb,dspecies}, 'Position',[110 15 350 20], 'Style','edit', 'String',metaData.species); 
  set(Hwarning, 'String',''); 
  set(HwarningOK, 'String','');
  uicontrol('Parent',dspecies, 'Position',[40 15 20 20], 'Callback',{@OKlineageCb,dspecies}, 'Style','pushbutton', 'String','OK');
  AmPgui('setColors')
end

function OKlineageCb(~, ~, dspecies)  % check manually-filled lineage
  persistent list_genus list_family list_order  list_class list_phylum
  global metaData Hwarning HwarningOK infoAmPgui Hwait lin
  
  % the lowest level in the manually filled dialog window dspecies that is in AmP is used; 
  % higher levels are overwritten by those in the AmP lineage
  
  set(Hwarning, 'String','checking lineage, see Matlab window'); 
  Hwait = waitbar(0,'Please wait for checking lineage ...');

  if isempty(list_genus)
    list_genus  = list_taxa('',3); waitbar(0.2,Hwait);
    list_family = list_taxa('',4); waitbar(0.4,Hwait);
    list_order  = list_taxa('',5); waitbar(0.6,Hwait); 
    list_class  = list_taxa('',6); waitbar(0.8,Hwait); 
    list_phylum = list_taxa('',7); waitbar(1.0,Hwait); 
  end

  genus = strsplit(metaData.species,'_'); genus = genus{1};
  if ismember(genus, list_genus)
    fprintf(['Genus "', genus, '" is present in AmP\n'])
    infoAmPgui = 2;
    metaData.family = lin{5};
    metaData.order  = lin{4};
    metaData.class  = lin{3};
    metaData.phylum = lin{2};
  elseif ismember(metaData.family, list_family)
    fprintf(['Genus is not present in AmP, but family "', metaData.family, '" is\n'])
    infoAmPgui = 3;
    list_lin = lineage_short(metaData.family); 
    metaData.order  = list_lin{4};
    metaData.class  = list_lin{3};
    metaData.phylum = list_lin{2};
  elseif ismember(metaData.order, list_order)
    fprintf(['Family is not present in AmP, but order "', metaData.order, '" is\n'])
    infoAmPgui = 4;
    list_lin = lineage(metaData.order); 
    metaData.class = cell2str(list_class(ismember(list_class,list_lin)));
    metaData.phylum = cell2str(list_phylum(ismember(list_phylum,list_lin)));
  elseif ismember(metaData.class, list_class)
    fprintf(['Order is not present in AmP, but class "', metaData.class, '" is\n'])
    infoAmPgui = 5;
    list_lin = lineage(metaData.class); 
    metaData.phylum = cell2str(list_phylum(ismember(list_phylum,list_lin)));
  elseif ismember(metaData.phylum, list_phylum)
    fprintf(['Class is not present in AmP, but phylum "', metaData.phylum, '" is\n'])
    infoAmPgui = 6;
  else
    fprintf(['Phylum "', metaData.phylum, '" is not present in AmP!\n'])
    infoAmPgui = 7;
  end
  close(dspecies);
  AmPgui('color')
end

function familyCb(~, ~)
  global metaData Hfamily
  metaData.family = get(Hfamily, 'string');
end

function orderCb(~, ~)
 global metaData Horder
 metaData.order = get(Horder, 'string');
end

function classCb(~, ~)
 global metaData Hclass
 metaData.class = get(Hclass, 'string');
end

function phylumCb(~, ~)
 global metaData Hphylum
 metaData.phylum = get(Hphylum, 'string');
end

function species_enCb(~, ~)
 global metaData Hcommon
 metaData.species_en = get(Hcommon, 'string');
end
 
function climateCb(~, ~, Hclimate)  
  global metaData eco_types hclimateLand hclimateSea
  set(hclimateLand,'Position',[250 20 1200 850]); % climate figure large size
  set(hclimateSea,'Position',[250 20 1200 850]); % climate figure large size
  climateCode = fields(eco_types.climate); n_climate = length(climateCode); 
  if isempty(metaData.ecoCode.climate)
    i_climate = 1;
  else
    i_climate = 1:n_climate;
    sel_climate = ismember(climateCode,metaData.ecoCode.climate); 
    i_climate = i_climate(sel_climate);
  end
  i_climate =  listdlg('ListString',climateCode, 'Name','climate dlg', 'ListSize',[205 450], 'InitialValue',i_climate);  
  metaData.ecoCode.climate = climateCode(i_climate); 
  set(Hclimate, 'String', cell2str(metaData.ecoCode.climate)); 
  set(hclimateLand,'Position',[300 450 500 300]); % climate figure normal size
  set(hclimateSea, 'Position',[900 450 500 300]); % climate figure normal size
  AmPgui('setColors')
end

function ecozoneCb(~, ~, Hecozone)   
  global metaData eco_types hecozones hoceans
  set(hecozones,'Position',[250 20 1200 850]); % ecozone figures large size
  set(hoceans,  'Position',[250 20 1200 850]); % ecozone figures large size
  ecozoneCode = fields(eco_types.ecozone); n_ecozone = length(ecozoneCode); 
  ecozoneCodeList = ecozoneCode;
   for i=1:n_ecozone
     ecozoneCodeList{i} = [ecozoneCodeList{i}, ': ', eco_types.ecozone.(ecozoneCode{i})];
   end
   metaData.ecoCode.ecozone
   if isempty(metaData.ecoCode.ecozone)
     i_ecozone = 1;
   else
     i_ecozone = 1:n_ecozone;
     sel_ecozone = ismember(ecozoneCode,metaData.ecoCode.ecozone); 
     i_ecozone = i_ecozone(sel_ecozone);
   end
   i_ecozone =  listdlg('ListString', ecozoneCodeList,'Name', 'ecozone dlg','ListSize',[450 500], 'InitialValue',i_ecozone);
   metaData.ecoCode.ecozone = ecozoneCode(i_ecozone); 
   set(Hecozone, 'String', cell2str(metaData.ecoCode.ecozone)); 
   set(hecozones,'Position',[300  50 500 300]); % ecozone figures normal size
   set(hoceans,  'Position',[900  50 500 300]); % ecozone figures normal size
   AmPgui('setColors')
end
 
function habitatCb(~, ~, Hhabitat)  
  global metaData eco_types 
  habitatCode = fields(eco_types.habitat); n_habitat = length(habitatCode); 
  habitatCodeList = habitatCode; 
  for i=1:n_habitat
    habitatCodeList{i} = [habitatCodeList{i}, ': ', eco_types.habitat.(habitatCode{i})];
  end
  if isempty(metaData.ecoCode.habitat)
    i_habitat = 1;
  else
    code = metaData.ecoCode.habitat; n_code = length(code);
    for i = 1:n_code; Code = code{i}; code{i} = Code(3:end); end % remove stage codes
    i_habitat = 1:n_habitat;
    i_habitat = i_habitat(i_habitat(ismember(habitatCode,code)));
  end
  i_habitat =  listdlg('ListString',habitatCodeList, 'Name','habitat dlg', 'ListSize',[400 500], 'InitialValue',i_habitat);
  habitatCode = prependStage(i_habitat, habitatCode, habitatCodeList, 'habitat');
  metaData.ecoCode.habitat = habitatCode; 
  set(Hhabitat, 'String', cell2str(metaData.ecoCode.habitat)); 
  AmPgui('setColors')
end

function embryoCb(~, ~, Hembryo)  
  global metaData eco_types 
  embryoCode = fields(eco_types.embryo); n_embryo = length(embryoCode); 
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
  AmPgui('setColors')
end

function migrateCb(~, ~, Hmigrate)  
  global metaData eco_types 
  migrateCode = fields(eco_types.migrate); n_migrate = length(migrateCode);
  migrateCodeList = migrateCode;
  for i=1:n_migrate
    migrateCodeList{i} = [migrateCodeList{i}, ': ', eco_types.migrate.(migrateCode{i})];
  end
  migrateCode = [' '; migrateCode]; migrateCodeList = [' no migration/torpor'; migrateCodeList];
  if isempty(metaData.ecoCode.migrate)
    i_migrate = 1;
  else
    i_migrate = 1:n_migrate;
    i_migrate = i_migrate(i_migrate(ismember(migrateCode,metaData.ecoCode.migrate)));
  end
  i_migrate =  listdlg('ListString',migrateCodeList, 'Name','migrate dlg', 'ListSize',[600 180], 'InitialValue',i_migrate);
  metaData.ecoCode.migrate = migrateCode(i_migrate); 
  set(Hmigrate, 'String', cell2str(metaData.ecoCode.migrate)); 
  AmPgui('setColors')
end

function foodCb(~, ~, Hfood)  
  global metaData eco_types 
  foodCode = fields(eco_types.food); n_food = length(foodCode); 
  foodCodeList = foodCode;
  for i=1:n_food
    foodCodeList{i} = [foodCodeList{i}, ': ', eco_types.food.(foodCode{i})];
  end
  if isempty(metaData.ecoCode.food)
    i_food = 1;
  else
    code = metaData.ecoCode.food; n_code = length(code);
    for i = 1:n_code; Code = code{i}; code{i} = Code(3:end); end; % remove stage codes
    i_food = 1:n_food;
    i_food = i_food(i_food(ismember(foodCode,code)));
  end
  i_food =  listdlg('ListString',foodCodeList, 'Name','food dlg', 'ListSize',[600 500], 'InitialValue',i_food);
  foodCode = prependStage(i_food, foodCode, foodCodeList, 'food');
  metaData.ecoCode.food = foodCode; 
  set(Hfood, 'String', cell2str(metaData.ecoCode.food)); 
  AmPgui('setColors')
end

function genderCb(~, ~, Hgender)  
  global metaData eco_types 
  genderCode = fields(eco_types.gender); n_gender = length(genderCode); 
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
  i_gender =  listdlg('ListString',genderCodeList, 'Name','gender dlg', 'ListSize',[600 190], 'InitialValue',i_gender);
  metaData.ecoCode.gender = genderCode(i_gender); 
  set(Hgender, 'String', cell2str(metaData.ecoCode.gender)); 
  AmPgui('setColors')
end

function reprodCb(~, ~, Hreprod)  
  global metaData eco_types 
  reprodCode = fields(eco_types.reprod); n_reprod = length(reprodCode); 
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
  i_reprod =  listdlg('ListString',reprodCodeList, 'Name','reprod dlg', 'ListSize',[600 120], 'InitialValue',i_reprod);
  metaData.ecoCode.reprod = reprodCode(i_reprod); 
  set(Hreprod, 'String', cell2str(metaData.ecoCode.reprod));
  AmPgui('setColors')
end

function T_typicalCb(~, ~)  
   global metaData HT
   metaData.T_typical = C2K(str2double(get(HT, 'string')));
   AmPgui('setColors')
end
 
 function authorCb(~, ~)  
   global metaData Hauthor
   metaData.author = str2cell(get(Hauthor, 'string'));
   AmPgui('setColors')
 end
 
 function emailCb(~, ~) 
   global metaData Hemail
   metaData.email = get(Hemail, 'string');
 end
 
 function addressCb(~, ~)  
   global metaData Haddress
   metaData.address = get(Haddress, 'string');
 end

 function addDiscussionCb(~, ~, ddiscussion)
   global metaData 
   if isfield(metaData.discussion, 'D1')
     n = 1 + length(fields(metaData.discussion)); 
   else
     n = 1;
   end
   nm = ['D', num2str(n)]; 
   metaData.discussion.(nm) = []; metaData.bibkey.(nm) = [];
   delete(ddiscussion)
   AmPgui('discussion')
 end
  
 function discussionCb(~, ~, i)
   global metaData HD HDb 
   nm = ['D', num2str(i)];
   metaData.discussion.(nm) = get(HD(i), 'string');
   metaData.bibkey.(nm) = str2cell(get(HDb(i), 'string'));
 end
 
 function addFactCb(~, ~, dfacts)
   global metaData 
   if isfield(metaData.facts, 'F1')
     n = 1 + length(fields(metaData.facts)); 
   else
     n = 1;
   end
   nm = ['F', num2str(n)]; 
   metaData.facts.(nm) = []; metaData.bibkey.(nm) = [];
   delete(dfacts)
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
 
function linksCb(~, ~, id_links,i)  
  global metaData Hlinks
  metaData.links.(id_links{i}) = get(Hlinks(i), 'string');
end

function addBibCb(~, ~, dbiblist) % create new bibitem in biblist with bibkey "new"
  global metaData
  metaData.biblist.new = [];
  delete(dbiblist)
  AmPgui('biblist')
end

function DbCb(~, ~, bibTypeList, i_bibkey) % present bibitem to allow filling of fields
  global metaData Dbb Dbi Db
  bibkey = fields(metaData.biblist); bibkey = bibkey{i_bibkey};
  Db = dialog('Position',[350 320 800 320], 'Name','bibitem dlg');
  uicontrol('Parent',Db, 'Position',[ 20 280  50 20], 'Callback',{@OKCb,Db}, 'Style','pushbutton', 'String','OK'); 
  uicontrol('Parent',Db, 'Position',[100 280  50 20], 'Style','text', 'String','bibkey: '); 
  Dbb = uicontrol('Parent',Db, 'Position',[160 280  80 20], 'Callback',{@bibkeyCb,bibTypeList,bibkey,i_bibkey}, 'Style','edit', 'String',bibkey); 
  if ~isempty(metaData.biblist) & ~strcmp(bibkey, 'new')
    uicontrol('Parent',Db, 'Position',[300 280 150 20], 'String',['type: ',metaData.biblist.(bibkey).type], 'Style','text');
    fld = bibTypeList.(metaData.biblist.(bibkey).type); n_fld = length(fld);
    for i=1:n_fld
      hight = 260 - i * 25;
      if ~isfield(metaData.biblist.(bibkey), fld{i})
        metaData.biblist.(bibkey).(fld{i}) = [];
      end
      str = metaData.biblist.(bibkey).(fld{i});
      uicontrol('Parent',Db, 'Position',[20 hight 80 20], 'Style','text', 'String',[fld{i},': ']); 
      Dbi(i) = uicontrol('Parent',Db, 'Position',[100 hight 680 20], 'Callback',{@bibitemFldCb,bibkey,fld{i},i}, 'Style','edit', 'String',str); 
    end
  end
end

function bibkeyCb(~, ~, bibTypeList, bibkey, i_bibkey) 
  global metaData Dbb Db Hb
  bibkeyNew = get(Dbb, 'string');
  metaData.biblist = renameStructField(metaData.biblist, bibkey, bibkeyNew); 
  if strcmp(bibkey, 'new') % set type and fill fields with empty if existing bibkey was new
    fld = fields(bibTypeList);
    i_type =  listdlg('ListString',fields(bibTypeList), 'Name','biblist dlg', 'ListSize',[100 150], 'SelectionMode','single', 'InitialValue',1);
    metaData.biblist.(bibkeyNew).type = fld{i_type};
    fld = bibTypeList.(fld{i_type}); n_fld = length(fld);
    for i=1:n_fld
      metaData.biblist.(bibkeyNew).(fld{i}) = [];
    end
  end
  set(Hb(i_bibkey), 'String',bibkeyNew);
  delete(Db);
  DbCb([], [], bibTypeList, i_bibkey)
  AmPgui('color');
end

function bibitemFldCb(~, ~, bibkey, fld, i) % fill a field of a bibitem
  global metaData Dbi
  metaData.biblist.(bibkey).(fld) = get(Dbi(i), 'string');
end

function add0Cb(~, ~, code0, ddata_0) % add 0-var data set to data_0
   % code0: array of possible 0-var data sets: name, description
   % ddata_0: handle for data_0 dialog
   global data txtData auxData metaData
   n_code0 = size(code0,1); codeList0 = code0(:,1);
   for i = 1:n_code0
     codeList0{i} = [code0{i,1}, ': ', code0{i,4}];
   end
   i_code0 =  listdlg('ListString',codeList0, 'Name','0-var data dlg', 'ListSize',[300 400], 'InitialValue',n_code0);
   code0 = code0(i_code0,:); 
   if ~isempty(data.data_0)
     data_0 = fields(data.data_0); 
     code0 = code0(~ismember(code0(:,1), data_0),:);
   end
   n = size(code0,1);
   for i = 1:n
     data.data_0.(code0{i,1}) = []; 
     txtData.units.(code0{i,1}) = code0{i,2};
     txtData.label.(code0{i,1}) = code0{i,4};
     txtData.bibkey.(code0{i,1}) = [];
     txtData.comment.(code0{i,1}) = '';
     if code0{i,3}
       auxData.temp.(code0{i,1}) = [];
     end
     metaData.data_0 = [metaData.data_0; code0{i,1}];
   end
   delete(ddata_0);
   AmPgui('data_0');
end 

function d0Cb(~, ~, i) % fill fields for 0-var data set i
   global data auxData txtData H0v H0T H0b H0c
   fld = fields(data.data_0);
   data.data_0.(fld{i}) = str2double(get(H0v(i), 'string'));
   if isfield(auxData.temp, fld{i})
     auxData.temp.(fld{i}) = C2K(str2double(get(H0T(i), 'string')));
     txtData.units.temp.(fld{i}) = 'K';
     txtData.label.temp.(fld{i}) = 'temperature';
   end
   txtData.bibkey.(fld{i}) = str2cell(get(H0b(i), 'string'));
   txtData.comment.(fld{i}) = get(H0c(i), 'string');
end

function add1Cb(~, ~, code1, ddata_1)
   global data txtData auxData metaData
   n_code1 = size(code1,1); codeList1 = code1(:,1);
   for i = 1:n_code1
     codeList1{i} = [code1{i,1}, ': ', cell2str(code1{i,4})];
   end
   i_code1 =  listdlg('ListString',codeList1, 'Name','1-var data dlg', 'ListSize',[300 350], 'InitialValue',n_code1);
   code1 = code1(i_code1,:); 
   if ~isempty(data.data_1)
     data_1 = fields(data.data_1); 
     code1 = code1(~ismember(code1(:,1), data_1),:);
   end
   n = size(code1,1);
   for i = 1:n
     data.data_1.(code1{i,1}) = []; 
     txtData.units.(code1{i,1}) = code1{i,2};
     txtData.label.(code1{i,1}) = code1{i,4};
     txtData.bibkey.(code1{i,1}) = [];
     txtData.comment.(code1{i,1}) = [];
     if code1{i,3}
       auxData.temp.(code1{i,1}) = [];
     end
     metaData.data_1 = [metaData.data_1; code1{i,1}];
   end 
   delete(ddata_1);
   AmPgui('data_1');
end 

function D1Cb(~, ~, fld, i)  
   global data auxData txtData D1 H1v H1T H1b H1c
   D1(i) = dialog('Position',[150 35 475 500], 'Name','1-variate data set dlg');
   units = txtData.units.(fld); label = txtData.label.(fld);
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
     H1T(i) = uicontrol('Parent',D1(i), 'Position',[325 300  50 20], 'Callback',{@d1TCb,fld,i}, 'String', num2str(K2C(auxData.temp.(fld))), 'Style','edit');
   end
   uicontrol('Parent',D1(i), 'Position',[225 275  100 20], 'String','bibkey', 'Style','text');
   H1b(i) = uicontrol('Parent',D1(i), 'Position',[300 275  100 20], 'Callback',{@d1bCb,fld,i}, 'String',txtData.bibkey.(fld), 'Style','edit');
   uicontrol('Parent',D1(i), 'Position',[225 250  70 20], 'String','comment', 'Style','text');
   H1c(i) = uicontrol('Parent',D1(i), 'Position',[225 225  240 20], 'Callback',{@d1cCb,fld,i}, 'String',txtData.comment.(fld), 'Style','edit');
end

function d1Cb(~, ~, fld, i)
  global data H1v
  data.data_1.(fld) = str2num(get(H1v(i), 'string'));
end

  
function d1TCb(~, ~, fld, i)
  global auxData txtData H1T 
  auxData.temp.(fld) = C2K(str2double(get(H1T(i), 'string')));
  txtData.units.temp.(fld) = 'K';
  txtData.label.temp.(fld) = 'temperature';
end  

function d1bCb(~, ~, fld, i)
  global txtData H1b 
  txtData.bibkey.(fld) = str2cell(get(H1b(i), 'string'));
end  

function d1cCb(~, ~, fld, i)
  global txtData H1c
  txtData.comment.(fld) = get(H1c(i), 'string');
end  

function COMPLETECb(~, ~)  
  global metaData HCOMPLETE
  metaData.COMPLETE = str2double(get(HCOMPLETE, 'string'));
  AmPgui('setColors')
end

function stayCb(~, ~, H) 
  OKCb([], [], H);
end

function proceedCb(~, ~, H)
  global infoAmPgui data metaData txtData auxData color select_id id_links eco_types 
  
  % do all data_0 have bibkeys?
  check_bibkey0 = false;
  if ~isempty(data.data_0)
    fld_0 = fields(data.data_0); n = length(fld_0); check_bibkey0 = false(n,1);
    for i= 1:n
      if ~isfield(txtData.bibkey, fld_0{i})
        fprintf(['Warning from AmPeps: please enter a bibkey for dataset ', fld_0{i}, '\n']);
        check_bibkey0{i} = true;
      end
    end
  end

  % do all data_1 have bibkeys?
  check_bibkey1 = false;
  if ~isempty(data.data_1)
    fld_1 = fields(data.data_1); n = length(fld_1); check_bibkey1 = false(n,1);
    for i= 1:n
      if ~isfield(txtData.bibkey, fld_1{i})
        fprintf(['Warning from AmPeps: please enter a bibkey for dataset ', fld_1{i}, '\n']);
        check_bibkey1{i} = true;
      end
    end
  end
  
  % do all facts have bibkeys?
  check_bibkeyF = false;
  if ~isempty(metaData.facts)
    fld_F = fields(metaData.facts); n = length(fld_F); check_bibkeyF = false(n,1);
    for i= 1:n
      if ~isfield(metaData.bibkey, fld_F{i})
        fprintf(['Warning from AmPeps: please enter a bibkey for fact ', fld_F{i}, '\n']);
        check_bibkeyF(i) = true;
      end
    end
  end

  % do all bibkeys have bibitems?
  check_bibitem = false;
  if ~isempty(txtData.bibkey) & ~isempty(metaData.biblist)
    bibkeys = {};
    dataNm = fields(txtData.bibkey); n_data = length(dataNm); check_bibitem = false(n_data,1);
    for i = 1:n_data
      addbibkey = txtData.bibkey.(dataNm{i});
      if iscell(addbibkey)
        bibkeys = [bibkeys; addbibkey(:)];
      else
        bibkeys = [bibkeys; addbibkey];
      end
    end
    if ~isempty(metaData.bibkey) % bibkeys for facts and discussion points
      fld = fields(metaData.bibkey); n_fld = length(fld);
      for i=1:n_fld
        addbibkey = metaData.bibkey.(fld{i});
        if iscell(addbibkey)
          bibkeys = [bibkeys; addbibkey(:)];
        else
          bibkeys = [bibkeys; addbibkey];
        end
      end
    end
    bibkeys = unique(bibkeys);
    bibkeys = bibkeys(~ismember(bibkeys, [fields(metaData.biblist); 'guess'; 'Kooy2010']));
    if ~isempty(bibkeys)
      fprintf('Warning from AmPeps: the following bibkeys were not found in the biblist, please complete\n');
      bibkeys
      check_bibitem = true;
    end 
  end

  % are all ecoCodes filled, except migrate?
  eco = {'climate', 'ecozone', 'habitat', 'embryo', 'food', 'gender', 'reprod'}; n_eco = length(eco); 
  check_eco = false(n_eco,1);
  for i = 1 : n_eco
    check_eco(i) = isempty(metaData.ecoCode.(eco{i}));
  end
  
  % first check that all required fields are filled, if so proceed to AmPeps
  if isempty(metaData.author); fprintf('Warning from AmPeps: please enter author details\n') 
    OKCb([], [], H); AmPgui('author'); 
  elseif isempty(metaData.curator); fprintf('Warning from AmPeps:select curator\n') 
    OKCb([], [], H); AmPgui('curator'); 
  elseif isempty(metaData.species); fprintf('Warning from AmPeps: please enter species name\n') 
    OKCb([], [], H); AmPgui('species'); 
  elseif any(check_eco)
    fprintf('Warning from AmPeps: empty ecoCodes ', cell2str(eco(check_eco)),'\n');      
    OKCb([], [], H); AmPgui('ecoCode')  
  elseif isempty(metaData.T_typical); fprintf('Warning from AmPeps: please specify typical body temperature\n')
    OKCb([], [], H); AmPgui('T_typical'); 
  elseif isempty(metaData.COMPLETE); fprintf('Warning from AmPeps: please specify COMPLETE\n')
    OKCb([], [], H); AmPgui('COMPLETE'); 
  elseif isempty(data.data_0) | isempty(txtData.units.temp) 
    fprintf('Warning from AmPeps: please enter at least one 0-variate data point that is time-dependent\n'); 
    OKCb([], [], H); AmPgui('data_0'); 
  elseif isempty(metaData.biblist)
    fprintf('Warning from AmPeps: empty biblist, please complete\n');
    OKCb([], [], H); AmPgui('biblist'); 
  elseif any(check_bibkeyF)
    OKCb([], [], H); AmPgui('facts');  
  elseif any(check_bibkey0)
    OKCb([], [], H); AmPgui('data_0'); 
  elseif any(check_bibkey1)
    OKCb([], [], H); AmPgui('data_1'); 
  elseif check_bibitem
    OKCb([], [], H); AmPgui('biblist'); 
  else
    save(['results_', metaData.species, '.mat'], 'data', 'auxData', 'metaData', 'txtData', 'color', 'select_id', 'id_links', 'eco_types', 'infoAmPgui');
    OKCb([], [], H); AmPeps(infoAmPgui);
  end
      
end

function leaveCb(~, ~, H)
  global infoAmPgui
  OKCb([], [], H);
  AmPeps(infoAmPgui);
end

function quitCb(~, ~, H) 
  OKCb([], [], H);
  close all;
end

function OKCb(~, ~, H) 
  if iscell(H)
    n = length(H);
    for i = 1:n
      close(H{i});
    end
  else
    close(H);
  end
end

function deleteCb(~, ~, type, id, handle) 
  global data metaData txtData
  switch type
    case 'facts'
      fact = ['F', num2str(id)];
      metaData.facts = rmfield(metaData.facts, fact); 
      metaData.bibkey = rmfield(metaData.bibkey, fact);
      if isfield(metaData.facts, ['F', num2str(id+1)])
        n = length(fields(metaData.facts)) - id + 2;
        for i = 1:n
          metaData.facts = renameStructField(metaData.facts,['F', num2str(i + 1)], ['F', num2str(i)]);
          metaData.bibkey = renameStructField(metaData.bibkey,['F', num2str(i + 1)], ['F', num2str(i)]);
        end
      end
      close(handle);
      AmPgui('facts');
    
    case 'discussion'
      disc = ['D', num2str(id)];
      metaData.discussion = rmfield(metaData.discussion, disc); 
      metaData.bibkey = rmfield(metaData.bibkey, disc);
      if isfield(metaData.discussion, ['D', num2str(id+1)])
        n = length(fields(metaData.discussion)) - id + 2;
        for i = 1:n
          metaData.discussion = renameStructField(metaData.discussion,['D', num2str(i + 1)], ['D', num2str(i)]);
          metaData.bibkey = renameStructField(metaData.bibkey,['D', num2str(i + 1)], ['D', num2str(i)]);
        end
      end
      close(handle);
      AmPgui('discussion');
    
    case 'biblist'
      metaData.biblist = rmfield(metaData.biblist, id); 
      close(handle);
      AmPgui('biblist');

    case 'data_0'
      data.data_0 = rmfield(data.data_0, id); 
      txtData.bibkey = rmfield(txtData.bibkey, id); 
      delete(handle);
      AmPgui('data_0');
      
    case 'data_1'
      data.data_1 = rmfield(data.data_1, id); 
      txtData.bibkey = rmfield(txtData.bibkey, id); 
      close(handle);
      AmPgui('data_1');     
  end
end

%% other support functions
function str = cell2str(cell)
  if isempty(cell)
    str = []; return
  end
  if ~iscell(cell)
    str = cell;
    return
  end
  n = length(cell); str = [];
  for i=1:n
    str = [str, cell{i}, ','];
  end
  str(end) = [];
end

function c = str2cell(str)
  if isempty(str)
    c = {}; return
  elseif iscell(str)
    c = str; return
  end
  str = strsplit(str, ',');
  n = length(str); 
  c = cell(1,n);
  for i=1:n
    c{i} = str{i};
  end
end

function stageCode = prependStage(ind, code, codeList, type)
  stageList = { ...
  '0b', '0j', ...
  '0x          stage ij is the period', ...
  '0p          between events i and j', ...
  '0i', ...
  'bj          0: start', ...
  'bx          b: birth', ...
  'bp          j: metamorphosis', ...
  'bi           x: weaning/fledge', ...
  'jp           p: puberty', ...
  'ji            i: death', ... % this spacing gives the best outlining on the screen
  'xp', 'xi', 'pi'};
  stageCode = code(ind); n = length(ind); 
  switch type
    case 'habitat'
      init = 5; % stageCode 0i
    case 'food'
      init = 9; % stageCode bi
  end
  for i = 1:n
    fprintf(['Prepend stage for code ', code{ind(i)},'\n']);
    name = ['stage code for ', codeList{ind(i)}];
    i_stage =  listdlg('ListString',stageList, 'Name',name, 'SelectionMode','single', 'ListSize',[600 250], 'InitialValue',init);
    stage = stageList{i_stage};
    stageCode{i} = [stage(1:2), code{ind(i)}];
  end
end

function sel = Contains(nm, str)
  % this fuction is the same as Matlab built-in-function contains, but the R2016a version does not work with cell input
  n = length(nm); sel = true(n,1);
  for i=1:n
    sel(i) = ~isempty(strfind(nm{i}, str));
  end
end
