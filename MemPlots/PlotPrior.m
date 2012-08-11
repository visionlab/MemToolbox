%PLOTPRIOR Show a model's prior
% This allows you to visualize the entire prior (what you 
% believe about the parameters, before you see any data).
%
%   figHand = PlotPrior(model, [optionalParameters])
%
% Optional parameters:
%
%  'UseModelComparisonPrior' - whether to use the normal diffuse prior for
%  the model, model.prior (default), or whether to use the prior used for 
%  computing Bayes Factors, model.priorForMC (if set to true).
%
function figHand = PlotPrior(model, varargin)
  args = struct('UseModelComparisonPrior', false);
  args = parseargs(varargin, args);
  
  if args.UseModelComparisonPrior && ~isfield(model, 'priorForMC')
   fprintf(['WARNING: You said to use the model comparison prior (priorForMC),\n'...
     'but the model you specified does not include such a prior. We will \n'...
     'instead show samples from the normal prior.']);
  end
  
  priorModel = EnsureAllModelMethods(model);
    
  if args.UseModelComparisonPrior
    priorModel.prior = priorModel.priorForMC;
    priorModel.logprior = @(p) sum(log(priorModel.priorForMC(p)));
  end
  
  priorModel.pdf = @(data, varargin)(1);
  priorModel.logpdf = @(data, varargin)(0);
  priorSamples = MCMC([], priorModel, 'Verbosity', 0, ...
    'PostConvergenceSamples', 1000);
  fullPrior = GridSearch([], priorModel, 'PosteriorSamples', priorSamples);
  figHand = PlotPosterior(fullPrior, model.paramNames);
end