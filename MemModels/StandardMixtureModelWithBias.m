% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model

function model = StandardMixtureModelWithBias()
	model.paramNames = {'mu', 'g', 'K'};
	model.lowerbound = [-pi 0 0]; % Lower bounds for the parameters
	model.upperbound = [pi 1 Inf]; % Upper bounds for the parameters
	model.movestd = [0.01, 0.02, 0.1];
	model.pdf = @(data, mu, g, K) ((1-g).*vonmisespdf(data,mu,K) + (g).*unifpdf(data,-pi,pi));
	model.start = [0.01, .2, 10;  % g, K
                   0.00, .4, 15;  % g, K
                  -0.03, .1, 20]; % g, K
  model.generator = @StandardMixtureModelWithBiasGenerator;
end

% acheives a 15x speedup over the default rejection sampler
function r = StandardMixtureModelWithBiasGenerator(parameters, dims)
    n = prod(dims); % figure out how many numbers to cook
    r = rand(n,1)*2*pi - pi; % fill array with blind guesses
    guesses = logical(rand(n,1) < parameters{2}); % figure out which ones will be guesses
    r(~guesses) = vonmisesrnd(parameters{1}, parameters{3}, [sum(~guesses),1]); % pick rnds
    r = reshape(r, dims); % reshape to requested dimensions
end