%% treeview_taxa_js
% write treeview_taxa.js that is called by treeview_taxa.html

%%
function treeview_taxa_js (pedigree)
% created 2016/03/06 by Bas Kooijman

%% Syntax
% <../treeview_taxa_js.m *treeview_taxa_js*> (pedigree) 

%% Description
% Clears and creates file treeview_taxa.js in DEBtool_M/taxa and writes java code to it
%
% Input:
%
% * character string with pedigree (default pedigree('Animalia'))
%
%% Example of use
% treeview_taxa_js(pedigree('Animalia'))

  fid_tv = fopen('treeview_taxa.js', 'w+'); % open file for writing, delete existing content

  % write header
  fprintf(fid_tv, '//\n');
  fprintf(fid_tv, '// Copyright (c) 2006 by Conor O''''Mahony.\n');
  fprintf(fid_tv, '// For enquiries, please email GubuSoft@GubuSoft.com\n');
  fprintf(fid_tv, '// Please keep all copyright notices below.\n');
  fprintf(fid_tv, '// Original author of TreeView script is Marcelino Martins.\n');
  fprintf(fid_tv, '// This document includes the TreeView script.\n');
  fprintf(fid_tv, '// The TreeView script can be found at http://www.TreeView.net.\n');
  fprintf(fid_tv, '// The script is Copyright (c) 2006 by Conor O''''Mahony.\n');
  fprintf(fid_tv, '//\n');
  fprintf(fid_tv, '// You can find general instructions for this file at www.treeview.net.\n');
  fprintf(fid_tv, '//\n\n');
  
  % write specs
  fprintf(fid_tv, 'USETEXTLINKS = 1\n');
  fprintf(fid_tv, 'STARTALLOPEN = 0\n');
  fprintf(fid_tv, 'USEFRAMES = 0\n');
  fprintf(fid_tv, 'USEICONS = 0\n');
  fprintf(fid_tv, 'WRAPTEXT = 1\n');
  fprintf(fid_tv, 'PRESERVESTATE = 1\n');
  fprintf(fid_tv, 'HIGHLIGHT = 1\n\n');
  
  % build tree
  nl = strfind(pedigree, char(10)); node = pedigree(1:nl-1); pedigree(1:nl) = [];
  fprintf(fid_tv, ['foldersTree = gFld("<b>', node, '</b>", "treeview_taxa.html")\n']);

  while length(pedigree) > 3
    nl = strfind(pedigree, char(10)); node = pedigree(1:nl-1); pedigree(1:nl) = [];
    level = max(strfind(node, char(9))); node(1:level) = []; L = ['L', num2str(level)]; Lnew = ['L', num2str(1 + level)];
    if level == 1
      fprintf(fid_tv, ['L2 = insFld(foldersTree, gFld("', node,'", "treeview_taxa.html?pic=', node, '.png"))\n']);
    elseif isempty(strfind(node, '_'))
      fprintf(fid_tv, [Lnew, ' = insFld(', L, ', gFld("', node,'", "treeview_taxa.html?pic=', node, '.png"))\n']);
    else
      fprintf(fid_tv, ['insDoc(', L, ', gLnk("S", "', node, '", "http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/i_results_', node, '.html"))\n']); 
    end
  end
 
  fclose(fid_tv);

