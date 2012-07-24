function model = EnsureAllModelMethods(model)
  % If no prior, just put a uniform prior on all parameters
  if ~isfield(model, 'prior')
    model.prior = @(params)(1);
  end
  
  % If no logpdf, create one from pdf
  if ~isfield(model, 'logpdf')
    model.logpdf = @(varargin)(nansum(log(model.pdf(varargin{:}))));
  end
  
  % If there's no model.pdf, create one using model.logpdf
  if ~isfield(model, 'pdf')
    model.pdf = @(varargin)(exp(model.logpdf(varargin{:})));
  end
  
  % If there's no model.priorForMC, use the uninformative prior
  if ~isfield(model, 'priorForMC')
    model.priorForMC = model.prior;
  end
end