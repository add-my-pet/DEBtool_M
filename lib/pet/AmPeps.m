%% AmPeps
% the Entry Prepare System of AmP

%%
function AmPeps
% created 2020/06/09 by  Bas Kooijman

%% Syntax
% <../AmPeps.m *AmPeps*>

%% Description
% The function has no explicit input or output. It is a shell around several other functions, that eventually write:
%   mydata_my_pet.m, pars_init_my_pet.m, predict_my_pet.m and run_my_pet.m.
% Guidance is presented at <https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeps.html *AmPeps.html*>

global data metaData txtData auxData infoAmPgui

web('https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeps.html','-browser');
web('https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/AmPeco.html','-browser');
hclimateLand = figure('Name','Land climate', 'Position',[200 450 500 300]); image(imread('climate_land.png'));
hclimateSea  = figure('Name','Sea climate',  'Position',[800 450 500 300]); image(imread('climate_sea.jpg'));
hecozones    = figure('Name','Land ecozone', 'Position',[200  50 500 300]); image(imread('ecozones.png'));
hoceans      = figure('Name','Sea ecozone',  'Position',[800  50 500 300]); image(imread('oceans.jpg'));
AmPgui;
if infoAmPgui == 0 || isempty(infoAmPgui)
  return % stay in gui  
end
close(hclimateLand,hclimateSea,hecozones,hoceans)
if infoAmPgui == 2
  %path = 'https://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_zip/';
  %eval(['!powershell wget ', path]);
  WD = cdCur; 
    list = cellstr(ls('../../add_my_pet/entries_zip')); 
    my_pet_zip = list(contains(list,metaData.species));
    unzip(['../../add_my_pet/entries_zip/', my_pet_zip]);
  cd(WD)
  edit(['mydata_', metaData.species, '.m'], ...
       ['pars_init_', metaData.species, '.m'], ...
       ['predict_', metaData.species, '.m'], ...
       ['run_', metaData.species, '.m'])
  return
end
% AmPflat: flatten biblist, data, remove empty fields

% prt_mydata(data, auxData, metaData, txtData)
% prt_run_my_pet(metaData.species)
% copy pars_init
% [auxPar, info] = prt_predict(par, metaPar, data, auxData, metaData);
% edit pars_init

% edit(['mydata_,     metaData.species], ...
%      ['pars_init_', metaData.species], ...
%      ['predict_'  , metaData.species], ...
%      ['run_'      , metaData.species])

end