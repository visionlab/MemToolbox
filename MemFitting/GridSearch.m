%GRIDSEARCH Calculate full posterior of parameters of model given data
%
%  fullPosterior = GridSearch(data, model, [optionalParameters])
%
% This fitting function  loops over reasonable values of each parameter
% and evaluates the likelihood and prior at those values. It then returns a
% posterior matrix whose size is N-dimensional for an N-parameter model
% (e.g., the full posterior, evaluated at discrete points on each parameter).
% The .logLikeMatrix is the log posterior; for visualization purposes, it
% is often useful to have a version of this that is proportional to the
% actual posterior rather than the log posterior. This is available as
% .propToLikeMatrix. The .valuesUsed contains the values at which
% each dimension/parameter was evaluated.
%
% Optional parameters:
%  'PointsPerParam' - how many bins to break up each model parameter into
%    Note that the posterior has to be evaluated at the full factorial of
%    the model parameters, so if you pass 25 and have a 4 parameter model
%    you will have 25^4 = 390,625 points that need to be evaluated.
%
%      fullPosterior = GridSearch(data, model, 'PointsPerParam', 25)
%
%  'PosteriorSamples' - if you have already run MCMC on this data, you can
%    pass the posteriorSamples you got back from MCMC to GridSearch. This
%    will allow GridSearch to smartly constrain the space it searchs, based
%    on the MCMC samples (Rather than the default of searching the full
%    range of parameters).
%
%      posSamples = MCMC(data, model)
%      fullPosterior = GridSearch(data, model, 'PosteriorSamples', posSamples)
%
%  'TakeSamplesFromPrior' - if you haven't run MCMC on this data, you can
%    choose to center the grid search by having GridSearch sample from the
%    prior on the parameters and choose upper and lower bounds accordingly.
%
%      fullPosterior = GridSearch(data, model, 'TakeSamplesFromPrior', true)
%
%    If you do not pass this parameter, GridSearch simply uses the
%    model.upperbound and model.lowerbound on parameters to center the search.
%
function fullPosterior = GridSearch(data, model, varargin)
  args = struct('MleParams', [], 'PosteriorSamples', [], ...
    ... % Default to 5000 total points
    'PointsPerParam', round(nthroot(5000, length(model.paramNames))), ...
    'TakeSamplesFromPrior', false);
  args = parseargs(varargin, args);

  % Ensure there is a model.prior, model.logpdf and model.pdf
  model = EnsureAllModelMethods(model);

  if ~isempty(args.PosteriorSamples)
      % Refine the grid search to look only at reasonable values:
      model.upperbound = max(args.PosteriorSamples.vals);
      model.lowerbound = min(args.PosteriorSamples.vals);
  end

  if args.TakeSamplesFromPrior && isempty(args.PosteriorSamples)
    % Sample from prior
    priorModel = model;
    priorModel.pdf = @(data, varargin)(1);
    priorModel.logpdf = @(data, varargin)(0);
    priorSamples = MCMC([], priorModel, 'Verbosity', 0, 'PostConvergenceSamples', 10000);
    model.upperbound = max(priorSamples.vals);
    model.lowerbound = min(priorSamples.vals);
  end

  % Use MAP parameters to center the grid search if any parameters have Inf
  % upper or lowerbound
  if isempty(args.MleParams) && (any(isinf(model.upperbound)) || any(isinf(model.lowerbound)))
    args.MleParams = MAP(data, model);
  end

  % Number of parameters
  Nparams = length(model.paramNames);

  % Figure out what values to search
  which = linspace(0,1,args.PointsPerParam);
  for i=1:Nparams
    if ~isinf(model.upperbound(i))
      MappingFunction{i} = @(percent) (model.lowerbound(i) ...
        + (model.upperbound(i)-model.lowerbound(i))*percent);
    else
      if isinf(model.lowerbound(i))
        error('Can''t have lower and upperbound of a parameter be Inf');
      else
        MappingFunction{i} = @(percent) (-log(1-(percent./1.01))*args.MleParams(i)*2);
      end
    end
    valuesUsed{i} = MappingFunction{i}(which);
  end

  % Convert to full factorial
  [allVals{1:Nparams}] = ndgrid(valuesUsed{:});

  % Evaluate
  logLikeMatrix = zeros(size(allVals{1}));
  parfor i=1:numel(allVals{1})
    curParams = cellfun(@(x)x(i), allVals);
    curParamsCell = num2cell(curParams);
    logLikeMatrix(i) = model.logpdf(data, curParamsCell{:}) ...
      + model.logprior(curParams(:));
  end
  fullPosterior.logLikeMatrix = logLikeMatrix;

  % Convert log likelihood matrix into likelihood, avoiding underflow
  fullPosterior.propToLikeMatrix = exp(logLikeMatrix-max(logLikeMatrix(:)));
  fullPosterior.propToLikeMatrix(isnan(fullPosterior.propToLikeMatrix)) = 0;

  % Store values used:
  fullPosterior.valuesUsed = valuesUsed;
end
