function ModelComparison_Example()
  % Example data
  data = load('MemData/data.mat');
  
  addpath('MemModels');
  model1 = StandardMixtureModel();
  model2 = NoGuessingModel();
  
  % Model comparison with cross validation
  %--------------------------------------------
  fprintf('CROSS VALIDATION\n-----------------------------------\n');
  
  [logLike, AIC, params] = ModelComparison_CrossValidate(data, {model1, model2});
 
  disp('Log likelihood of models');
  fprintf('\t%0.f\n',logLike);
  fprintf('\n');
  
  disp('Relative model probabilities:');
  disp(exp((min(AIC)-AIC)/2));
  
  disp('AIC difference between models')
  disp('(Pos = Model 1 preferred, Neg = Model 2 preferred):');
  disp(AIC(2) - AIC(1));
  
  disp('Best parameters:');
  disp(params);
  
  % Show fits
  PlotData(params{1}, data, model1.pdf);
  PlotData(params{2}, data, model2.pdf);
  
  % Model comparison with bayes factor 
  %--------------------------------------------
  fprintf('BAYES FACTOR \n-----------------------------------\n');
  % Run
  [MD, params, stored] = ModelComparison_BayesFactor(data, {model1, model2});
 
  disp('Log likelihood of models');
  for i=1:length(stored)
      fprintf('\t%0.f\n',max(stored{i}.like));
  end
  fprintf('\n');
  
  disp('Proportion model preferred:');
  disp(MD);
  
  disp('Log Bayes factor');
  disp('(Pos = Model 1 preferred, Neg = Model 2 preferred, >1 is good evidence, >3 strong evidence):');
  disp(log(MD(1))-log(MD(2)));
  
  disp('Best parameters:');
  disp(params);
  
  % Show fits
  PlotData(params{1}, data, model1.pdf);
  PlotData(params{2}, data, model2.pdf);
  
  % Show figures with each parameter's correlation with each other
  MCMC_Plot(stored{1}, model1.paramNames);
  MCMC_Plot(stored{2}, model2.paramNames);
  
  keyboard
end

% ------------------------------------------------------------------------
function PlotData(params, data, pdf)
  % Plot data fit
  figure;
  
  % Plot data histogram
  x = linspace(-pi, pi, 55)';
  n = histc(data.errors(:), x);
  bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
  xlim([-pi pi]); hold on;
  
  % Plot scaled version of the prediction
  vals = linspace(-pi, pi, 500)';
  asCell = num2cell(params);
  p = pdf(struct('errors', vals), asCell{:});
  multiplier = length(vals)/length(x);
  plot(vals, p ./ sum(p(:)) * multiplier, 'b--', 'LineWidth', 2);
  xlabel('Error (radians)');
  ylabel('Probability');
end


