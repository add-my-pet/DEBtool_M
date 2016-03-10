//
// Copyright (c) 2006 by Conor O''Mahony.
// For enquiries, please email GubuSoft@GubuSoft.com
// Please keep all copyright notices below.
// Original author of TreeView script is Marcelino Martins.
// This document includes the TreeView script.
// The TreeView script can be found at http://www.TreeView.net.
// The script is Copyright (c) 2006 by Conor O''Mahony.
//
// You can find general instructions for this file at www.treeview.net.
//

USETEXTLINKS = 1
STARTALLOPEN = 0
USEFRAMES = 0
USEICONS = 0
WRAPTEXT = 1
PRESERVESTATE = 1
HIGHLIGHT = 1

foldersTree = gFld("<b>Echinodermata</b>", "treeview_taxa.html")
L2 = insFld(foldersTree, gFld("Asteroidea", "treeview_taxa.html?pic=%22Asteroidea%2Ejpg%22"))
L3 = insFld(L2, gFld("Forcipulatida", "treeview_taxa.html?pic=%22Forcipulatida%2Ejpg%22"))
L4 = insFld(L3, gFld("Asteriidae", "treeview_taxa.html?pic=%22Asteriidae%2Ejpg%22"))
L5 = insFld(L4, gFld("Asterias", "treeview_taxa.html?pic=%22Asterias%2Ejpg%22"))
insDoc(L5, gLnk("S", "Asterias_rubens", "http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/i_results_Asterias_rubens.html"))
L5 = insFld(L4, gFld("Pisaster", "treeview_taxa.html?pic=%22Pisaster%2Ejpg%22"))
insDoc(L5, gLnk("S", "Pisaster_ochraceus", "http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/i_results_Pisaster_ochraceus.html"))
L3 = insFld(L2, gFld("Valvatida", "treeview_taxa.html?pic=%22Valvatida%2Ejpg%22"))
L4 = insFld(L3, gFld("Asterinidae", "treeview_taxa.html?pic=%22Asterinidae%2Ejpg%22"))
L5 = insFld(L4, gFld("Asterina", "treeview_taxa.html?pic=%22Asterina%2Ejpg%22"))
insDoc(L5, gLnk("S", "Asterina_gibbosa", "http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/i_results_Asterina_gibbosa.html"))
L4 = insFld(L3, gFld("Odontasteridae", "treeview_taxa.html?pic=%22Odontasteridae%2Ejpg%22"))
L5 = insFld(L4, gFld("Odontaster", "treeview_taxa.html?pic=%22Odontaster%2Ejpg%22"))
insDoc(L5, gLnk("S", "Odontaster_validus", "http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/i_results_Odontaster_validus.html"))
L2 = insFld(foldersTree, gFld("Echinoidea", "treeview_taxa.html?pic=%22Echinoidea%2Ejpg%22"))
L3 = insFld(L2, gFld("Camarodonta", "treeview_taxa.html?pic=%22Camarodonta%2Ejpg%22"))
L4 = insFld(L3, gFld("Echinidae", "treeview_taxa.html?pic=%22Echinidae%2Ejpg%22"))
L5 = insFld(L4, gFld("Echinus", "treeview_taxa.html?pic=%22Echinus%2Ejpg%22"))
insDoc(L5, gLnk("S", "Echinus_affinis", "http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/i_results_Echinus_affinis.html"))
L5 = insFld(L4, gFld("Sterechinus", "treeview_taxa.html?pic=%22Sterechinus%2Ejpg%22"))
insDoc(L5, gLnk("S", "Sterechinus_neumayeri", "http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/i_results_Sterechinus_neumayeri.html"))
L4 = insFld(L3, gFld("Parechinidae", "treeview_taxa.html?pic=%22Parechinidae%2Ejpg%22"))
L5 = insFld(L4, gFld("Paracentrotus", "treeview_taxa.html?pic=%22Paracentrotus%2Ejpg%22"))
insDoc(L5, gLnk("S", "Paracentrotus_lividus", "http://www.bio.vu.nl/thb/deb/deblab/add_my_pet/entries_web/i_results_Paracentrotus_lividus.html"))
