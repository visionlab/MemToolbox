% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model

function model = StandardMixtureModelWithBiasSD()
  model.name = 'Standard mixture model with bias (parameterized by SD)';
	model.paramNames = {'mu', 'g', 'sd'};
	model.lowerbound = [-pi 0 0]; % Lower bounds for the parameters
	model.upperbound = [pi 1 Inf]; % Upper bounds for the parameters
	model.movestd = [0.01, 0.02, 0.1];
	model.pdf = @(data, mu, g, sd) ((1-g).*vonmisespdf(data.errors(:),mu,sd2k(sd)) + ...
	                                  (g).*unifpdf(data.errors(:),-pi,pi));
	model.start = [0.1, .2, 0.3;  % mu, g, sd
                 0.0, .4, 0.25;  % mu, g, sd
                -0.1, .1, 0.20]; % mu, g, sd
  model.generator = @StandardMixtureModelWithBiasGenerator;
end

% achieves a 15x speedup over the default rejection sampler
function r = StandardMixtureModelWithBiasGenerator(parameters, dims)
    n = prod(dims); % figure out how many numbers to cook
    r = rand(n,1)*2*pi - pi; % fill array with blind guesses
    guesses = logical(rand(n,1) < parameters{2}); % figure out which ones will be guesses
    r(~guesses) = vonmisesrnd(parameters{1}, sd2k(parameters{3}), [sum(~guesses),1]); % pick rnds
    r = reshape(r, dims); % reshape to requested dimensions
end