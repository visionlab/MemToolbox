% ALLGUESSINGMODEL returns a structure for a single component model. This is the same
% as StandardMixtureModel, but without a remembered state.

function model = AllGuessingModel()
  model.name = 'All guessing model';
	model.paramNames = {'g'};
	model.lowerbound = [1]; % Lower bounds for the parameters
	model.upperbound = [1]; % Upper bounds for the parameters
	model.movestd = [0.00];
	model.pdf = @(data, g) (g)*unifpdf(data.errors(:),-180,180);
	model.start = [1;  % K
                 1;  % K
                 1]; % K
  
  model.generator = @(parameters,dims) (unifrnd(-180,180,dims));
end
