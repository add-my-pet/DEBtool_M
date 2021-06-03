%% generate_statistics
% Finds parameter values for a pet that minimizes the lossfunction using the 
% Linear Succes History Adaptation of Differential Evolution (L-SHADE) using a filter
%%
function [statistics] = generate_statistics(data)
   % created 2020/03/18 by Juan Francisco Robles; 
   % modified 2020/03/19, 2020/06/08 by Juan Francisco Robles, 
   %   

   %% Syntax
   % [statistics] = <../generate_statistics.m *generate_statistics*> (data)

   %% Description
   % Calculates statistics from multimodal algorithm outputs. 
   % 
   % For the fitness and parameter values of the solutions returned by the
   % multimodal algorithms: 
   %
   % 1) The cardinality (number of solutions found during calibration
   % process). 
   % 2) The average and standard deviation for the finess of the set of 
   % solutions found.
   % 3) The average and standard deviation distance among solutions.
   %
   % For the parameter configurations of the solutions: 
   %
   % 1) The average value of each calibrated parameter. 
   % 2) The standard deviation of each calibrated parameter. 
   % 3) The spread of each calibrated parameter. 
   % 4) The mininum of each calibrated parameter.
   % 5) The maximum of each calibrated parameter.
   % 6) Kurtosis. 
   % 7) Skewness.
   % 8) Bimodality coefficient. 
   %
   % Input
   %
   % * data: the result values obtained by the multimodal algorithm used 
   %         for calibration. This structure contains: 
   % * * The number of solutions. 
   % * * The parameter configuration for each solution. 
   % * * The fitness value of these solutions. 
   %
   % Output
   % 
   % * statistics: the values for the calculated statistics. If report 
   %               function is called then the output results in an struct
   %               where fields are: 
   % 
   %                 
   %                |- Cardinality
   % * * 1) fitness |- Average fitness
   %                |- Standard deviation of fitness
   %                |- Average distance
   %
   %
   %                   |- Average value
   %                   |- Standar deviation
   %                   |- Spread
   % * * 2) parameters |- Minimum
   %                   |- Maximum
   %                   |- Kurtosis
   %                   |- Skewness
   %                   |- Bimodality coefficient
   %
   %% EXAMPLE
   %% generate_statistics(archive);
   % Returns an struct with two fields: 
   %
   % * fitness
   % * parameters 
   %
   % which contain the statistics from the solutions file. 
   %% Deciaml format values
   format long;
   
   %% Prepare structures
   statistics = struct;
   
   % Settings fields into statistics struct
   statistics.fitness = struct; 
   statistics.parameters = struct; 
   
   %% Setting subfield values
   % Fitness
   statistics.fitness.cardinality = cardinality(data);
   statistics.fitness.mean = mean_fitness(data);
   statistics.fitness.std = std_fitness(data);
   statistics.fitness.average_distance_fitness = average_distance_fitness(data);
   % Parameters
   statistics.parameters.mean = mean_params(data);
   statistics.parameters.std = std_params(data);
   statistics.parameters.spread = spread(data);
   statistics.parameters.minimum = minimum_params(data);
   statistics.parameters.maximum = maximum_params(data);
   statistics.parameters.kurtosis = kurtosis_params(data);
   statistics.parameters.skewness = skewness_params(data);
   statistics.parameters.bimodal_coefficient = bimodal_coefficient_params(data);

   %% Methods for fitness values
   % Calculates and returns the cardinality of the solutions set. 
   function value = cardinality(data)
      disp(data);
      if isfield(data, 'funvalues')
         value = length(data.funvalues);
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   % Calculates and returns the average fitness of the solutions set. 
   function value = mean_fitness(data)
      if isfield(data, 'funvalues')
         value = mean(data.funvalues);
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   % Calculates and returns the standard deviation for the fitness of the 
   % solutions set. 
   function value = std_fitness(data)
      if isfield(data, 'funvalues')
         value = std(data.funvalues);
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   
   % Calculates and returns the average distance for the fitness of the 
   % solutions set. 
   function value = average_distance_fitness(data)
      if isfield(data, 'funvalues')
         value = norm(data.funvalues)/length(data.funvalues);
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end

   %% Methods for parameter configurations
   % Calculates and returns the average values of the parameters solutions 
   % set.
   function values = mean_params(data)
      if isfield(data, 'pop')
         values = mean(data.pop(:,:));
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   % Calculates and returns the standard deviation values of the parameters
   % solutions set.
   function values = std_params(data)
       if isfield(data, 'pop')
         values = std(data.pop(:,:));
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   % Calculates and returns the spread (dispersion measure calculated as 
   % the diference between the maximum and minimum value of each calibrated
   % parameter) of the parameters solutions set.
   function values = spread(data)
      if isfield(data, 'pop')
         values = max(data.pop(:,:)) - min(data.pop(:,:));
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   % Calculates and returns the minimum values of the parameters solutions 
   % set.
   function values = minimum_params(data)
       if isfield(data, 'pop')
         values = min(data.pop(:,:));
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   % Calculates and returns the maximum values of the parameters solutions 
   % set.
   function values = maximum_params(data)
       if isfield(data, 'pop')
         values = max(data.pop(:,:));
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   % Calculates and returns the kurtosis values of the parameters solutions 
   % set. 
   % *Kurtosis*: Also known as the fourth standarized moment, it is an 
   % indicator of how peaked the data distribution is. A high Kurtosis
   % value indicates that the distribution has a sharp peak with long and
   % fal tails. 
   function values = kurtosis_params(data)
       if isfield(data, 'pop')
         values = kurtosis(data.pop(:,:));
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   % Calculates and returns the skewness values of the parameters solutions 
   % set.
   % *Skewness*: It measures the asymetry of the distribution and some
   % modality characteristics. A negative skew (left) has fewer low values
   % and a positive (rigth) has fewer large values. 
   function values = skewness_params(data)
       if isfield(data, 'pop')
         values = skewness(data.pop(:,:));
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
   % Calculates and returns the bimodal coefficient values of the 
   % parameters solutions set.
   % Bimodal coefficient (BC): This measure can help together with other
   % measures such as the skewness, to measure the multimodality of the
   % parameter distribution. Empirical values of the bimodal coefficient
   % (BC > 0.555) can be considered to indicate multimodality: higher
   % numbers point toward multimodality whereas lower numbers point toward
   % unimodality. 
   function values = bimodal_coefficient_params(data)
       if isfield(data, 'pop')
         skew = skewness_params(data);
         kurt = kurtosis_params(data);
         values = ((skew(:,:).^2) + 1)./(kurt(:,:) + ((3.*(length(data.pop)-1).^2)/((length(data.pop)-2).*(length(data.pop)-3))));
      else
         fprintf('There are not values to calculate this measure. \n Please, revise your data before to try again.');
      end
   end
end