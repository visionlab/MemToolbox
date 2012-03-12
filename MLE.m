%MLE Find maximum likelihood fit for data
%    [params] = MLE(data, model)
%
%---------------------------------------------------------------------
function [params, stored] = MLE(data, model)
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have
  try, matlabpool, end
  
  numChains = size(model.start,1);
  for c=1:numChains
    vals{c} = mle(data, 'pdf', model.pdf, 'start', model.start(c,:), ...
        'lowerbound', model.lowerbound, 'upperbound', model.upperbound);
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
