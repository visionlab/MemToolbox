% MemToolbox demo 7: Cleaner plots of the posterior
clear all;
data = MemDataset(3);
model = StandardMixtureModel();
fit = MemFit(data, model);

fullPosterior = GridSearch(data, model, 'PosteriorSamples', fit.posteriorSamples);
PlotPosterior(fullPosterior, model.paramNames);
