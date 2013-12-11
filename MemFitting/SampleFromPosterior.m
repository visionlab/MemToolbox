% SAMPLEFROMPOSTERIOR turn a fullPosterior into a posteriorSamples by sampling
% from it.
%
%  posteriorSamples = SampleFromPosterior(fullPosterior, numSamples)
%
% This function takes the output of GridSearch and converts it into the
% equivalent of what you would have gotten from MCMC.
%
% Example:
%  fullPosterior = GridSearch(data, model);
%  posteriorSamples = SampleFromPosterior(fullPosterior, 1000);
%
function posteriorSamples = SampleFromPosterior(fullPosterior, numSamples)
  whichLocs = randsample(numel(fullPosterior.propToLikeMatrix), ...
    numSamples, true, fullPosterior.propToLikeMatrix(:));
  [perParam{1:ndims(fullPosterior.logLikeMatrix)}] = ...
    ind2sub(size(fullPosterior.logLikeMatrix), whichLocs);
  posteriorSamples.like = fullPosterior.logLikeMatrix(whichLocs);
  for i=1:ndims(fullPosterior.logLikeMatrix)
    posteriorSamples.vals(:,i) = fullPosterior.valuesUsed{i}(perParam{i});
  end
end
