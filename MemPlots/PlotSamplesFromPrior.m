%PLOTSAMPLESFROMPRIOR Show a model's prior by sampling from it
% This allows you to visualize the entire prior (what you 
% believe about the parameters, before you see any data).
%
%   figHand = PlotSamplesFromPrior(model, [optionalParameters])
%
% Optional parameters:
%  'NumSamples' - how many samples from the prior to take 
%
%  'UseModelComparisonPrior' - whether to use the normal diffuse prior for
%  the model (as used in estimation), model.prior (default), or whether to
%  use the prior used for computing Bayes Factors, model.priorForMC (if set
%  to true).
%
function figHand = PlotSamplesFromPrior(model, varargin)
  args = struct('NumSamples', 20000, 'UseModelComparisonPrior', false);
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
    'PostConvergenceSamples', args.NumSamples);
  figHand = PlotPosterior(priorSamples, model.paramNames);
end