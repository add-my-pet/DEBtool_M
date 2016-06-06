%% printstat_st
% prints the statistics of a species to screen

%%
function printstat_st(stat, txtStat)
% created 2016/04/14 by Bas Kooijman

%% Syntax
% <../printstat_st.m *printstat_st*> (stat, txtStat)

%% Description
% Prints the statistics of a species to screen
%
% Input
%
% * stat: statistics structure
% * txtStat: text for statistics (units, label)

%% Remarks
% Both stat and txtStat are outputs of statistics_st

fprintf('\nStatistics \n');
[nm nst] = fieldnmnst_st(stat);    % get names and number of statistics fields
for i = 1:nst % scan parameter fields
  str1 = [nm{i}, ' ='];
  str2 = [txtStat.units.(nm{i}), ', ', txtStat.label.(nm{i})];
  fprintf('%s %3.4g %s \n', str1, stat.(nm{i}), str2);
end

