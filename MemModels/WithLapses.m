% WITHLAPSES adds a lapse ("inattentional") term to any model 
%
%  model = WithLapses(model, [priorForLapseRate])
%
% The first parameter is the model to convert; the second (optional)
% parameter is a function for the prior on the lapse rate. It takes a single 
% argument, lapseRate.
%
% Thus, to take the NoGuessingModel, which has a standard deviation (sd), 
% and add an additional lapse term (lapseRate), just use:
%   model = WithBias(NoGuessingModel())
%
% This wrapper is compatible with both Orientation() and TwoAFC(). For
% example, the following works fine:
%   model = TwoAFC(WithLapses(StandardMixtureModel());
%
function model = WithLapses(model, priorForLapseRate)
  % If no prior is specified, default to an improper uniform prior
  if nargin < 2
    priorForLapseRate = @(p)(1);
  end
  
  % Take model and turn it into a model with a bias term
  model.name = [model.name ' with lapses'];
  model.paramNames = {'Lapse rate', model.paramNames{:}};
  model.lowerbound = [0 model.lowerbound];
  model.upperbound = [1 model.upperbound];
  model.movestd = [0.02 model.movestd];
  model.start = [rand(size(model.start,1),1)  model.start];
  
  % Adjust pdf and prior
  model.oldPdf = model.pdf;
  model.pdf = @NewPDF;
  
  model.priorForLapseRate = priorForLapseRate;
  if isfield(model, 'prior')
    model.oldPrior = model.prior;
    model.prior = @(p)(model.oldPrior(p(2:end)) .* model.priorForLapseRate(p(1)));
  end
  
  if isfield(model, 'priorForMC')
    model.oldPriorForMC = model.priorForMC;
    model.priorForMC = @(p)(model.oldPriorForMC(p(2:end)) .* model.priorForLapseRate(p(1)));
  end

  % Shift errors and/or changeSize 
  function p = NewPDF(data, lapseRate, varargin)
    p = (1-lapseRate).*model.oldPdf(data, varargin{:}) + ...
          (lapseRate).*1/360;
  end
end