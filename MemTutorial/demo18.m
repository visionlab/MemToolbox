% MemToolbox demo 18: Checking a model and sampling data
clear all;

% Test to see if we can recover some parameter values
model = WithBias(StandardMixtureModel);
paramsIn = {0, 0.1, 10}; % mu, g , sd
numTrials = [10 100 1000];
numItems = [3 5];
[paramsOut, lowerCI, upperCI] = ...
             TestSamplingAndFitting(model, paramsIn, numTrials, numItems)

% Simulate data
simulatedData.errors = SampleFromModel(StandardMixtureModel, [0.1 20], [1 500])

% Simulate data for models that require extra information
clear simulatedData;
numTrials = 9;
itemsPerTrial = [3 3 3 4 4 4 5 5 5];
simulatedData = GenerateDisplays(numTrials, itemsPerTrial);
params = [0.1, 0.1, 20];
errors = SampleFromModel(SwapModel, params, [1 numTrials], simulatedData);
simulatedData.errors = errors
