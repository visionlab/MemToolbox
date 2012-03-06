% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model

function model = StandardMixtureModelWithBias()
	model.paramNames = {'mu', 'g', 'K'};
	model.lowerbound = [0 0 0]; % Lower bounds for the parameters
	model.upperbound = [2*pi 1 Inf]; % Upper bounds for the parameters
	model.movestd = [0.01, 0.02, 0.1];
	model.pdf = @(data, mu, g, K) ((1-g).*vonmisespdf(data,mu,K) + (g).*unifpdf(data,-pi,pi));
	model.start = [0.01, .2, 10;  % g, K
                   0.00, .4, 15;  % g, K
                  -0.03, .1, 20]; % g, K