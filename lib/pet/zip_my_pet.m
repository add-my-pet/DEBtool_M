%% zip_my_pet
% Compress all my_pet .m and .mat files in the current folder to the file my_pet.zip

%%
function filenm = zip_my_pet(my_pet, basefolder)
% created by Dina Lika 2015/08/07, modified by Bas Kooijman 2017/09/29, 2018/08/17

%% Syntax
% <../zip_my_pet.m *zip_my_pet*>(my_pet)
  
%% Description
% zips all my_pet .m and .csv files in folder "my_pet". 
% If full path to the my_pet folder is not specified, the current folder is '.\' (one level up)
%
% Input
%
% * my_pet: string with name of species
%
% * basefolder : String that specifies the root of the paths 
%              for the files to zip (optional)
%              Default folder:  '.\'
%
% Output 
%
% * filenm: character string with name of zip-file that has been written
% * zip files in the current folder:
% 
%    -- my_pet, '\mydata_', my_pet, '.m'
%    -- my_pet, '\predict_', my_pet, '.m'
%    -- my_pet, '\pars_init_', my_pet, '.m'
%    -- my_pet, '\run_', my_pet, '.m'
%    -- any csv files

 
%% Remarks
% compress all my_pet files; See also <zip_pets.html *zip_pets*>
  
%% Example of use
% zip_my_pet('my_pet', basefolder)
%
% Check number of arguments
  
  narginchk(1,2);

  WD = pwd;
  cd([basefolder,'/',my_pet])
    [data, auxData, metaData] = feval(['mydata_',my_pet]);
    filenm = [my_pet, '_',  datestr(datenum(metaData.date_acc), 'yyyymmdd')];   % name of generated zip file
  cd(WD)

   list = {[ my_pet, '\*_', my_pet, '.m'], [ my_pet, '\*.csv']};
  
   if nargin == 1
          basefolder = '.'; % default path to the basefolder
   end
   
  % zip file is created in your current folder.
  zip(filenm, list, basefolder)