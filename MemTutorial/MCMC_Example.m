function MCMC_Example()
  close all;
    
  % Example data
  data = load('MemData/3000+trials_3items_SUBJ#1.mat');
  
  % Choose a model
  model = StandardMixtureModel();
  %model = NoGuessingModel();
  %model = StandardMixtureModelWithBias();
  %model = InfiniteScaleMixtureModel('wrappednormal','gamma');
  %model = BinomialModel();
  
  % Run MCMC
  stored = MCMC_Convergence(data, model);
  params = MCMC_Summarize(stored, 'maxPosterior');

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
  h = PlotModelParametersAndData(model, stored, data);
  subfigure(2,2,3, h);
  
  % Posterior predictive
  h = PlotPosteriorPredictiveData(model, stored, data);
  subfigure(2,2,4, h);
  
  % Get MLE parameters using search
  disp('MLE from mle():');
  params_mle = MLE(data, model);
  disp(params_mle);
end

