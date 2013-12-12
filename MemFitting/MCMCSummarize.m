% MCMCSUMMARIZE Convert samples from MCMC into estimates of parameters
%
%  s = MCMCSummarize(posteriorSamples, whichField)
%
% Returns a struct with a .posteriorMean, .posteriorMedian, .maxPosterior,
%  .lowerCredible, .upperCredible.
%
% If you pass the optional second parameter whichField, it does not
% return a struct but instead returns only that one field. Possible values
% are: posteriorMean, posteriorMedian, maxPosterior, lowerCredible,
% upperCredible.
%
%  Examples:
%     posteriorSamples = MCMC(data, model);
%     posteriorMean = MCMCSummarize(posteriorSamples, 'posteriorMean');
%
%  or:
%     posteriorSamples = MCMC(data, model);
%     fit = MCMCSummarize(posteriorSamples);
%     fit.posteriorMean
%
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
