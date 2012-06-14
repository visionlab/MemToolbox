% Convert samples from MCMC into estimates of parameters
% - If you pass the optional second parameter whichField, it does not
% return a struct but instead returns only that one field. Possible values
% are posteriorMean, posteriorMedian, maxPosterior, lowerCredible,
% upperCredible
function params = MCMCSummarize(stored, whichField) 
  [~,highestLike]=max(stored.like);
  outParams.posteriorMean = mean(stored.vals);
  outParams.posteriorMedian = median(stored.vals);
  outParams.maxPosterior = stored.vals(highestLike,:);
  outParams.lowerCredible = quantile(stored.vals, 0.025);
  outParams.upperCredible = quantile(stored.vals, 0.975);
  if nargin < 2
    params = outParams;
  else
    params = outParams.(whichField);
  end
end