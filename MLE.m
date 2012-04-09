%MLE Find maximum likelihood fit for data
%    [params] = MLE(data, model)
%
%---------------------------------------------------------------------
function [params, stored] = MLE(data, model)
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have
  options = statset('MaxIter',2500, 'MaxFunEvals',2500,'UseParallel', 'always');
  numChains = size(model.start,1);
  parfor c=1:numChains
    vals{c} = mle(data, 'pdf', model.pdf, 'start', model.start(c,:), ...
        'lowerbound', model.lowerbound, 'upperbound', model.upperbound, ...
        'options', options);
    asCell = num2cell(vals{c});
    like(c) = sum(log(model.pdf(data, asCell{:})));
  end
  
  % Combine values across chains
  stored.vals = [vals{1}];
  stored.like = like;
  for c=2:numChains
    stored.vals = [stored.vals; vals{c}];
  end
  
  % Find MLE estimate
  [~,b]=max(stored.like);
  params = stored.vals(b,:);
end
