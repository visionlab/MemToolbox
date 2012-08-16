data = MemDataset(3);
model = StandardMixtureModel();
fit = MemFit(data, model);

fullPosterior = GridSearch(data, model, 'PosteriorSamples', fit.posteriorSamples);
PlotPosterior(fullPosterior, model.paramNames);
