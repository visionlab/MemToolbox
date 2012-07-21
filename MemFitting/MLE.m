% MLE - Find maximum likelihood fit of model to data
%
%    maxLikelihood = MLE(data, model)
%
%---------------------------------------------------------------------
function [maxLikelihood, like] = MLE(data, model)
  
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have
  options = statset('MaxIter',5000,'MaxFunEvals',5000,'UseParallel','always');
  
  model = EnsureAllModelMethods(model);
  numChains = size(model.start,1);
  for c=1:numChains
    vals{c} = mle(data, 'logpdf', model.logpdf, 'start', model.start(c,:), ...
      'lowerbound', model.lowerbound, 'upperbound', model.upperbound, ...
      'options', options);
    asCell = num2cell(vals{c});
    like(c) = model.logpdf(data, asCell{:});
  end
  
  % Combine values across chains
  likeSamples.vals = [vals{1}];
  likeSamples.like = like;
  for c=2:numChains
    likeSamples.vals = [likeSamples.vals; vals{c}];
  end
  
  % Find MLE estimate
  [like,b]=max(likeSamples.like);
  maxLikelihood = likeSamples.vals(b,:);
end
