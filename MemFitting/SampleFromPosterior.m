% SampleFromPosterior - turn a fullPosterior into a posteriorSamples by
% sampling from it
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