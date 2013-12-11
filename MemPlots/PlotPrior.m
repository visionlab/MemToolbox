%PLOTPRIOR Show a model's prior
% This allows you to visualize the entire prior (what you
% believe about the parameters, before you see any data).
%
%   figHand = PlotPrior(model)
function figHand = PlotPrior(model)

  priorModel = EnsureAllModelMethods(model);

  priorModel.pdf = @(data, varargin)(1);
  priorModel.logpdf = @(data, varargin)(0);
  priorSamples = MCMC([], priorModel, 'Verbosity', 0, ...
    'PostConvergenceSamples', 1000);
  fullPrior = GridSearch([], priorModel, 'PosteriorSamples', priorSamples);
  figHand = PlotPosterior(fullPrior, model.paramNames);
end
