% ModelComparison_BayesFactor - Compute Bayes Factor via Monte Carlo
% 
%  Log Bayes Factors can be interpreted as follows: (per Jeffreys (1961))
%   0 to 0.5  - not worth more than a mention
%   0.5 to 1  - substantial
%   1 to 2    - strong
%   >2        - decisive
%
% A Bayes factor is computed by asking how likely the data that was observed
% is, given the entire set of data the model can possibly predict. This 
% penalizes complex models -- having extra freedom means they can predict
% more different kinds of data, and thus each particular set of data is
% less likely. 
%
% To compute this we use Monte Carlo. Thus we draw samples from the
% prior of the model (e.g., choose 'random' values of its parameters), and
% then see how likely the data is under those parameters. Models that
% predict the data well over their entire possible space of parameters do
% well, and models that need very particular settings of their parameters
% to fit the data do poorly. This approximation method is quite accurate
% for small numbers of parameters (<~5) as in most models in use in
% MemToolbox.
%
% Examples:
% 
%  Take MemDataset(3), which in reality contains 20% 'swaps' with
%  distractors.
%  
%    data = MemDataset(3);
%    bf = ModelComparison_BayesFactorMonteCarlo(data, {StandardMixtureModel(), SwapModel()})
%  
%  Posterior odds of models:
%    0.00	  1.00	
%
%    bf = 
%            0      -46.489
%       46.489            0
%
%  This suggests entirely definitively that the SwapModel provides a better
%  fit, with a Bayes Factor preference of model 2 over model 1 (bf(2,1)) of
%  46.
%
%  Now scramble the distractors, meaning there are very few 'swaps':
%
%    data.distractors = Shuffle(data.distractors')'
%    bf = ModelComparison_BayesFactorMonteCarlo(data, {StandardMixtureModel(), SwapModel()})
%
%  Posterior odds of models:
%     0.84	  0.16	
%
%    bf =
%            0      0.71015
%     -0.71015            0
%
%   With no actual swaps in the data, the same process now reveals
%   substantial evidence for the StandardMixtureModel rather than the swap
%   model. This is because the SwapModel is penalized for its complexity
%   (all settings of B>0 result in poor fits to the data).
%

%---------------------------------------------------------------------
function [logBayesFactor,logPosteriorOdds,posteriorOdds] = ModelComparison_BayesFactor(data, models, varargin)
  args = struct('Verbosity', 1);
  args = parseargs(varargin, args);
  
  if length(models) < 2
    error('Model comparison requires a cell array of at least two models.');
  end
  
  % Make sure each of the models are well formed
  for m = 1:length(models)
    if ~isfield(models{m}, 'priorForMC')
      fprintf(['WARNING: Using a Bayes Factor with a very difuse prior, like ' ...
        'the defaults used for interference by MemToolbox, is nearly meaningless. It '...
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
  
  % Posterior odds of each model:
  posteriorOdds = 10.^(logPosteriorOdds - max(logPosteriorOdds));
  posteriorOdds = posteriorOdds ./ sum(posteriorOdds);
  
  if args.Verbosity > 0
    fprintf('\n  Posterior odds of models:\n    ');
    fprintf('%0.2f\t', posteriorOdds(:));
    fprintf('\n\n');
  end
  
  % Compute bayes factor for each model with respect to each other
  for m = 1:length(models)
    for m2 = 1:length(models)
      % Positive = pref for model m
      % Negative = pref for model m2
      logBayesFactor(m,m2) = logPosteriorOdds(m) - logPosteriorOdds(m2);
    end
  end
end
