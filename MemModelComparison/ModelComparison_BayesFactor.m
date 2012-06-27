%---------------------------------------------------------------------
function [bayesFactor,fullPosterior] = ModelComparison_BayesFactor(data, models, varargin)
  
  if length(models) < 2
    error('Model comparison requires a cell array of at least two models.');
  end
  
  args = struct('PointsPerParam', 25);
  args = parseargs(varargin, args);
  
  % Make sure each of the models are well formed
  for m = 1:length(models)
    models{m} = EnsureAllModelMethods(models{m});
    models{m}.prior = models{m}.priorForMC;
  end
  
  % Get likelihoods
  for m = 1:length(models)
    fullPosterior{m} = GridSearch(data, models{m}, 'PointsPerParam', 25);
  end
  
  for m = 1:length(models)    
    % Bayes factor is the average likelihood of 
    % each model, weighted by the prior.
    maxLike = max(fullPosterior{m}.logLikeMatrix(:));
    wLogLike = fullPosterior{m}.logLikeMatrix - maxLike;
    curPrior = fullPosterior{m}.priorMatrix;
    wLogLike(isnan(wLogLike)) = 0;
    posteriorOdds(m) = maxLike + log(nansum(exp(wLogLike(:)).*curPrior(:)));
    
  end
  
  % compute bayes factor for each model with respect to the first model
  for m = 1:length(models)
    % Positive = pref for model 1
    % Negative = pref for model 2
    bayesFactor(m) = posteriorOdds(1) - posteriorOdds(m);
  end
end
