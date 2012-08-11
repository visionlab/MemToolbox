% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model

function model = StandardMixtureModel_Kappa()
  model.name = 'Standard mixture model (kappa)';
	model.paramNames = {'g', 'K'};
	model.lowerbound = [0 0]; % Lower bounds for the parameters
	model.upperbound = [1 Inf]; % Upper bounds for the parameters
	model.movestd = [0.02, 0.1];
	model.pdf = @(data, g, K) ((1-g).*vonmisespdf(data.errors(:),0,K) + ...
	                             (g).*unifpdf(data.errors(:),-180,180));
                             
	model.start = [.2, 10;  % g, K
                 .4, 15;  % g, K
                 .1, 20]; % g, K
                 
  model.prior = @(p) JeffreysPriorForKappaOfVonMises(p(2));  % K
  
  % Example of a possible .priorForMC:
  % model.priorForMC = @(p) (betapdf(p(1),1.25,2.5) * ... % for g ...
  %                          lognpdf(p(2),2,0.5));        % for K
        
  model.generator = @StandardMixtureModelGenerator;
end
  
% Achieves a 15x speedup over the default sampler
function r = StandardMixtureModelGenerator(parameters, dims, displayInfo)
  n = prod(dims); % figure out how many numbers to cook
  r = rand(n,1)*360 - 180; % fill array with blind guesses
  guesses = logical(rand(n,1) < parameters{1}); % figure out which ones will be guesses
  r(~guesses) = vonmisesrnd(0, parameters{2}, [sum(~guesses),1]); % pick rnds
  r = reshape(r, dims); % reshape to requested dimensions
end

  
  
  
  
  
  