% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model,
% with mean MU, guess rate G, and precision Kappa (i.e., the concetration
% parameter of the von Mises distribution).

function model = StandardMixtureModelWithBiasKappa()
  model.name = 'Standard mixture model with bias';
  model.paramNames = {'mu', 'g', 'K'};
  model.lowerbound = [-180 0 0]; % Lower bounds for the parameters
  model.upperbound = [180 1 Inf]; % Upper bounds for the parameters
  model.movestd = [1, 0.02, 0.1];
  model.pdf = @(data, mu, g, K) ((1-g).*vonmisespdf(data.errors(:),mu,K) + ...
                                   (g).*unifpdf(data.errors(:),-180,180));
  model.start = [4.0, .2, 10;  % mu, g, K
                0.0, .4, 15;  % mu, g, K
               -4.0, .1, 20]; % mu, g, K
  model.generator = @StandardMixtureModelWithBiasGenerator;
end

% acheives a 15x speedup over the default rejection sampler
function r = StandardMixtureModelWithBiasGenerator(parameters, dims)
  n = prod(dims); % figure out how many numbers to cook
  r = rand(n,1)*360 - 180; % fill array with blind guesses
  guesses = logical(rand(n,1) < parameters{2}); % figure out which ones will be guesses
  r(~guesses) = vonmisesrnd(parameters{1}, parameters{3}, [sum(~guesses),1]); % pick rnds
  r = reshape(r, dims); % reshape to requested dimensions
end