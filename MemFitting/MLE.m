% MLE Find maximum likelihood fit of model to data
%
%    maxLikelihoodParameters = MLE(data, model)
%
function [maxLikelihood, like] = MLE(data, model)
  
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
    maxLikelihood = [];
    like = model.logpdf(data);
    return
  end
  
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have
  options = statset('MaxIter',50000,'MaxFunEvals',50000,...
    'UseParallel','always','FunValCheck','off');
  
  % Start the search at several different points (based on model.start)  
  numChains = size(model.start,1);
  for c=1:numChains
    % Maximize the likelihood function
    vals{c} = mle(data, 'logpdf', model.logpdf, 'start', model.start(c,:), ...
      'lowerbound', model.lowerbound, 'upperbound', model.upperbound, ...
      'options', options);
    
    % Store MLE value
    asCell = num2cell(vals{c});
    like(c) = model.logpdf(data, asCell{:});
  end
  
  % Combine values across chains
  likeSamples.vals = [vals{1}];
  likeSamples.like = like;
  for c=2:numChains
    likeSamples.vals = [likeSamples.vals; vals{c}];
  end
  
  % Find MLE estimate (best one across all the chains)
  [like,b]=max(likeSamples.like);
  maxLikelihood = likeSamples.vals(b,:);
end
