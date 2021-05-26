
%% generate_report
% Print error statistics on screen

%%
function generate_report(par, metaPar, metaData)
% created 2020/11/30 by Juan Francisco Robles

%% Syntax
% <../error_stats.m *error_stats*>(par, metaPar, data, metaData, txtData, txtPar) 

%% Description
% Plotes model predictions from calibration solutions
%
% Input
% 
% * par: structure with parameters of species
% * metaPar: structure with information on metaparameters
% * data: structure with data for species
% * auxData: structure with auxilliairy data that is required to compute predictions of data (e.g. temperature, food.). 
%   auxData is unpacked in predict and the user needs to construct predictions accordingly.
% * metaData: structure with information on the entry
% * txtData: structure with information on the data

%% Remarks
% Depending on <estim_options.html *estim_options*> settings:
% writes to results_my_pet.mat and/or results_my_pet.html, 
% plots to screen
% writes to report_my_pet.html and shows in browser
% Plots use lava-colour scheme; from high to low: white, red, blue, black.
% In grp-plots, colours are assigned from high to low.
% Since the standard colour for females is red, and for males blue, compose set with females first, then males.

global pets 

n_pets = length(pets);

if n_pets > 1
    for i = 1:n_pets   
        metaPar_i = metaPar.(pets{i});
        metaPar_i.model = metaPar.model{i};
        prt_report_my_pet(metaData.(pets{i}), metaPar_i, parPets.(pets{i})) 
    end
else % n_pets == 1
    prt_report_my_pet(metaData, metaPar, par)  
end
end