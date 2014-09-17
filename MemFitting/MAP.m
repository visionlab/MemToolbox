% MAP Find maximum a posterior fit of model to data
%
%    maxPosteriorParameters = MAP(data, model)
%
function [maxPosterior, like] = MAP(data, model)
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have
  if license('test', 'optimization_toolbox')
    options = statset('MaxIter',50000,'MaxFunEvals',50000,...
      'UseParallel','always','FunValCheck','off');
  else
    options = statset('MaxIter',50000,'MaxFunEvals',50000,...
      'FunValCheck','off');    
  end

  % If they don't pass in a model, assume the standard mixture model.
  if nargin < 2
    model = StandardMixtureModel();
    fprintf('No model passed in. Assuming StandardMixtureModel().\n');
  end

  % If they pass in errors instead of a data struct, fix it for them.
  if(isnumeric(data))
    data = struct('errors', data);
  end

  % Make sure the model is all good:
  model = EnsureAllModelMethods(model);

  % Special case for model's with no free parameters at all
  if(isempty(model.start))
    maxPosterior = [];
    like = model.logpdf(data);
    return;
  end

  numChains = size(model.start,1);

  % Start the search at several different points (based on model.start)
  for c=1:numChains
    % Create a function that evaluates the posterior (prior*likelihood)
    logPosterior = @(data, varargin) (model.logpdf(data, varargin{:}) ...
      + model.logprior(cell2mat(varargin)));

    % Maximize this function
    vals{c} = mle(data, 'logpdf', logPosterior, 'start', model.start(c,:), ...
      'lowerbound', model.lowerbound, 'upperbound', model.upperbound, ...
      'options', options);

    % Store MAP value
    asCell = num2cell(vals{c});
    posterior(c) = model.logpdf(data, asCell{:}) ...
      + model.logprior(vals{c});
  end

  % Combine values across chains
  posteriorSamples.vals = [vals{1}];
  posteriorSamples.like = posterior;
  for c=2:numChains
    posteriorSamples.vals = [posteriorSamples.vals; vals{c}];
  end

  % Find MAP estimate (best one across all the chains)
  [like,b]=max(posteriorSamples.like);
  maxPosterior = posteriorSamples.vals(b,:);
end
