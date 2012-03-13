function MCMC_Example()
  close all;
  addpath('MemModels');
  addpath('Helpers');
  addpath('MemVisualizations');
    
  % Example data
  d = load('MemData/3000+trials_3items_SUBJ#1.mat');
  
  % Choose a model
  %model = StandardMixtureModel();
  %model = InfiniteScaleMixtureModel();
  %model = NoGuessingModel();
  %model = StandardMixtureModelWithBias();
  model = InfiniteScaleMixtureModelWithBias();
  
  % Run MCMC
  MCMCMemoized = MemoizeToDisk(@MCMC);
  [params, stored] = MCMCMemoized(d.data(:), model);
  
  % Maximum posterior parameters from MCMC
  disp('MAP from MCMC():');
  disp(params);
  
  % Make sure MCMC converged:
  % Trace plots and histograms should have similar means and variance
  % (e.g., should overlap). This shows that the chains that started in
  % different places all settled into the same ending distribution.
  h = MCMC_Convergence_Plot(stored, model.paramNames);
  subfigure(2,2,1, h);
  
  % Show a figure with each parameter's correlation with each other
  h = MCMC_Plot(stored, model.paramNames);
  subfigure(2,2,2, h);
  
  % Show fit
  h = PlotModelParametersAndData(model, stored, d.data(:));
  subfigure(2,2,3, h);
  
  % Posterior predictive
  h = PlotPosteriorPredictiveData(model, stored, d.data(:));
  subfigure(2,2,4, h);  
  
  % Get MLE parameters using search
  disp('MLE from mle():');
  MLEMemoized = MemoizeToDisk(@MLE);
  params_mle = MLEMemoized(d.data(:), model);
  disp(params_mle);
end

