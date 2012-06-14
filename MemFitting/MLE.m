%MLE Find maximum likelihood fit for data
%    maxPosterior = MLE(data, model)
%
%---------------------------------------------------------------------
function maxPosterior = MLE(data, model)
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have
  options = statset('MaxIter',5000, 'MaxFunEvals',5000,'UseParallel','always');
  
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
  posteriorSamples.vals = [vals{1}];
  posteriorSamples.like = like;
  for c=2:numChains
    posteriorSamples.vals = [posteriorSamples.vals; vals{c}];
  end
  
  % Find MLE estimate
  [~,b]=max(posteriorSamples.like);
  maxPosterior = posteriorSamples.vals(b,:);
end
