% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model

function model = StandardMixtureModelNoBiasKappa()
  model.name = 'Standard mixture model';
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
                     
  model.priorForMC = @(p) (betapdf(p(1),1.25,2.5) * ... % for g ...
                           lognpdf(p(2),2,0.5));        % for K
        
  model.generator = @StandardMixtureModelGenerator;
end

% achieves a 15x speedup over the default rejection sampler
% calls the standardmixturemodel generator with mu=0
function r = StandardMixtureModelGenerator(parameters, dims)
    model = StandardMixtureModel('Bias',true);
    r = model.generator({0, parameters{1}, parameters{2}}, dims);
end
  
  
  
  
  
  
  