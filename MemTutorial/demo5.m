% MemToolbox demo 5: Model comparison
clear all;
data = MemDataset(1);

% First model:
model1 = StandardMixtureModel();
MemFit(data,model1);

% Second model:
model2 = WithBias(StandardMixtureModel);
MemFit(data,model2);

% Now compare:
MemFit(data, {model1, model2});