function result_pets_mmea(result, par, metaPar, txtPar, data, auxData, metaData, txtData, weights)
   % Save the best results data into solution set for printing or working
   % with them by using DEB modules.
   % results_pets(best_sol, metaPar, txtPar, data, auxData, metaData, txtData, weights);
   
   global results_filename results_display pets
     
   %% Save the unified solutions set. 
   %result = save_results(result, 'final', par, metaPar, txtPar, data, ..., 
   %    auxData, metaData, txtData, weights);
   %% Save solutions found for a latter analysis
   if exist('result', 'var') && ~isempty(result)
      if strcmp(results_filename, 'Default') ~= 0
         dtime = strsplit(datestr(datetime), ' ');
         auxtime = dtime{2}; auxtime([3 6 9]) = 'hms'; % Changing ':' time separators to h/m/s
         filename = ['solutionSet_', pets{1}, '_', dtime{1}, '_', auxtime]; % Filename with calibrated pet name and date; removed: strcat
      else
         filename = results_filename;
      end
      save(filename, 'result');
      disp('CALIBRATION PROCESS FINISHED CORRECTLY');
   end
   
   %% Print results depeding on results output parameter
   %plot_results(filename, results_display);
end