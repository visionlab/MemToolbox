% MemToolbox demo 14: Fitting a model with one set of data and evaluating it
% with another
clear all;

data.errors = [-10, 2, 43, -2, 1, 100, 119, -34, 11];
data.n = [1, 1, 1, 3, 3, 3, 5, 5, 5]

dataWithout5 = RemoveDataByField(data, 'n', 5)

% Sample posterior given the data for two different models
continuousResourceSamps = MCMC(dataWithout5, ContinuousResourceModel)
slotPlusResourceSamps   = MCMC(dataWithout5, SlotsPlusResourcesModel)

% Visualize posterior predictive fits for each model
dataSetSize5 = GetDataByField(data, 'n', 5);
PlotPosteriorPredictiveData(ContinuousResourceModel, ...
                            continuousResourceSamps, dataSetSize5);
PlotPosteriorPredictiveData(SlotsPlusResourcesModel, ...
                            slotPlusResourceSamps, dataSetSize5);
