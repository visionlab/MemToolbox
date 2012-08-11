% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model
% with guess rate g and standard deviation sd.

function model = StandardMixtureModelNoBiasSD()
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
                      
  model.priorForMC = @(p) (betapdf(p(1),1.25,2.5) * ... % for g
                           lognpdf(deg2k(p(2)),2,0.5)); % for sd

end

% achieves a 15x speedup over the default rejection sampler
% calls the standardmixturemodel generator with mu=0
function r = StandardMixtureModelGenerator(parameters, dims, displayInfo)
    model = StandardMixtureModelWithBiasSD();
    r = model.generator({0, parameters{1}, parameters{2}}, dims);
end