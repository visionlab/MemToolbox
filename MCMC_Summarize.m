% Convert samples from MCMC into estimates of parameters
function params = MCMC_Summarize(stored) 
  [~,highestLike]=max(stored.like);
  params.posteriorMean = mean(stored.vals);
  params.posteriorMedian = median(stored.vals);
  params.maxPosterior = stored.vals(highestLike,:);
  params.lowerCredible = quantile(stored.vals, 0.025);
  params.upperCredible = quantile(stored.vals, 0.975);
end