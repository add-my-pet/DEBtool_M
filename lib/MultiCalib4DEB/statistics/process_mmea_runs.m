function final_stats = process_mmea_runs(results_file)

%% Load results file
load(results_file);

%% Get the number of runs
num_runs = sum(contains(fieldnames(result), 'run_'));

%% Run over the results
res.cardinality = [];
res.lf.min = [];
res.lf.mean = [];
res.lf.avg_dist = [];
res.MRE.min = [];
res.MRE.mean = [];
res.MRE.avg_dist = [];
res.SMSE.min = [];
res.SMSE.mean = [];
res.SMSE.avg_dist = [];

res.mean = [];
res.spread = []; 
res.minimum = [];
res.maximum = [];
res.kurtosis = [];
res.skewness = [];
res.bimodal_coefficient = [];

for run=1:num_runs
    st = generate_statistics(result.(['run_', num2str(run)]));
    %% Fitness
    res.cardinality = [res.cardinality; st.fitness.cardinality];
    res.lf.min = [res.lf.min; st.fitness.min];
    res.lf.mean = [res.lf.mean; st.fitness.mean];
    res.lf.avg_dist = [res.lf.avg_dist; st.fitness.average_distance_fitness];
    res.MRE.min = [res.MRE.min; st.fitness.min];
    res.MRE.mean = [res.MRE.mean; st.fitness.mean];
    res.MRE.avg_dist = [res.MRE.avg_dist; st.fitness.average_distance_fitness];
    res.SMSE.min = [res.SMSE.min; st.fitness.min];
    res.SMSE.mean = [res.SMSE.mean; st.fitness.mean];
    res.SMSE.avg_dist = [res.SMSE.avg_dist; st.fitness.average_distance_fitness];
    
    %% Parameters
    res.mean = [res.mean; st.parameters.mean];
    res.spread = [res.spread; st.parameters.spread];
    res.minimum = [res.minimum; st.parameters.minimum];
    res.maximum = [res.maximum; st.parameters.maximum];
    res.kurtosis = [res.kurtosis; st.parameters.kurtosis];
    res.skewness = [res.skewness; st.parameters.skewness];
    res.bimodal_coefficient = [res.bimodal_coefficient; st.parameters.bimodal_coefficient];
    
end

final_stats.fitness.stats_names = ["mean_cardinality", "std_cardinality"];
final_stats.fitness.stats_names = [final_stats.fitness.stats_names, "mean_min_lf", "std_min_lf", "mean_avg_lf", "std_svg_lf", "mean_lf_avg_dist"];
final_stats.fitness.stats_names = [final_stats.fitness.stats_names, "std_lf_avg_dist", "mean_min_MRE", "std_min_MRE", "mean_avg_MRE", "std_svg_MRE"];
final_stats.fitness.stats_names = [final_stats.fitness.stats_names, "mean_MRE_avg_dist", "std_MRE_avg_dist", "mean_min_SMSE", "std_min_SMSE", "mean_avg_SMSE"];
final_stats.fitness.stats_names = [final_stats.fitness.stats_names, "std_svg_SMSE", "mean_SMSE_avg_dist", "std_SMSE_avg_dist"];
final_stats.fitness.stats_values = [mean(res.cardinality), std(res.cardinality), mean(res.lf.min), std(res.lf.min), mean(res.lf.mean), std(res.lf.mean)];
final_stats.fitness.stats_values = [final_stats.fitness.stats_values, mean(res.lf.avg_dist), std(res.lf.avg_dist), mean(res.MRE.min), std(res.MRE.min)];
final_stats.fitness.stats_values = [final_stats.fitness.stats_values, mean(res.MRE.mean), std(res.MRE.mean), mean(res.MRE.avg_dist), std(res.MRE.avg_dist)]; 
final_stats.fitness.stats_values = [final_stats.fitness.stats_values, mean(res.SMSE.min), std(res.SMSE.min), mean(res.SMSE.mean), std(res.SMSE.mean)]; 
final_stats.fitness.stats_values = [final_stats.fitness.stats_values, mean(res.SMSE.avg_dist), std(res.SMSE.avg_dist)];

if num_runs > 1
    final_stats.mean_parameter_values = mean(res.mean);
    final_stats.std_parameter_values = std(res.mean);
    final_stats.mean_spread = mean(res.spread);
    final_stats.std_spread = std(res.spread);
    final_stats.mean_minimum = mean(res.minimum);
    final_stats.std_minimum = std(res.minimum);
    final_stats.mean_maximum = mean(res.maximum);
    final_stats.std_maximum = std(res.maximum);
    final_stats.mean_kurtosis = mean(res.kurtosis);
    final_stats.std_kurtosis = std(res.skewness);
    final_stats.mean_skewness = mean(res.skewness);
    final_stats.std_skewness = std(res.skewness);
    final_stats.mean_bimodal_coefficient = mean(res.bimodal_coefficient);
    final_stats.std_bimodal_coefficient = std(res.bimodal_coefficient);
else
    final_stats.mean_parameter_values = res.mean;
    final_stats.std_parameter_values = res.mean;
    final_stats.mean_spread = res.spread;
    final_stats.std_spread = res.spread;
    final_stats.mean_minimum = res.minimum;
    final_stats.std_minimum = res.minimum;
    final_stats.mean_maximum = res.maximum;
    final_stats.std_maximum = res.maximum;
    final_stats.mean_kurtosis = res.kurtosis;
    final_stats.std_kurtosis = res.skewness;
    final_stats.mean_skewness = res.skewness;
    final_stats.std_skewness = res.skewness;
    final_stats.mean_bimodal_coefficient = res.bimodal_coefficient;
    final_stats.std_bimodal_coefficient = res.bimodal_coefficient;
end


end