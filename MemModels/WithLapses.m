% WITHLAPSES adds a lapse ("inattentional") term to any model
%
%  model = WithLapses(model, [priorForLapseRate])
%
% The first parameter is the model to convert; the second (optional)
% parameter is a function for the prior on the lapse rate. It takes a single
% argument, lapseRate.
%
% The lapse parameter adds in the possibility that observers might
% randomly guess on some proportion of trials ('lapses'). This is
% functionally identical to the guess parameters that already exist in
% several models (e.g.,StandardMixtureModel).
%
% Thus, to take the NoGuessingModel, which has a standard deviation (sd),
% and add an additional lapse term (lapseRate), just use:
%
%   model = WithLapses(NoGuessingModel())
%
% This model would then be identical to the StandardMixtureModel (since
% it will consist of both an sd and guess parameter).
%
% This wrapper is compatible with both Orientation() and TwoAFC(). For
% example, the following works fine:
%
%   model = TwoAFC(WithLapses(NoGuessingModel()));
%
function model = WithLapses(model, priorForLapseRate)
  % If no prior is specified, default to an improper uniform prior
  if nargin < 2
    priorForLapseRate = @(p)(1);
  end

  % Warn if the model already has a guess rate or lapse rate. Note that the built-in
  % models that fit capacities/guesses across set sizes (which is distinct from lapses)
  % call those parameters 'capacity' and not 'g', so this should only warn about
  % parameters that are truly just lapses:
  if any(strcmp(model.paramNames, 'g')) || any(strcmp(model.paramNames, 'lapse'))
    fprintf(['Warning: You are adding a lapse parameter to a model that already ' ...
      'has one ("g", guess rate or "lapse"). This is almost certainly not what you ' ...
      'want to do, since the two parameters will trade-off perfectly.\n\n']);
  end

  % Take model and turn it into a model with a bias term
  model.name = [model.name ' with lapses'];
  model.paramNames = {'lapse', model.paramNames{:}};
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

  % Shift errors and/or changeSize
  function p = NewPDF(data, lapseRate, varargin)
    p = (1-lapseRate).*model.oldPdf(data, varargin{:}) + ...
          (lapseRate).*1/360;
  end
end
