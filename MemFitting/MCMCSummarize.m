% Convert samples from MCMC into estimates of parameters
% - If you pass the optional second parameter whichField, it does not
% return a struct but instead returns only that one field. Possible values
% are posteriorMean, posteriorMedian, maxPosterior, lowerCredible,
% upperCredible
function s = MCMCSummarize(posteriorSamples, whichField) 
  [tmp,highestLike]=max(posteriorSamples.like);
  outParams.posteriorMean = mean(posteriorSamples.vals);
  outParams.posteriorMedian = median(posteriorSamples.vals);
  outParams.maxPosterior = posteriorSamples.vals(highestLike,:);
  outParams.lowerCredible = quantile(posteriorSamples.vals, 0.025);
  outParams.upperCredible = quantile(posteriorSamples.vals, 0.975);
  if nargin < 2
    s = outParams;
  else
    s = outParams.(whichField);
  end
end