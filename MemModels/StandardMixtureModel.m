% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model

function model = StandardMixtureModel()
	model.paramNames = {'g', 'K'};
	model.lowerbound = [0 0]; % Lower bounds for the parameters
	model.upperbound = [1 Inf]; % Upper bounds for the parameters
	model.movestd = [0.02, 0.1];
	model.pdf = @(data, g, K) ((1-g).*vonmisespdf(data,0,K) + (g).*unifpdf(data,-pi,pi));
	model.start = [.2, 10;  % g, K
                   .4, 15;  % g, K
                   .1, 20]; % g, K
    model.generator = @StandardMixtureModelGenerator;
end

% acheives a 15x speedup over the default rejection sampler
% calls the standardmixturemodel generator with mu=0
function r = StandardMixtureModelGenerator(parameters, dims)
    model = StandardMixtureModelWithBias();
    r = model.generator({0, parameters{1}, parameters{2}}, dims);
end