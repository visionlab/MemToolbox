%MLE Find maximum likelihood fit for data
%    [params] = MLE(data, model)
%
%---------------------------------------------------------------------
function [params, stored] = MLE(data, model)
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have
  try matlabpool, end
  
  numChains = size(model.start,1);
  chainStored = [];
  parfor c=1:numChains
    chainStored(c).vals = mle(data, 'pdf', model.pdf, 'start', model.start(c,:), ...
        'lowerbound', model.lowerbound, 'upperbound', model.upperbound);
    asCell = num2cell(chainStored(c).vals);
    chainStored(c).like = sum(log(model.pdf(data, asCell{:})));
  end
  
  % Combine values across chains
  stored.vals = [chainStored(1).vals];
  stored.like = [chainStored(1).like];
  for c=2:numChains
    stored.vals = [stored.vals; chainStored(c).vals];
    stored.like = [stored.like; chainStored(c).like];
  end
  
  % Find MLE estimate
  [~,b]=max(stored.like);
  params = stored.vals(b,:);
end
