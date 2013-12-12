% ENSUREALLMODELMETHODS makes sure a model is complete with all pdf/prior functions
%
% model = EnsureAllModelMethods(model)
%
% This function is a helper function used by all the functions in
% MemFitting to ensure that all models have a .prior, .logprior, .pdf and
% .logpdf. .logpdf and .logprior are created from .pdf and .prior, if they
% do not exist. If nor prior is specified, .prior is assumed to be uniform
% over all parameters.
%
function model = EnsureAllModelMethods(model)
  % If no prior, just put a uniform prior on all parameters
  if ~isfield(model, 'prior')
    model.prior = @(params)(1);
  end

  % If there's no model.pdf, create one using model.logpdf
  if ~isfield(model, 'pdf')
    model.pdf = @(varargin)(exp(model.logpdf(varargin{:})));
  end

  % If no logpdf, create one from pdf
  if ~isfield(model, 'logpdf')
    model.logpdf = @(varargin)(sumWithNans(log(model.pdf(varargin{:}))));
  end

  % If no logprior, create one from prior
  if ~isfield(model, 'logprior')
    model.logprior = @(params)(sumWithNans(log(model.prior(params))));
  end
end

function s = sumWithNans(v)
  if any(~isnan(v))
    s = nansum(v);
  else
    s = NaN;
  end
end
