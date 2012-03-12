function MCMC_Example()
  close all;
  addpath('MemModels');
  addpath('MemVisualizations');
    
  % Example data
  d = load('MemData/3000+trials_3items_SUBJ#1.mat');
  
  % Choose a model
  %model = StandardMixtureModel();
  model = InfiniteScaleMixtureModel();
  
  % Run MCMC
  load InfiniteScale.mat
  %[params, stored] = MCMC(d.data(:), model);
  
  % Maximum posterior parameters from MCMC
  disp('MAP from MCMC():');
  disp(params);
  
  % Make sure MCMC converged:
  % Trace plots and histograms should have similar means and variance
  % (e.g., should overlap). This shows that the chains that started in
  % different places all settled into the same ending distribution.
  h = MCMC_Convergence_Plot(stored, model.paramNames);
  subfigure(2,3,1, h);
  
  % Show a figure with each parameter's correlation with each other
  h = MCMC_Plot(stored, model.paramNames);
  subfigure(2,3,2, h);
  
  % Show fit
  h = PlotData(model, params, d.data(:));
  subfigure(2,3,3, h);
  
  % Get MLE parameters using search
  disp('MLE from mle():');
  %params_mle = MLE(d.data(:), model);
  disp(params_mle);
  
  %save InfiniteScale.mat params stored params_mle
end

function figHand = PlotData(model, params, data)
  % Plot data fit
  figHand = figure;
  
  % Plot data histogram
  x = linspace(-pi, pi, 55)';
  n = histc(data, x);
  bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
  xlim([-pi pi]); hold on;
  palettablehistogram;
  
  % Plot scaled version of the prediction
  vals = linspace(-pi, pi, 500)';
  paramsAsCell = num2cell(params);
  p = model.pdf(vals, paramsAsCell{:});
  multiplier = length(vals)/length(x);
  plot(vals, p ./ sum(p(:)) * multiplier, 'b--', 'LineWidth', 2);
  xlabel('Error (radians)');
  ylabel('Probability');
end

