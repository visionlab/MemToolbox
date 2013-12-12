% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model
% with guess rate g and standard deviation sd.

function model = StandardMixtureModel_SD()
  model.name = 'Standard mixture model';
	model.paramNames = {'g', 'sd'};
	model.lowerbound = [0 0]; % Lower bounds for the parameters
	model.upperbound = [1 Inf]; % Upper bounds for the parameters
	model.movestd = [0.02, 0.1];
	model.pdf = @(data, g, sd) ((1-g).*vonmisespdf(data.errors(:),0,deg2k(sd)) + ...
                                (g).*1/360);
	model.start = [0.2, 10;  % g, sd
                 0.4, 15;  % g, sd
                 0.1, 20]; % g, sd
  model.generator = @StandardMixtureModelGenerator;

  % To specify a prior probability distribution, change and uncomment
  % the following line, where p is a vector of parameter values, arranged
  % in the same order that they appear in model.paramNames:
  % model.prior = @(p) (1);

end

% Achieves a 15x speedup over the default sampler
function r = StandardMixtureModelGenerator(parameters, dims, displayInfo)
  n = prod(dims); % figure out how many numbers to cook
  r = rand(n,1)*360 - 180; % fill array with blind guesses
  guesses = logical(rand(n,1) < parameters{1}); % figure out which ones will be guesses
  r(~guesses) = vonmisesrnd(0, deg2k(parameters{2}), [sum(~guesses),1]); % pick rnds
  r = reshape(r, dims); % reshape to requested dimensions
end
