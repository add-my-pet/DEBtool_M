%% get_fileNms
% get the names of all files on an url

%%
function  nms = get_fileNms(url)
% created 2021/12/21 by Bas Kooijman

%% Syntax
% nms = <get_fileNms *get_fileNms*>(url)

%% Description
% get list of all file names on an url
%
% Input:
%
% * url: string with name of url
% 
% Output
%
% * nms: cell-string with names of files

%% Example
% nm = get_fileNms('file:///C:/Users/bas.xps/Documents/deb/deblab/add_my_pet/entries/Daphnia_magna')

nms = strsplit(urlread(url),char(10))';
nms = nms(~cellfun(@isempty,nms));

