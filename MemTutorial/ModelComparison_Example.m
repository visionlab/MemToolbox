function ModelComparison_Example()
  % Example data
  data = load('MemData/data.mat');
  
  addpath('MemModels');
  model1 = StandardMixtureModel();
  model2 = NoGuessingModel();
  
  % Model comparison with cross validation
  %--------------------------------------------
  fprintf('CROSS VALIDATION\n-----------------------------------\n');
  
  [logLike, AIC, maxPosterior] = ModelComparison_CrossValidate(data, {model1, model2});
 
  disp('Log likelihood of models');
  fprintf('\t%0.f\n',logLike);
  fprintf('\n');
  
  disp('Relative model probabilities:');
  disp(exp((min(AIC)-AIC)/2));
  
  disp('AIC difference between models')
  disp('(Pos = Model 1 preferred, Neg = Model 2 preferred):');
  disp(AIC(2) - AIC(1));
  
  disp('Best parameters:');
  disp(maxPosterior);
  
  % Show fits
  PlotModelFit(model1, maxPosterior{1}, data, 'NewFigure', true);
  PlotModelFit(model2, maxPosterior{2}, data, 'NewFigure', true);
  
  % Model comparison with Bayes factor 
  %--------------------------------------------
  fprintf('BAYES FACTOR \n-----------------------------------\n');
  % Run
  [MD, maxPosterior, posteriorSamples] = ModelComparison_BayesFactor(data, {model1, model2});
 
  disp('Log likelihood of models');
  for i=1:length(posteriorSamples)
      fprintf('\t%0.f\n',max(posteriorSamples{i}.like));
  end
  fprintf('\n');
  
  disp('Proportion model preferred:');
  disp(MD);
  
  disp('Log Bayes factor');
  disp('(Pos = Model 1 preferred, Neg = Model 2 preferred, >1 is good evidence, >3 strong evidence):');
  disp(log(MD(1))-log(MD(2)));
  
  disp('Best parameters:');
  disp(maxPosterior);
  
  % Show fits
  PlotModelFit(model1, maxPosterior{1}, data, 'NewFigure', true);
  PlotModelFit(model2, maxPosterior{2}, data, 'NewFigure', true);
  
  % Show figures with each parameter's correlation with each other
  PlotPosterior(posteriorSamples{1}, model1.paramNames);
  PlotPosterior(posteriorSamples{2}, model2.paramNames);
  
  keyboard
end


