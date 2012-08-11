% WITHBIAS adds a bias terms to any model 
%
%  model = WithBias(model)
%
% e.g., to take the StandardMixtureModel, which has a guess rate (g) and
% standard deviation (sd), and add a shift term (mu), just use:
%   model = WithBias(StandardMixtureModel())
%
% This wrapper is compatible with both Orientation() and TwoAFC(). For
% example, the following works fine:
%   model = TwoAFC(WithBias(StandardMixtureModel());
%
function model = WithBias(model)
  % Take model and turn it into a model with a bias term
  model.name = [model.name ' with bias'];
  model.paramNames = {'mu', model.paramNames{:}};
  model.lowerbound = [-180 model.lowerbound];
  model.upperbound = [180 model.upperbound];
  model.movestd = [1 model.movestd];
  model.start = [rand(size(model.start,1),1)*10  model.start];
  
  model.oldPdf = model.pdf;
  model.pdf = @NewPDF;
  
  % Convert orientation data to a format that is useable in all the models
  function p = NewPDF(data, mu, varargin)
    data.errors = wrap(data.errors - mu);
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
