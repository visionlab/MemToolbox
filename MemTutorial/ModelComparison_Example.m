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
  PlotModelFit(model1, params{1}, data, 'NewFigure', true);
  PlotModelFit(model2, params{2}, data, 'NewFigure', true);
  
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
  PlotModelFit(model1, params{1}, data, 'NewFigure', true);
  PlotModelFit(model2, params{2}, data, 'NewFigure', true);
  
  % Show figures with each parameter's correlation with each other
  PlotPosterior(stored{1}, model1.paramNames);
  PlotPosterior(stored{2}, model2.paramNames);
  
  keyboard
end


