function GridSearch_Example()
  data = MemDataset(3);
  model = StandardMixtureModel();

  % First do grid search over the entire parameter space:
  fullPosterior = GridSearch(data, model);

  % and visualize:
  h = PlotPosterior(fullPosterior, model.paramNames);
  subfigure(2,2,1,h);

  % Not very useful, right? Here's what it is really useful for.
  % First lets do MCMC to get some idea of the shape of the likelihood
  % function:
  posteriorSamples = MCMC(data, model);
  h = PlotPosterior(posteriorSamples, model.paramNames);
  subfigure(2,2,2,h);

  % Now lets refine the grid search to look only at reasonable values:
  model.upperbound = max(posteriorSamples.vals);
  model.lowerbound = min(posteriorSamples.vals);
  fullPosterior = GridSearch(data, model);
  h = PlotPosterior(fullPosterior, model.paramNames);
  subfigure(2,2,3,h);
end




