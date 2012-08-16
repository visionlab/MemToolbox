% MemToolbox demo 12: Analyzing multiple subjects
clear all;

% Fit multiple subjects independently
datasets{1} = MemDataset(1);
datasets{2} = MemDataset(2);
model = StandardMixtureModel();
fit = FitMultipleSubjects_MAP(datasets, model)

% Fit multiple subjects hierarchically
data1 = MemDataset(1);
data2 = MemDataset(2);
model = StandardMixtureModel();
fit = MemFit({data1,data2}, model)