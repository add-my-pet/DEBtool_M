%% zip_pets
% Compress files of all species in a taxon in the current folder to the file taxon.zip.

%%
function zip_pets(taxon, basefolder)
% created by Bas Kooijman 2015/10/04

%% Syntax
% <../zip_pets.m *zip_pets*>(taxon, basefolder)
  
%% Description  
% zips all files of all species in a taxon in file "taxon.zip". 
% If full path to the my_pet folder is not specified, the current folder is '.\' (one level up)
%
% Input
%
% * taxon: string with name of taxon
%
% * species: cell string with species
%
% * basefolder: Optional string that specifies the root of the paths for the files to zip (Default folder:  '.\')
%
% Output 
%
% * zipped file in current folder  
 
%% Remarks
% See also <zip_my_pet.html *zip_my_pet*>
  
%% Example of use
% zip_pets('Aves')
  
  if nargin == 1
    basefolder = '.'; % default path to the basefolder
  end

  % zip file is created in your current folder.
  zip(taxon, species, basefolder)
