clc;
clear all;

data = MemDataset(1);
data.errors = SampleFromModel(StandardMixtureModel, {.2, 20}, [1000 1]);
%data.errors = SampleFromModel(StandardMixtureModel('Bias', true), {10, .2, 20}, [1000 1]);

% Models
model{1} = EnsureAllModelMethods(StandardMixtureModel());
model{2} = EnsureAllModelMethods(StandardMixtureModel('Bias', true));

% Fix priors to be well-defined:
model{1}.upperbound = [1 80];
model{2}.upperbound = [180 1 80];
model{1}.prior = @(params) prod(unifpdf(params, model{1}.lowerbound', model{1}.upperbound'));
%model{2}.prior = @(params) prod(unifpdf(params, model{2}.lowerbound', model{2}.upperbound'));
model{2}.prior = @(params) prod([normpdf(params(1), 0, 10); ...
  unifpdf(params(2:end), model{2}.lowerbound(2:end)', model{2}.upperbound(2:end)')]);


% Get likelihoods:
fullPosterior{1} = GridSearch(data, model{1}, 'PointsPerParam', 25);
fullPosterior{2} = GridSearch(data, model{2}, 'PointsPerParam', 25);

% Get priors at each point:
for m=1:2
  Nparams = length(model{m}.paramNames);

  % Bayes factor: Average likelihood of each model, weighted by the prior
  maxLike = max(fullPosterior{m}.logLikeMatrix(:));
  wLogLike = fullPosterior{m}.logLikeMatrix - maxLike;
  curPrior = fullPosterior{m}.priorMatrix;
  wLogLike(isnan(wLogLike)) = 0;
  posteriorOdds(m) = maxLike + log(nansum(exp(wLogLike(:)).*curPrior(:)))
end

% Positive = pref for model 1
% Negative = pref for model 2
bayesFactor = posteriorOdds(1) - posteriorOdds(2)