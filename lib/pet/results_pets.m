%% results_pets
% Computes model predictions and handles them

%%
function results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights)
% created 2015/01/17 by Goncalo Marques, 2015/03/21 by Bas Kooijman
% modified 2015/03/30 by Goncalo Marques, 2015/04/01 by Bas Kooijman, 2015/04/14 by Goncalo Marques, 2015/04/27 by Goncalo Marques, 2015/05/05 by Goncalo Marques
% modified 2015/07/30 

%% Syntax
% <../results_pets.m *results_pets*>(par, metaPar, txtPar, data, auxData, metaData, txtData, weights) 

%% Description
% Computes model predictions and handles them (by plotting, saving or publishing)
%
% Input
% 
% * txtPar: information on the parameters
% * par: structure with parameters of species
% * chem: structure with chemical parameters for species
% * txtData: structure with information on the data
% * data: structure with data for species
% * metaData: structure with information on the entry

%% Remarks
% Depending on <estim_options.html *estim_options*> settings:
% writes to results_my_pet.mat an/or results_my_pet.html, 
% plots to screen

global pets results_output pseudodata_pets 

close all

[MRE, RE] = mre_st('predict_pets', par, data, auxData, weights); % WLS-method
metaPar.MRE = MRE;
metaPar.RE = RE;

% data = rmfield_wtxt(data, 'weight');
datapl = rmfield_wtxt(data, 'weight');

for i = 1:length(pets)
  ci = num2str(i);
  eval(['[nm nst] = fieldnmnst_st(data.pet', ci,');']);  % nst: number of data sets for pet i
  for j = 1:nst  % replace univariate data by plot data 
    eval(['[aux, k] = size(data.pet', ci, '.', nm{j}, ');']); % number of data points per set
    if k >= 2 && isempty(strfind(nm{j}, 'temp.'))
      eval(['datavec = data.pet', ci, '.', nm{j}, '(:,1);']);
      xaxis = linspace(min(datavec), max(datavec), 100)';
      eval(['datapl.pet', ci, '.', nm{j}, ' = xaxis;']);
      if k >= 3
        yaxis = zeros(length(xaxis), 1);
        eval(['yaxis(1) = data.pet', ci, '.', nm{j}, '(1,2);']);
        eval(['datapl.pet', ci, '.', nm{j}, '(:,2) = yaxis;']);
        for l = 3:k
          eval(['datavec = [data.pet', ci, '.', nm{j}, '(:,1), data.pet', ci, '.', nm{j}, '(:,l)];']);
          extra_dependent_var = spline1(xaxis, datavec);
          eval(['datapl.pet', ci, '.', nm{j}, '(:,l) = extra_dependent_var;']); 
        end
      end
    end
  end
end

prdData = predict_pets(par, datapl, auxData);

% prdData = predict_pets(par, data, auxData);

RE_pointer = 1; %auxiliary pointer for the printing of the relative errors

if results_output == 0 || results_output == 1

  for i = 1:length(pets)
    % produce par for species
%     par = par;   % for the case with no zoom factor transformation

    % unpack par
    v2struct(par);
  
    ci = num2str(i);
    fprintf([pets{i}, ' \n']); % print the species name
    fprintf('COMPLETE = %3.1f \n', metaData.(['pet', ci]).COMPLETE)
    fprintf('MRE = %8.3f \n\n', MRE)
    
    fprintf('\n');
%     eval(['printprd_st(data.pet', ci, ', txtData.pet', ci, ', prdData.pet', ci, ', RE);']);  
 
 free = par.free;  
 corePar = rmfield_wtxt(par,'free'); coreTxtPar.units = txtPar.units; coreTxtPar.label = txtPar.label;
 [parFields nbParFields] = fieldnmnst_st(corePar);

for j = 1:nbParFields
    if  ~isempty(strfind(parFields{j},'n_')) || ~isempty(strfind(parFields{j},'mu_')) || ~isempty(strfind(parFields{j},'d_'))
corePar   = rmfield_wtxt(corePar, parFields{j});
coreTxtPar.units = rmfield_wtxt(coreTxtPar.units, parFields{j});
coreTxtPar.label = rmfield_wtxt(coreTxtPar.label, parFields{j});
free = rmfield_wtxt(free, parFields{j});
    end
end
corePar.free = free;
printpar_st(corePar,coreTxtPar);
fprintf('\n')
  end
end

if results_output == 1 || results_output == 2
    
  par = par;
  filenm = ['results_', pets{1}, '.mat'];
  metaData = metaData.pet1;
  save(filenm, 'txtPar', 'par', 'metaPar', 'metaData');
  
end


if exist(['results_', pets{i}, '.m'], 'file')
      par = par;   % for the case with no zoom factor transformation
      eval(['results_', pets{i}, '(txtPar, par, metaPar, txtData.pet', ci, ', data.pet', ci, ');']);
    
else
    
      eval(['[nm nst] = fieldnmnst_st(data.pet', ci, ');']);
      for j = 1:nst
        eval(['[aux, k] = size(data.pet', ci, '.', nm{j}, ');']); % number of data points per set
        if k >= 2 && isempty(strfind(nm{j}, 'temp.'))
          figure;
          set(gca,'Fontsize',12)
          set(gcf,'PaperPositionMode','manual');
          set(gcf,'PaperUnits','points'); 
          set(gcf,'PaperPosition',[0 0 300 180]);%left bottom width height
          eval(['xdata = data.pet', ci, '.', nm{j}, '(:,1);']);
          eval(['ydata = data.pet', ci, '.', nm{j}, '(:,2);']);
          eval(['xpred = datapl.pet', ci, '.', nm{j}, '(:,1);']);
          eval(['ypred = prdData.pet', ci, '.', nm{j}, ';']);
          plot(xpred, ypred, 'b', xdata, ydata, '.r', 'Markersize',20, 'linewidth', 4)
          eval(['lblx = [char(txtData.pet', ci, '.label.', nm{j},'(1)), '', '', char(txtData.pet', ci, '.units.', nm{j},'(1))];']);
          xlabel(lblx);
          eval(['lbly = [char(txtData.pet', ci, '.label.', nm{j},'(2)), '', '', char(txtData.pet', ci, '.units.', nm{j},'(2))];']);
          ylabel(lbly);
        end
      end
end
 
if results_output == 2  

     
  for i = 1:length(pets)
    % produce par for species
    par = par;   % for the case with no zoom factor transformation
    
    % unpack par
    v2struct(par);
    ci = num2str(i);
    graphnm = ['results_', pets{i}, '_'];
    
      eval(['[nm nst] = fieldnmnst_st(data.pet', ci, ');']);
      counter = 1;
      for j = 1:nst
        eval(['[aux, k] = size(data.pet', ci, '.', nm{j}, ');']); % number of data points per set
        if k >= 2
          if counter < 10
            figure(counter)  
            eval(['print -dpng ', graphnm, '0', num2str(counter),'.png']);
          else
            figure(counter)  
            eval(['print -dpng ', graphnm, num2str(counter), '.png']);
          end
          counter = counter + 1;
        end
      end
  end
    fprintf('\n')
%   end
end


