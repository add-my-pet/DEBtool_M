%% AmPgui
% a GUI to create 4 structures

%%
function AmPgui(action)
% created 2020/06/05 by  Bas Kooijman

%% Syntax
% [data, auxData, metaData, txtData] = <../AmPgui.m *AmPgui*>

%% Description
% Like mydata_my_pet.m, it writes 4 data-structures from scratch
%
% Input: will be entered during the GUI session
%
% Output:
% 
% * data: structure with data
% * auxData: structure with auxilirary data 
% * metaData: structure with metaData 
% * txtData: structure with text for data 

%% Remarks
% set metaData on global befor use of this function.
% Files will be saved in your local directory; 
% use the cd command to the dir of your choice BEFORE running this function to save files in the desired place.
% All weights are set at default values in the resulting file; 
% you might want to change them in the file during the estimation process.
% This function is called in AmPeps

persistent  hs he hT ha hc hg hd hf hk hl hb HOK
global data auxData metaData txtData 
global Hauthor Hemail Haddress Hspecies Hacknowledgment dS

if ~exist('data', 'var') 
  data = [];
end   
if ~exist('auxData', 'var') 
  auxData = [];
end
if ~exist('metaData', 'var') 
  metaData = [];
end
if ~exist('txtData', 'var')
  txtData = [];
end

if nargin == 0 % create the GUI
  dmd = dialog('Position',[150 100 120 360], 'Name','AmPgui');
  hs  = uicontrol('Parent', dmd, 'Callback', 'AmPgui species', 'Position',       [10 290 100 20], 'String', 'species', 'Style', 'pushbutton');
  he  = uicontrol('Parent', dmd, 'Callback', 'AmPgui ecoCode', 'Position',       [10 265 100 20], 'String', 'ecoCode', 'Style', 'pushbutton');
  hT  = uicontrol('Parent', dmd, 'Callback', 'AmPgui T_typical', 'Position',     [10 240 100 20], 'String', 'T_typical', 'Style', 'pushbutton');
  ha  = uicontrol('Parent', dmd, 'Callback', 'AmPgui author',  'Position',       [10 215 100 20], 'String', 'author', 'Style', 'pushbutton');
  hc  = uicontrol('Parent', dmd, 'Callback', 'AmPgui curator', 'Position',       [10 190 100 20], 'String', 'curator', 'Style', 'pushbutton');
  hg  = uicontrol('Parent', dmd, 'Callback', 'AmPgui grp', 'Position',           [10 165 100 20], 'String', 'grp', 'Style', 'pushbutton');
  hd  = uicontrol('Parent', dmd, 'Callback', 'AmPgui discussion', 'Position',    [10 140 100 20], 'String', 'discussion', 'Style', 'pushbutton');
  hf  = uicontrol('Parent', dmd, 'Callback', 'AmPgui facts', 'Position',         [10 115 100 20], 'String', 'facts', 'Style', 'pushbutton');
  hk  = uicontrol('Parent', dmd, 'Callback', 'AmPgui acknowledgment','Position', [10  90 100 20], 'String', 'acknowledgment', 'Style', 'pushbutton');
  hl  = uicontrol('Parent', dmd, 'Callback', 'AmPgui links', 'Position',         [10  65 100 20], 'String', 'links', 'Style', 'pushbutton');
  hb  = uicontrol('Parent', dmd, 'Callback', 'AmPgui biblist', 'Position',       [10  40 100 20], 'String', 'biblist', 'Style', 'pushbutton');
  
else % perform action
  switch(action)
      case 'species'
        if ~isfield(metaData, 'species')
          metaData.species = [];
        end
        if ~isfield(metaData, 'links')
          metaData.links = [];
        end
        dS = dialog('Position',[150 150 500 150],'Name','species dlg');
        Hspecies = uicontrol('Parent',dS, 'Callback', @speciesCb, 'Position', [110 45 350 20], 'Style', 'edit', 'String', metaData.species); 
         
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
        dA = dialog('Position',[150 150 500 150],'Name','author dlg');
        uicontrol('Parent',dA, 'Position', [10 95 146 20], 'String', 'Name', 'Style', 'text');
        Hauthor  = uicontrol('Parent',dA, 'Callback', @authorCb, 'Position',  [110 95 350 20], 'Style', 'edit', 'String', metaData.author); 
        uicontrol('Parent',dA, 'Position', [10 70 146 20], 'String', 'email', 'Style', 'text');
        Hemail   = uicontrol('Parent',dA, 'Callback', @emailCb, 'Position',   [110 70 350 20], 'Style', 'edit', 'String', metaData.email); 
        uicontrol('Parent',dA, 'Position', [10 45 146 20], 'String', 'address', 'Style', 'text');
        Haddress = uicontrol('Parent',dA, 'Callback', @addressCb, 'Position', [110 45 350 20], 'Style', 'edit', 'String', metaData.address); 
        
      case 'curator'
        curList = {'Starrlight Augustine', 'Dina Lika', 'Nina Marn', 'Mike Kearney', 'Bas Kooijman'};
        emailList = {'starrlight.augustine@akvaplan.niva.no', 'lika@uoc.gr' ,'nina.marn@gmail.com', 'mrke@unimelb.edu.au', 'salm.kooijman@gmail.com'};
        i_cur =  listdlg('ListString', curList, 'SelectionMode', 'single', 'Name', 'curator dlg', 'ListSize', [140 80], 'InitialValue', 5);
        metaData.curator = curList{i_cur}; metaData.email_cur = emailList{i_cur}; 
        Datevec = datevec(datenum(date)); metaData.date_acc = Datevec(1:3);
        
      case 'acknowledgment'
        if ~isfield(metaData, 'acknowledgment')
          metaData.acknowledgment = [];
        end
        dK = dialog('Position',[150 150 700 150],'Name','acknowledgment dlg');
        uicontrol('Parent',dK, 'Position', [10 95 146 20], 'String', 'Text', 'Style', 'text');
        Hacknowledgment = uicontrol('Parent',dK, 'Callback', @acknowledgmentCb, 'Position',  [110 95 550 20], 'Style', 'edit', 'String', metaData.acknowledgment); 

  end
end
end

 function speciesCb(source, eventdata)  
   global metaData Hspecies dS
   spnm = get(Hspecies, 'string');
   spnm = strrep(spnm, ' ', '_'); 
   [id_CoL, my_pet] = get_id_CoL(spnm); 
   if isempty(id_CoL)
     web('http://www.catalogueoflife.org/col/','-browser');
     uicontrol('Parent', dS, 'Position', [110 70 350 20], 'Style', 'text', 'String', 'species not recognized, search CoL');
   elseif ismember(my_pet,select)
     uicontrol('Parent', dS, 'Position', [110 95 350 20], 'Style', 'text', 'String', 'species is already in AmP');
     uicontrol('Parent', dS, 'Position', [110 75 350 20], 'Style', 'text', 'String', 'close and proceed to post-editing phase of AmPeps');
   else
     [lin, rank] = lineage_CoL(my_pet);
     metaData.species = my_pet; metaData.links.id_CoL = id_CoL;
     metaData.species_en = get_common_CoL(id_CoL);
     nm = lin(ismember(rank, 'Family')); metaData.family = nm{1};
     nm = lin(ismember(rank, 'Order'));  metaData.order = nm{1};
     nm = lin(ismember(rank, 'Class'));  metaData.class = nm{1};
     nm = lin(ismember(rank, 'Phylum')); metaData.phylum = nm{1};
   end
 end
 
 function authorCb(source, eventdata)  
   global metaData Hauthor
   metaData.author = get(Hauthor, 'string');
 end
 
 function emailCb(source, eventdata) 
   global metaData Hemail
   metaData.email = get(Hemail, 'string');
 end
 
 function addressCb(source, eventdata)  
   global metaData Haddress
   metaData.address = get(Haddress, 'string');
 end
 
 function acknowledgmentCb(source, eventdata)  
   global metaData Hacknowledgment
   metaData.acknowledgment = get(Hacknowledgment, 'string');
 end
