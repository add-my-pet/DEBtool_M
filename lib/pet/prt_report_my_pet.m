%% prt_report_my_pet
% Creates report_my_pet.html 

%%
function prt_report_my_pet(metaData, metaPar, par, T, f, destinationFolder)
% created 2016/11/24 Starrlight;

%% Syntax
% <../prt_report_my_pet.m *prt_report_my_pet*> (metaData, metaPar, par, T, f, destinationFolder) 

%% Description
% Read and writes report_my_pet.html. This pages contains a list of implied model
% properties of my_pet. 
%
% Input:
%
% * metaData: structure (output of <http://www.debtheory.org/wiki/index.php?title=Mydata_file *mydata_my_pet_par*> file)
% * metaPar: structure (output of <http://www.debtheory.org/wiki/index.php?title=Pars_init_file *pars_init_my_pet_par*> file)
% * par: structure (output of <http://www.debtheory.org/wiki/index.php?title=Pars_init_file *pars_init_my_pet_par*> file)
% * T: optional scalar with temperature in Kelvin (default: T_typical)
% * f: optional scalar scaled functional response (default: 1)
% * destinationFolder : optional string with destination folder the files
% are printed to (default: current folder)

%% Example of use
% load('results_my_pet.mat');
% prt_report_my_pet(metaData, metaPar, par, T, f, destinationFolder)

% Removes underscores and makes first letter of english name be
% in capital:
speciesprintnm = strrep(metaData.species, '_', ' ');
speciesprintnm_en = strrep(metaData.species_en, '_', ' ');
if speciesprintnm_en(1)>='a' && speciesprintnm_en(1)<='z'
  speciesprintnm_en(1)=char(speciesprintnm_en(1)-32);
end

if exist('destinationFolder','var')
  fileName = [destinationFolder, 'report_',metaData.species, '.html'];
else
  fileName = ['report_',metaData.species, '.html'];
  if ~exist('f','var')
    f = 1;
    if ~exist('T','var')
      T = metaData.T_typical;
    end
  end
end

[stat, txtStat] = statistics_st(metaPar.model, par, T, f);
stat.z = par.z; txtStat.label.z = 'zoom factor'; txtStat.units.z = '-'; % add zoom factor to statistics which are to be printed 
flds = fieldnmnst_st(stat); % fieldnames of all statistics
% [webStatFields, webColStat] = get_statfields(metaPar.model); % which statistics in what order should be printed in the table

oid = fopen(fileName, 'w+'); % % open file for writing, delete existing content

fprintf(oid, '<!DOCTYPE html>\n');
fprintf(oid, '<HTML>\n');
fprintf(oid, '<HEAD>\n');
fprintf(oid,['  <TITLE>',metaData.species,'</TITLE>\n']);
fprintf(oid, '</HEAD>\n\n');
fprintf(oid, '<BODY>\n\n');

fprintf(oid, '  <h1 > \n');
% ---------- makes links to the wikipedia page if it exists
if isfield(metaData.biblist,'Wiki') %|| isfield(metaData.biblist,'wiki')
  url = eval(['metaData.biblist.', 'Wiki']);
  url(1: strfind(url, 'http') - 1) = [];
  url = url(1: strfind(url, '}') - 1);
  fprintf(oid,['    <A HREF = "',url,'" target = "_blank">',speciesprintnm,'</A> (',speciesprintnm_en,'): &nbsp;\n']);
elseif isfield(metaData.biblist,'wiki') %|| isfield(metaData.biblist,'wiki')
  url = eval(['metaData.biblist.', 'wiki']);
  url(1: strfind(url, 'http') - 1) = [];
  url = url(1: strfind(url, '}') - 1);
  fprintf(oid,['    <A HREF = "',url,'" target = "_blank">',speciesprintnm,'</A>(',speciesprintnm_en,'): &nbsp;\n']);
end
if isfield(metaData.biblist,'Wiki') ==0
  fprintf(oid, [speciesprintnm,'(',speciesprintnm_en,') &nbsp;\n']);
end
% ----------------------------------------------------------------------
fprintf(oid, '  </h1>\n\n');
fprintf(oid, '      <H1 >Implied properties for this entry </H1>\n');	
			
% print out text before the tables
% fprintf(oid, '<H2>Implied properties for this entry</H2>');
fprintf(oid,['      <H2>Model: <a class="link" target = "_blank" href="http://www.debtheory.org/wiki/index.php?title=Typified_models" >&nbsp;', metaPar.model,' &nbsp;</a></H2>\n\n']);

% print the table with the properties :    
fprintf(oid, '      <TABLE>\n');
fprintf(oid, '        <TR BGCOLOR = "#FFE7C6"><TH colspan="4">Implied properties at %g deg. C</TH></TR>\n', K2C(T));
fprintf(oid, '        <TR BGCOLOR = "#FFE7C6"><TH>symbol</TH><TH> value</TH><TH> units</TH><TH> description</TH></TR>\n');
for i = 1:length(flds)
  fprintf(oid, '        <TR BGCOLOR = "%s"> <TD>%s</TD> <TD>%g</TD> <TD>%s</TD><TD>%s</TD></TR>\n',...
    '#ffffff', flds{i}, stat.(flds{i}), ...
    txtStat.units.(flds{i}), txtStat.label.(flds{i}));
end 
fprintf(oid, '      </TABLE>\n\n');


fprintf(oid, '</BODY>\n');
fprintf(oid, '</HTML>\n');

fclose(oid);


