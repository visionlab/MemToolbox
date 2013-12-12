% MemToolbox demo 12: Analyzing multiple subjects
clear all;

% Fit multiple subjects independently
datasets{1} = MemDataset(1);
datasets{2} = MemDataset(2);
model = StandardMixtureModel();
fit = MemFit(datasets, model)

% Fit multiple subjects hierarchically
datasets{1} = MemDataset(1);
datasets{2} = MemDataset(2);
model = StandardMixtureModel();
fit = MemFit(datasets, model, 'UseHierarchical', true)
