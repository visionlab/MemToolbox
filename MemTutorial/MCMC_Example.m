function MCMC_Example()
  close all;
    
  % Example data
  data = MemDataset(1);
  
  % Choose a model
  model = StandardMixtureModel();

  % Run MCMC
  posteriorSamples = MCMC(data, model);
  maxPosterior = MCMCSummarize(posteriorSamples, 'maxPosterior');

  % Maximum posterior parameters from MCMC
  disp('MAP from MCMC():');
  disp(maxPosterior);
  
  % Make sure MCMC converged:
  % Trace plots and histograms should have similar means and variance
  % (e.g., should overlap). This shows that the chains that started in
  % different places all settled into the same ending distribution.
  h = PlotConvergence(posteriorSamples, model.paramNames);
  subfigure(2,2,1, h);
  
  % Show a figure with each parameter's correlation with each other
  h = PlotPosterior(posteriorSamples, model.paramNames);
  subfigure(2,2,2, h);
  
  % Show fit
  h = PlotModelParametersAndData(model, posteriorSamples, data);
  subfigure(2,2,3, h);
  
  % Posterior predictive
  h = PlotPosteriorPredictiveData(model, posteriorSamples, data);
  subfigure(2,2,4, h);
  
  % Get MLE parameters using search
  disp('MLE from mle():');
  maxPosterior_mle = MLE(data, model);
  disp(maxPosterior_mle);
end

