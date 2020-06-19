%% import
% imports a mydata_my_pet.m file for editing in AmPeps

%%
function AmPimport(mydata_my_pet)
% created 2020/06/19 by  Bas Kooijman

%% Syntax
% [<../AmPimport.m *AmPimport*> (mydata_my_pet) 

%% Description
% imports a mydata_my_pet.m file for editing in AmPeps, via AmPgui and writing of the 4 AmP sources files
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

global data metaData txtData auxData


eval(['[data, auxData, metaData, txtData] = ', mydata_my_pet, ';']);
[data, metaData] = mydata2AmPgui(data,metaData);

AmPeps;