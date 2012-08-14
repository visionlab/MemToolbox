% MODELCOMPARISON_BAYESFACTOR Compute Bayes Factor via Monte Carlo
% 
%  [logBayesFactor,logPosteriorOdds,posteriorOdds] = ...
%             ModelComparison_BayesFactor(data, models, [optionalParameters])
%
% A Bayes factor is computed by asking how likely the data that was observed
% is, given the entire set of data the model can possibly predict. This 
% penalizes complex models: having extra freedom means they can predict
% more different kinds of data, and thus each particular set of data is
% less likely. 
%
%  Log Bayes Factors can be interpreted as follows: (per Jeffreys, 1961)
%   0 to 0.5  - not worth more than a mention
%   0.5 to 1  - substantial
%   1 to 2    - strong
%   >2        - decisive
%
% To compute a Bayes Factor we use Monte Carlo. Thus we draw samples from 
% the prior of the model (e.g., choose 'random' values of its parameters), 
% and then see how likely the data is under those parameters. Models that
% predict the data well over their entire possible space of parameters do
% well, and models that need very particular settings of their parameters
% to fit the data do poorly. This approximation method for computing Bayes
% Factors is relatively accurate for small numbers of parameters (<~5) as  
% in most models in use in MemToolbox; in particular, it is accurate enough
% for the scale above (log units). However, Bayes factors should not be 
% considered to be precise.
%
% Computing a Bayes Factor depends on the prior of the model, since that is
% what specified how flexible the model is -- what data you could have seen
% if you generated it from this model. Thus, ModelComparison_BayesFactor
% makes use of a different, less diffuse prior, model.priorForMC, that you
% should specify for each of your models. In specifying this prior, you may
% want to make use of the PlotSamplesFromPrior function to visualize the
% prior you have specified.
%
%
% Example usage:
%  Take MemDataset(3), which in reality contains 20% 'swaps' with
%  distractors.
%  
%   data = MemDataset(3);
%   bf = ModelComparison_BayesFactor(data, {StandardMixtureModel(), SwapModel()})
%  
%  Posterior odds of models:
%    0.00	  1.00	
%
%    bf = 
%            0      -49.045
%       49.045            0
%
%  This suggests definitively that the SwapModel provides a better fit,
%  with a Bayes Factor preference of model 2 over model 1 (bf(2,1)) of
%  49.
%
%  Now scramble the distractors, meaning there are very few 'swaps':
%
%   data.distractors = Shuffle(data.distractors')';
%   bf = ModelComparison_BayesFactor(data, {StandardMixtureModel(), SwapModel()})
%
%  Posterior odds of models:
%     0.97	  0.03	
%
%    bf =
%            0       1.4581
%      -1.4581            0
%
% With no actual swaps in the data, the same process now reveals
% strong evidence for the StandardMixtureModel rather than the swap
% model. This is because the SwapModel is penalized for its complexity
% (all settings with swaps (e.g., B>0) result in poor fits to the data).
%
% Optional parameters:
%  'PosteriorSamples' - Calculating the Bayes Factors is done by using a 
%  t-distribution to approximate the posterior to choose the range of samples
%  from the prior. This requires running MCMC on each model, which in many
%  cases you will have already done. Thus, the function takes an optional
%  parameter 'PosteriorSamples', which is a cell array the same
%  length as the cell array of models that contains these samples. 
%
%  'NumSamples' - how many samples from the prior to take in order to
%  estimate the Bayes Factor. The default is 100,000. Increase this if you
%  get different Bayes Factors on subsequent runs of the same model
%  comparison, or if your model is particularly complex:
%
%    bf = ModelComparison_BayesFactor(data, {StandardMixtureModel(), ...
%           SwapModel()}, 'NumSamples', 150000);
%
function [logBayesFactor,logPosteriorOdds,posteriorOdds] = ...
    ModelComparison_BayesFactor(data, models, varargin)
  
  args = struct('Verbosity', 2, 'NumSamples', 100000, 'PosteriorSamples', []);
  args = parseargs(varargin, args);
  
  if length(models) < 2
    error('Model comparison requires a cell array of at least two models.');
  end
  
  % Make sure each of the models are well formed
  warned = false;
  for m = 1:length(models)
    if ~isfield(models{m}, 'priorForMC')
      fprintf(['\nWARNING: No priorForMC found in model ' num2str(m) '!\n']);
      if ~warned
        fprintf(['Bayes Factors, unlike estimation of parameters, \n' ...
        'are heavily influenced by your prior. Many of the models in \n'...
        'MemToolbox are specified with very diffuse priors, which \n'...
        'will penalize models with more parameters quite heavily. You may \n'...
        'want to set more reasonable priors (e.g., if your set \n'...
        'size is 2, your guess rate will probably be 0.1-0.4) before \n'...
        'examining Bayes Factors. To do so, specify a priorForMC()\n'...
        'function on your model. This prior will only be used in \n'...
        'calculating Bayes Factors, not doing estimation of parameters.\n\n']);
      end
      warned = true;
    end
    models{m} = EnsureAllModelMethods(models{m});
    models{m}.prior = models{m}.priorForMC;
    models{m}.logprior = @(p) sum(log(models{m}.priorForMC(p)));
    if isempty(args.PosteriorSamples)
      if args.Verbosity > 0
        fprintf('  Calculating posterior samples for model %d: %s\n', m, models{m}.name);
      end
      posteriorSamples{m} = MCMC(data, models{m}, ...
        'Verbosity', 0, 'PostConvergenceSamples', 1000);
    else
      posteriorSamples{m} = args.PosteriorSamples{m};
    end
  end
  
  % Compute importance functions
  for m=1:length(models)
    centerGaussian{m} = mean(posteriorSamples{m}.vals);
    covarGaussian{m} = cov(posteriorSamples{m}.vals); 
  end
  
  % Get samples from importance function
  for m=1:length(models)
    % mvtrnd converts to the cov matrix to a correlation matrix, so we have
    % to adjust the variances (and mean) later...
    importanceSamples{m} = mvtrnd(covarGaussian{m}, 5, args.NumSamples);
    rowBad = zeros(size(importanceSamples{m},1),1);
    for i=1:size(importanceSamples{m},2)
      % adjust variance/mean
      importanceSamplesRescaled{m}(:,i) = ...
        importanceSamples{m}(:,i).*sqrt(covarGaussian{m}(i,i)) + centerGaussian{m}(i);
      
      % throw out samples outside the bounds
      rowBad = rowBad | ...
        importanceSamplesRescaled{m}(:,i)>=models{m}.upperbound(i) | ...
        importanceSamplesRescaled{m}(:,i)<=models{m}.lowerbound(i);
    end
    if sum(rowBad)>length(rowBad)*0.20
      fprintf('  Warning: many samples were outside range of function, only using %d samples.\n', ...
        sum(rowBad));
    end
    importanceSamples{m}(rowBad,:) = [];
    importanceSamplesRescaled{m}(rowBad,:) = [];
  end
  
  % Calculate likelihood
  for m = 1:length(models)    
    if args.Verbosity > 0
      fprintf('  Calculating likelihoods for model %d: %s\n', m, models{m}.name);
    end
    parfor i=1:size(importanceSamples{m},1)
      logW(i) = models{m}.logprior(importanceSamplesRescaled{m}(i,:)) ...
        - log(mvtpdf(importanceSamples{m}(i,:), covarGaussian{m}, 5));
      params = num2cell(importanceSamplesRescaled{m}(i,:));
      logLike(i) = models{m}.logpdf(data, params{:});
    end
    summedLogLike = logsumexp(logLike' + logW'); % Returns log(sum(exp(a)))
    logAverageLike = summedLogLike -  logsumexp(logW');
    logPosteriorOdds(m) = logAverageLike / log(10); % Convert to log base 10
  end
  
  % Posterior odds of each model:
  posteriorOdds = 10.^(logPosteriorOdds - max(logPosteriorOdds));
  posteriorOdds = posteriorOdds ./ sum(posteriorOdds);
  
  if args.Verbosity > 1
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
