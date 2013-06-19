% MemToolbox demo 13: Comparing data across conditions
clear all;

% Splitting a dataset by condition
data.errors = [-89, 29, -2, 6, -16, 65, 43, -12, 10, 0, 178, -42, 52, 1];
data.condition = [1 1 1 1 1 1 1 2 2 2 2 2 2 2];
[datasets, conditionOrder] = SplitDataByCondition(data);
datasets{1}
datasets{2}

[datasets, conditionOrder] = SplitDataByField(data, 'condition');

model = StandardMixtureModel();

% Create sample data sets
clear data;
data.errors(1:200) = SampleFromModel(model, [0.1, 20], [1 200]);
data.errors(201:400) = SampleFromModel(model, [0.3, 30], [1 200]);
data.condition(1:200) = 1;
data.condition(201:400) = 2;

[datasets, conditionOrder] = SplitDataByCondition(data);
for i=1:length(datasets)
  posteriorSamples{i} = MCMC(datasets{i}, StandardMixtureModel);
end

PlotPosteriorComparison(posteriorSamples, model.paramNames)

% Make data
clear data;
for sub=1:8
  data{sub}.errors(1:200) = SampleFromModel(model, [0.1, 20], [1 200]);
  data{sub}.errors(201:400) = SampleFromModel(model, [0.3, 30], [1 200]);
  data{sub}.condition(1:200) = 1;
  data{sub}.condition(201:400) = 2;
end

for sub=1:8
  [datasets, conditionOrder] = SplitDataByCondition(data{sub});
  for cond=1:length(datasets)
    params{cond}(sub,:) = MAP(datasets{cond}, model);
  end
end

PlotShift(params{1}, params{2}, model.paramNames);
