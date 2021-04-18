%% AmPimport
% imports a mydata_my_pet.m file for editing in AmPeps

%%
function AmPimport(my_pet)
% created 2020/06/19 by  Bas Kooijman

%% Syntax
% [<../AmPimport.m *AmPimport*> (my_pet) 

%% Description
% imports a mydata_my_pet.m file for editing in AmPeps, via AmPgui and writing of the 4 AmP sources files.
% if file mydata_my_pet.m is not available in the local directory, while my_pet is in AmP, the file will be copied from AmP. 
%
% Input:
%
% * mydata_my_pet: string with name of mydata-file

%
% Output:
%
% * no explicit output, see AmPeps

%% Remarks
% Files will be saved in your local directory; 
% use the cd command to the dir of your choice BEFORE running this function to save files in the desired place.

%% Example of use
% 1) make new folder, with e.g. name "Cottus_gobio"
% 2) cd in Matlab to this folder
% 3) AmPimport('Cottus_gobio')

global data metaData txtData auxData

% check if mydata_my_pet is present in local dir, else copy copy from AmP
if ismac
  list = strsplit(ls, ' ');
else
  list = cellstr(ls);
end
if isempty(list) | isempty(list(Contains(list,['mydata_', my_pet])))% not present in local dir
  path = ['https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries/', my_pet, '/'];
  if ismac || isunix
    system(['wget ', path, 'mydata_', my_pet, '.m',  ' -O ', 'mydata_', my_pet, '.m']);
  else
    system(['powershell wget ', path, 'mydata_', my_pet, '.m',  ' -O ', 'mydata_', my_pet, '.m']);
  end
end
      
eval(['[data, auxData, metaData, txtData] = mydata_', my_pet, ';']);

% convert to default notation
if isfield(data,'Wb')
  data = renameStructField(data, 'Wb', 'Wwb');
  txtData.units = renameStructField(txtData.units, 'Wb', 'Wwb');
  txtData.label = renameStructField(txtData.label, 'Wb', 'Wwb');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Wb', 'Wwb');
end

if isfield(data,'Lp_m')
  data = renameStructField(data, 'Lp_m', 'Lpm');
  txtData.units = renameStructField(txtData.units, 'Lp_m', 'Lpm');
  txtData.label = renameStructField(txtData.label, 'Lp_m', 'Lpm');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Lp_m', 'Lpm');
end
if isfield(data,'Wp')
  data = renameStructField(data, 'Wp', 'Wwp');
  txtData.units = renameStructField(txtData.units, 'Wp', 'Wwp');
  txtData.label = renameStructField(txtData.label, 'Wp', 'Wwp');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Wp', 'Wwp');
end
if isfield(data,'Wp_m')
  data = renameStructField(data, 'Wp_m', 'Wwpm');
  txtData.units = renameStructField(txtData.units, 'Wp_m', 'Wwpm');
  txtData.label = renameStructField(txtData.label, 'Wp_m', 'Wwpm');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Wp_m', 'Wwpm');
end
if isfield(data,'Wwp_m')
  data = renameStructField(data, 'Wwp_m', 'Wwpm');
  txtData.units = renameStructField(txtData.units, 'Wwp_m', 'Wwpm');
  txtData.label = renameStructField(txtData.label, 'Wwp_m', 'Wwpm');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Wwp_m', 'Wwpm');
end
if isfield(data,'Wdp_m')
  data = renameStructField(data, 'Wdp_m', 'Wdpm');
  txtData.units = renameStructField(txtData.units, 'Wdp_m', 'Wdpm');
  txtData.label = renameStructField(txtData.label, 'Wdp_m', 'Wdpm');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Wdp_m', 'Wdpm');
end

if isfield(data,'Li_m')
  data = renameStructField(data, 'Li_m', 'Lim');
  txtData.units = renameStructField(txtData.units, 'Li_m', 'Lim');
  txtData.label = renameStructField(txtData.label, 'Li_m', 'Lim');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Li_m', 'Lim');
end
if isfield(data,'Wi')
  data = renameStructField(data, 'Wi', 'Wwi');
  txtData.units = renameStructField(txtData.units, 'Wi', 'Wwi');
  txtData.label = renameStructField(txtData.label, 'Wi', 'Wwi');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Wi', 'Wwi');
end
if isfield(data,'Wi_m')
  data = renameStructField(data, 'Wi_m', 'Wwim');
  txtData.units = renameStructField(txtData.units, 'Wi_m', 'Wwim');
  txtData.label = renameStructField(txtData.label, 'Wi_m', 'Wwim');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Wi_m', 'Wwpm');
end
if isfield(data,'Wwi_m')
  data = renameStructField(data, 'Wwi_m', 'Wwim');
  txtData.units = renameStructField(txtData.units, 'Wwi_m', 'Wwim');
  txtData.label = renameStructField(txtData.label, 'Wwi_m', 'Wwim');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Wwi_m', 'Wwim');
end
if isfield(data,'Wdi_m')
  data = renameStructField(data, 'Wdi_m', 'Wdim');
  txtData.units = renameStructField(txtData.units, 'Wdi_m', 'Wdim');
  txtData.label = renameStructField(txtData.label, 'Wdi_m', 'Wdim');
  txtData.bibkey = renameStructField(txtData.bibkey, 'Wdi_m', 'Wdim');
end

if isfield(data,'LW')
  data = renameStructField(data, 'LW', 'LWw');
  txtData.units = renameStructField(txtData.units, 'LW', 'LWw');
  txtData.label = renameStructField(txtData.label, 'LW', 'LWw');
  txtData.bibkey = renameStructField(txtData.bibkey, 'LW', 'LWw');
end
if isfield(data,'LW_f')
  data = renameStructField(data, 'LW_f', 'LWw_f');
  txtData.units = renameStructField(txtData.units, 'LW_f', 'LWw_f');
  txtData.label = renameStructField(txtData.label, 'LW_f', 'LWw_f');
  txtData.bibkey = renameStructField(txtData.bibkey, 'LW_f', 'LWw_f');
end
if isfield(data,'LW_m')
  data = renameStructField(data, 'LW_m', 'LWw_m');
  txtData.units = renameStructField(txtData.units, 'LW_m', 'LWw_m');
  txtData.label = renameStructField(txtData.label, 'LW_m', 'LWw_m');
  txtData.bibkey = renameStructField(txtData.bibkey, 'LW_m', 'LWw_m');
end

if isfield(metaData.biblist, 'Kooy2010')
  metaData.biblist = rmfield(metaData.biblist, 'Kooy2010');
end

[data, metaData] = mydata2AmPgui(data,metaData); % convert mydata standard to AmPgui standard

AmPeps;
end

function sel = Contains(nm, str)
  % this fuction is the same as Matlab built-in-function contains, but the R2016a version does not work with cell input
  n = length(nm); sel = true(n,1);
  for i=1:n
    sel(i) = ~isempty(strfind(nm{i}, str));
  end
end