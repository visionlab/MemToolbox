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
  
  model.prior = @(p) JeffreysPriorForKappaOfVonMises(deg2k(p(2))); % SD
            
  % Example of a possible .priorForMC:
  % model.priorForMC = @(p) (betapdf(p(1),1.25,2.5) * ... % for g
  %                         lognpdf(deg2k(p(2)),2,0.5)); % for sd

end

% Achieves a 15x speedup over the default sampler
function r = StandardMixtureModelGenerator(parameters, dims, displayInfo)
  n = prod(dims); % figure out how many numbers to cook
  r = rand(n,1)*360 - 180; % fill array with blind guesses
  guesses = logical(rand(n,1) < parameters{1}); % figure out which ones will be guesses
  r(~guesses) = vonmisesrnd(0, deg2k(parameters{2}), [sum(~guesses),1]); % pick rnds
  r = reshape(r, dims); % reshape to requested dimensions
end
