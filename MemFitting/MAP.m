% MAP Find maximum a posterior fit of model to data
%
%    maxPosteriorParameters = MAP(data, model)
%
%---------------------------------------------------------------------
function [maxPosterior, like] = MAP(data, model)
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have
  options = statset('MaxIter',5000,'MaxFunEvals',5000,'UseParallel','always');
  
  model = EnsureAllModelMethods(model);
  numChains = size(model.start,1);
  for c=1:numChains
    logPosterior = @(data, varargin) (model.logpdf(data, varargin{:}) ...
      + model.logprior(cell2mat(varargin)));
    vals{c} = mle(data, 'logpdf', logPosterior, 'start', model.start(c,:), ...
      'lowerbound', model.lowerbound, 'upperbound', model.upperbound, ...
      'options', options);
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
  
  % Find MAP estimate
  [like,b]=max(posteriorSamples.like);
  maxPosterior = posteriorSamples.vals(b,:);
end
