% WITHBIAS adds a bias terms to any model 
%
%  model = WithBias(model, [priorForMu])
%
% The first parameter is the model to convert; the second (optional)
% parameter is a function for the prior on mu. It takes a single argument,
% mu.
%
% Thus, to take the StandardMixtureModel, which has a guess rate (g) and
% standard deviation (sd), and add a shift term (mu), just use:
%   model = WithBias(StandardMixtureModel())
%
% This wrapper is compatible with both Orientation() and TwoAFC(). For
% example, the following works fine:
%   model = TwoAFC(WithBias(StandardMixtureModel());
%
function model = WithBias(model, priorForMu)
  % If no prior is specified, default to an improper uniform prior
  if nargin < 2
    priorForMu = @(p)(1);
  end
  
  % Take model and turn it into a model with a bias term
  model.name = [model.name ' with bias'];
  model.paramNames = {'mu', model.paramNames{:}};
  model.lowerbound = [-180 model.lowerbound];
  model.upperbound = [180 model.upperbound];
  model.movestd = [1 model.movestd];
  model.start = [rand(size(model.start,1),1)*10  model.start];
  
  % Adjust pdf and prior
  model.oldPdf = model.pdf;
  model.pdf = @NewPDF;
  model.oldPrior = model.prior;
  model.prior = @(p)(model.prior(p(2:end)) .* priorForMu(p(1)));
  
  % Adjust generator function
  if isfield(model, 'generator')
    model.oldGenerator = model.generator;
    model.generator = @(params,dims,displayInfo)(...
      wrap(model.oldGenerator(params(2:end), dims, displayInfo)+params{1}));
  end
  
  % Shift errors and/or changeSize 
  function p = NewPDF(data, mu, varargin)
    if isfield(data, 'errors')
      data.errors = wrap(data.errors - mu);
    end
    if isfield(data, 'changeSize')
      data.changeSize = wrap(data.changeSize - mu);
    end
    p = model.oldPdf(data, varargin{:});
  end
end

function t = wrap(t)
  t(t>180) = t(t>180) - 360;
  t(t<-180) = t(t<-180) + 360;
end
