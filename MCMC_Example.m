function MCMC_Example()
  addpath('MemModels');
  addpath('MemVisualizations');
    
  % Example data
  d = load('MemData/data.mat');
  
  % Choose a model
  model = StandardMixtureModel();
  
  % Run
  [params, stored] = MCMC(d.data(:), model);
  
  % Maximum likelihood parameters from MCMC
  disp('MLE from MCMC():');
  disp(params);
  
  % Show fit
  PlotData(model, params, d.data(:));
  
  % Show a figure with each parameter's correlation with each other
  MCMC_Plot(stored, model.paramNames);
  
  % Sanity check: Use mle() built-in function
  disp('MLE from mle():');
  params_mle = mle(d.data(:), ... % Data
    'pdf', model.pdf, ... % Likelihood function
    'start', model.start(1,:), ... % Start position
    'lowerbound', model.lowerbound, ... % Lower bound for the parameters
    'upperbound', model.upperbound);  % Upper bounds for the parameters
  disp(params_mle);
end

function PlotData(model, params, data)
  % Plot data fit
  figure;
  
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

