% Compute Bayes Factor via Monte Carlo
ModelComparison_BayesFactorMonteCarlo(MemDataset(3), {StandardMixtureModel(), SwapModel()})

%---------------------------------------------------------------------
function [logBayesFactor,logPosteriorOdds] = ModelComparison_BayesFactor(data, models, varargin)
  args = struct('Verbosity', 1);
  args = parseargs(varargin, args);
  
  if length(models) < 2
    error('Model comparison requires a cell array of at least two models.');
  end
  
  % Make sure each of the models are well formed
  for m = 1:length(models)
    if ~isfield(models{m}, 'priorForMC')
      fprintf(['WARNING: Using a Bayes Factor with a very difuse prior, like ' ...
        'the defaults used for interference, is nearly meaningless. It '...
        'will *heavily* penalize the model with more parameters. Try setting ' ...
        'a priorForMC() function on your model with more reasonable priors.\n\n']);
    end
    models{m} = EnsureAllModelMethods(models{m});
    models{m}.prior = models{m}.priorForMC;
  end
  
  % Get samples from prior
  if args.Verbosity > 0
    fprintf('\nComparing %d models:\n', length(models));
  end
  for m = 1:length(models)
    if args.Verbosity > 0
      fprintf('  Sampling from prior of model %d: %s\n', m, models{m}.name);
    end
    priorModel = models{m};
    priorModel.pdf = @(data, varargin)(1);
    priorModel.logpdf = @(data, varargin)(0);
    priorSamples{m} = MCMC([], priorModel, 'Verbosity', 0, 'PostConvergenceSamples', 10000);
  end
  
  for m = 1:length(models)    
    % Bayes factor is the average likelihood of 
    % each model, weighted by the prior.
    if args.Verbosity > 0
      fprintf('   - calculating likelihoods for model %d: %s\n', m, models{m}.name);
    end
    for i=1:size(priorSamples{m}.vals,1)
      params = num2cell(priorSamples{m}.vals(i,:));
      logLike(i) = models{m}.logpdf(data, params{:});
    end
    summedLogLike = logsumexp(logLike'); % Returns log(sum(exp(a)))
    logAverageLike = summedLogLike -  log(size(priorSamples{m}.vals,1));
    logPosteriorOdds(m) = logAverageLike / log(10); % Convert to log base 10
  end
  
  if args.Verbosity > 0
    fprintf('\n  Posterior odds of models:\n    ');
    posteriorOdds = 10.^(logPosteriorOdds - max(logPosteriorOdds));
    posteriorOdds = posteriorOdds ./ sum(posteriorOdds);
    fprintf('%0.2f\t', posteriorOdds(:));
    fprintf('\n\n');
  end
  
  % Compute bayes factor for each model with respect to each other
  for m = 1:length(models)
    for m2 = 1:length(models)
      % Positive = pref for model 1
      % Negative = pref for model 2
      logBayesFactor(m,m2) = logPosteriorOdds(m) - logPosteriorOdds(m2);
    end
  end
end
