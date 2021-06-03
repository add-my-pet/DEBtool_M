![image](./MultiCalib4DEB/MC4DEB_logo.png) 
- - -
### Index of contents
* [What is MultiCalib4DEB?](#item1)
* [How can I use it?](#item2)
* [How to launch a process](#item3)
* [What options are available?](#item4)
* [What to do with the MultiCalib4DEB output?](#item5)
* [Further information](#item6)

<a name="item1"></a>
### What is this?
* * *
MultiCalib4DEB is a MATALB package which uses multimodal optimization for the calibration of dynamic energy budget models in DEBTools.

<a name="item2"></a>
### How can I use this package?
* * *
MultiCalib4DEB is developed for being used together with the DEBtools_M toolbox so, the first thing you need to start working with this package is to download the DEBtools_M (if you have not done it yet). You can do so from [here](https://github.com/add-my-pet/DEBtool_M).
You have a lot of information about DEBtools toolbox both in [its website](https://add-my-pet.github.io/DEBtool_M/docs/index.html) and in the [DEB Laboratory website](http://www.bio.vu.nl/thb/deb/deblab/)  

Then, clone or download the MultiCalib4DEB package from this website. 

Once you have both the MultiCalib4DEB toolbox and the MultiCalib4DEB, copy the entire MultiCalib4DEB package into the `lib` directory of DEBtools. 

From here, to use MultiCalib4DEB is as simple as setting the path to the DEBtools toolbox with `cd ../DEBtool_M/` and `addpath(genpath('.'))` or directly setting the entire path to the DEBtools toolbox `addpath(genpath('../DEBtool_M'))`. It is also possible to load both the DEBtool_M toolbox and the MultiCalib4DEB package separately with `addpath(genpath('../DEBtool_M/'))` and `addpath(genpath('../MultiCalib4DEB/'))`.

Now you are ready for use the package!

<a name="item3"></a>
## How can I launch a calibration with MultiCalib4DEB?
* * *

MultiCalib4DEB mimics the process that DEBtools uses for launching a calibration process so, for using the calibration module, you only need to load a pet in DEBtools style and then set some calibration options (its description is detailed in the [calibration options](#item4) section.

You have an example of how to launch a calibration with MultiCalib4DEB in the code below:

~~~
%% Calibrates the Clarias Gariepinus pet using SHADE multimodal algorithm
%% 

close all; 
global pets

% The pet to calibrate
pets = {'Clarias_gariepinus'};
% Check pet consistence
check_my_pet(pets); 

% Setting estimation options such as: 
% Loss function, method to use, filter, etc
estim_options('default');
% From where to get the initial parameter values
estim_options('init_pars_method', 2);
% Setting 'mm' (mmultimodal) for calibration 
calibration_options('method', 'mm1');
% Setting calibration options (number of runs, maximum function
% evaluations, ...) 
calibration_options('default'); 
% Set number of evaluations
calibration_options('max_fun_evals', 30000);
% Set value for individual generation ranges
calibration_options('gen_factor', 0.15); 
% Set if the initial guest from data is introduced into initial population
calibration_options('add_initial', 1); 
% Set if the best individual found will be refined with a local search
% method
calibration_options('refine_best', 1);
% Set if the bounds for the algorithm's first individuals population is
% taken from the data values or from pseudodata (1 -> data | 0 ->
% pseudodata average values)
calibration_options('bounds_from_ind', 1); 
% Verbose options
% Activate verbose
calibration_options('verbose', 1); 
calibration_options('verbose_options', 8); 
% Set calibration ranges
ranges.z = 0.4; % For a factor to the original parameter value. 
ranges.('f_tW') = [0.2, 0.32]; % For a desired range values. 
calibration_options('ranges', ranges);
% Calibrate
[best, info, out, best_favl] = calibrate;
~~~

<a name="item4"></a>
### Can I customize a calibration process?

The answer is YES! MultiCalib4DEB has some calibration options both to define and to interact with a calibration process. To do so, you only need to write `calibration_options('option_name', option_value)`. The complete list of cailbration options which MultiCalib4DEB considers is listed below: 

- **'method'**: The algorithm to use for parameter estimation. It can be `'SHADE'` (DEFAULT) or `'L-SHADE'`. Descriptions, code, and tests over the before-mentioned algorithms are available in its [author website](https://ryojitanabe.github.io/publication).
- **'num_results'**: The maximum number of results to maintain during the calibration process. Its number could be reduced after the calibration if there exist solutions with the same parameter values. **The minimum value for this option is 100 (DEFAULT) while the maximum is set to 500**. 
- **'max_fun_evals'**: The maximum number of function evaluations considered for the calibration process. **Its minimum value is 1,000. Its maximum value is 100,000. The DEFAULT value in 10,000**.
- **'max_calibration_time'**: The maximum time for the calibration process (**in minutes**). **The minimum value for this option is 60 minutes (DEFAULT) and its maximum value is 10,080 minutes (a week)**.
- **'num_runs'**: The number of independent runs to perform (each one with an independent random seed) through the parameter calibration process. **At least one (DEFAULT) run is required for the calibration process. The maximum number of independent runs is set to 15**.    
- **'gen_factor'**: It is a percentage value to build the ranges from where to generate the first set of solutions from the specie parameter values. **The minimum value for this option is 0.0 while the maximum is 2.0 (the DEFAULT value is 0.5)**. A value of 0.9 for this option means that, for an initial parameter value of 1.0, the range for generation is [(1 − 0.9)x1:0, 1.0x(1 + 0.9)]. Thus, the values for the first solutions parameters will be randomly selected from the range [0.1, 1.9].
- **'bounds_from_ind'**: It allows to select from where the parameters for the initial solutions are taken before to start the calibration process. There are two options: **0 to take the parameters from pet pseudo data values (if available) or 1 (DEFAULT) to take the parameters from the pet initial data values**. 
- **'add_initial'**: It is an option which allows to consider the first pet parameters into the initialization of the algorithm. **A value of 0 (DEFAULT) for this options means the parameter values are not selected. A value of 1 means they are considered**. 
- **'refine_best'**: An option to decide if the best solution is refined (by using a local search procedure) after the parameter estimation process. **A value of 0 (DEFAULT) discards the refinement process while a value of 1 activates it**. The refinement process is not considered into the maximum calibration time ('max_calibration_time') so the total calibration time increases if this parameter is selected. The refinement process runs while the calibration result improves so there is no a maximum time for this process.  
- **'verbose'**: If to print information about the best parameters found through the calibration process on screen. **0 means that verbose is deactivated (DEFAULT) while 1 means it is activated**.
- **'verbose_options'**: The number of solutions to print on screen. This parameter is used only when the verbose parameter is activated. **The minimum value for this option is 10 (DEFAULT) while the maximum value is limited to the 'num_results' option**.
- **'ranges'**: This option allows to define a set of ranges for all or for a part of the parameters which are selected for calibration. This parameter receives a pair parameter-range or parameter-percentage to define the minimum and maximum values allowed for the parameter(s). When a range [min., max.] is defined for a parameter, the values generated through the algorithms estimation cannot underpass/overpass the values which are set as minimum and maximum in the previous range. When a calibration value is under the minimum its value turns to the minimum value set into the range. When the value is over the maximum, then it changes to the maximum value. When a percentage is defined for a parameter, the minimum and maximum ranges for these parameter are calculated as [min = param. value x (1.0 − % value defined; max = param. value x (1.0 + % value defined)] 
- **'results_output'**: An option to print the results after the calibration process. 
    - **'Basic'**: Does not show results in screen but a summarizing of the best parameters in text mode on screen. This is the DEFAULT option.  
    - **'Best'**: Plots the best solution results using the DEBtools style 
- **'results_filename'**: An option for naming the results file. If the field is empty or it is not defined, the result filename is generated by default as 'results_' + 'pet_name_' + 'day-month-year_' + 'hour:min:secs'. If not, the results file will be named as set in this option. 
- **'mat_file'**: This option allows to define from which file to load the results from where to initialize the calibration parameters. This option is only considered if the DEBtool pars_init_method option is equal to 1 and if there is a previous result file. 
- 
<a name="item5"></a>
### What to do with the MultiCalib4DEB output?

When a MultiCalib4DEB process finishes, it returns a solutions file where the set with the best parameters combinations are stored in. Furthermore, the results file contains information about the loss function value for the results set, its parameter values, and some other information related with the parameters being calibrated. The fields a results object has is shown in the following table:

| **Field name** | **Description**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| NP             | The number of solutions the MultiCalib4DEB toolbox returns after the calibration process                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| pop            | The set of solutions returned after the calibration process. It contains $NP$ solutions, each of them containing a different set of calibration parameters (those which are free parameters in the pet parameters data file)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| funvalues      | The loss function values for each solution in $pop$                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| parnames       | The names of the parameters which were estimated through the calibration process. This is an information field which can be useful to work both with the statistics and charts modules the MultiCalib4DEB toolbox brings                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| results        | It is a MatLab struct field which contains both the general information about the pet whose parameters are calibrated and the specific information for each solution. All the calibration solutions are listed into this field as sub-fields with name "solution_ + solution_number" and contain the "par" and the "metaPar" files with the parameters of the pet in DEBtools M format. Then, the general information is stored below the specific one and contains the "data", "auxData", "txtPar", "metaData", "txtData", and "weights" also in DEBtools M format. The information into this field makes it easy to continue working with one or a set of results after the calibration process. Moreover, the solutions into the 'results' field can be used to generate reports later by using the _results_ module of MultiCalib4DEB | 

MultiCalib4DEB is prepared to work with the above-mentioned information both to generate statistical tests and to visualize the results. For this purposes, MultiCalib4DEB has two modules: `statistics` and `charts`. The options for these modules, some examples, and outputs are shown below: 

| Method       | Option             | Description                                                                                                                                                                                                                                                                                     |
|--------------|--------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|              | density_hm         | Plots a heat map with the distribution of the loss function values from the MultiCalib4DEB results output in a two-dimensional search space. The final heat map is plotted for a pair of calibration parameters                                                                                 |
|              | density_hm_scatter | Plots a heat map (such as in density_hm together with an scatter plot in which the values for the pair of parameters being selected is represented                                                                                                                                              |
| plot_chart   | scatter            | Plots an scatter plot with the values for a pair of parameters from the calibration results returned by MultiCalib4DEB                                                                                                                                                                          |
|              | weighted_scatter   | Plot an scatter (such as in scatter) in which the parameter values are weighted by using its loss function value                                                                                                                                                                                |
|              | density_scatter    | Plot an scatter (such as in scatter) in which each point is colored by the spatial density of nearby points. The function uses the kernel smoothing function to compute the probability density estimate for each point                                                                         |
|              | prediction         | Plots a prediction plot, the default plot the DEBtools M toolbox returns after an calibration process                                                                                                                                                                                           |
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|              | Basic              | Plots prediction results to screen                                                                                                                                                                                                                                                              |
| plot_results | Best               | Plots the calibration from the parameters of the best solution to screen                                                                                                                                                                                                                        |
|              | Set                | Plots a grouped calibration for the whole results set together with the average MRE and SMSE to screen |
|              | Complete           | Plots options Basic, Best, and Set together                                                                                                                                                                                                                                                     |

Two usage examples of the latter options are: 

- **`plot_chart` example**
~~~
global pets 

% The pet to calibrate
pets = {'Clarias_gariepinus'};
% Check pet consistence
check_my_pet(pets);

[data, auxData, metaData, txtData, weights] = mydata_pets; % Get pet data

% Load the solution set (example for Clarias Gariepinus). 
load('solutionSet_Clarias_gariepinus_20-Apr-2021_20:42:00.mat');

% Plot the chart!
plot_chart(solutions_set, 'density_hm', {'kap'; 'E_G'}, true, 20);
~~~

- **`plot_results` example**
~~~
global pets 

pets = {'Clarias_gariepinus'}; % The pet to calibrate
check_my_pet(pets); % Check pet consistence

% Get pet data
[data, auxData, metaData, txtData, weights] = mydata_pets;

% Load the solution set (example for Clarias Gariepinus). 
load('solutionSet_Clarias_gariepinus_20-Apr-2021_20:42:00.mat')

% Plot the solutions!
plot_results(solutions_set, solutions_set.results.txtPar, ...,
             solutions_set.results.data, ...,
             solutions_set.results.auxData, metaData, ..., 
             solutions_set.results.txtData, weights, 'Set');
~~~
The first example shows how to use the `plot_chart` method to plot a heat map for parameters "kap" and "E_G" from a results object over the "Clarias_gariepinus" DEBtools base pet by using the 'density_hm' option. The second example shows how to launch the `plot_results` method to plot a report over the set of solutions from the same results object by using the 'Set' option.

As mentioned at the beginning of this section, it is possible to launch an statistical analysis over the MultiCalib4DEB results. How to use and what to obtain from the MultiCalib4DEB `statistics` module is shown below:

~~~
% Load the results file
load('solutionsSet_Clarias_gariepinus.mat'); 
% Generate the statistics report
statistics_report = generate_statistics(solutions_set); 
~~~
The result of the last command (fields of the statistical analysis results and its values) can be seen in the next image.
![image](./MultiCalib4DEB/examples/statistical_analysis_example.png) 

<a name="item6"></a>
### Further information

- This project has been developed in MATLAB (v.9.2.0.538062 (R2017a))
- Test over this package have been performed over Ubuntu 20.04.2 LTS in an Intel(R) Core(TM) i5-7500 CPU @ 3.40GHz machine with 16GB of RAM memory. 
- A Journal article about this package is on the way. 

THANKS FOR USING THIS PACKAGE!
