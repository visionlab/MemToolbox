% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model

function model = StandardMixtureModelWithBiasSD()
  model.name = 'Standard mixture model with bias (parameterized by SD)';
	model.paramNames = {'mu', 'g', 'sd'};
	model.lowerbound = [-180 0 0]; % Lower bounds for the parameters
	model.upperbound = [180 1 Inf]; % Upper bounds for the parameters
	model.movestd = [1, 0.02, 1];
	model.pdf = @(data, mu, g, sd) ((1-g).*vonmisespdf(data.errors(:), ...
    mu,deg2k(sd)) + (g).*unifpdf(data.errors(:),-180,180));
	model.start = [10, .2, 20;  % mu, g, sd
                 0, .4, 15;  % mu, g, sd
                -10, .1, 30]; % mu, g, sd
  model.generator = @StandardMixtureModelWithBiasGenerator;
end

% achieves a 15x speedup over the default rejection sampler
function r = StandardMixtureModelWithBiasGenerator(parameters, dims)
    n = prod(dims); % figure out how many numbers to cook
    r = rand(n,1)*360 - 180; % fill array with blind guesses
    guesses = logical(rand(n,1) < parameters{2}); % figure out which ones will be guesses
    r(~guesses) = vonmisesrnd(parameters{1}, deg2k(parameters{3}), [sum(~guesses),1]); % pick rnds
    r = reshape(r, dims); % reshape to requested dimensions
end