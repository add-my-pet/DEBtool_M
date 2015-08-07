%% zip_my_pet
% Compress all my_pet .m and .mat files in the current folder to the file my_pet.zip.

%%
function zip_my_pet(my_pet, basefolder)
  % created by Dina Lika 2015/08/07

  %% Syntax
  % <../zip_my_pet.m *zip_my_pet*>(my_pet)
  
  %% Description
  % zips all my_pet .m and .mat files in folder "my_pet" 
  % If full path to the my_pet folder is not specified, 
  % the current folder is '.\' (one level up)
  %
  % Input
  %
  % my_pet: string with name of species
  %
  % basefolder : String that specifies the root of the paths 
  %              for the files to zip (optional)
  %              Default folder:  '.\'
  %
  % Output zip files in the current folder  
 
  %% Remarks
  % compress all my_pet file
  
  %% Example of use
  % zip_my_pet('my_pet', basefolder)
  % Check number of arguments
  
  narginchk(1,2);

  filenm = [my_pet, '_zip'];   % name of generated zip file

  % files to be included
%   list = {[ my_pet, '\mydata_', my_pet, '.m'], [ my_pet, '\predict_', my_pet, '.m'], ...
%         [ my_pet, '\pars_init_', my_pet, '.m'], [ my_pet, '\run_', my_pet, '.m'], ...
%         [ my_pet, '\results_', my_pet, '.mat']};

   list = {[ my_pet, '\*_', my_pet, '.m'], [ my_pet, '\*_', my_pet, '.mat']};
  
   if nargin == 1
          basefolder = '.'; % default path to the basefolder
   end
   
  % zip file is created in your current folder.
  zip(filenm, list, basefolder)