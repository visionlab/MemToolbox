% ALLGUESSINGMODEL returns a structure for a single-component model (a uniform 
% distribution). This is like StandardMixtureModel, but without a 
% remembered state.
function model = AllGuessingModel()
  model.name = 'All guessing model';
	model.paramNames = {'g'};
	model.lowerbound = 1; % Lower bounds for the parameters
	model.upperbound = 1; % Upper bounds for the parameters
	model.movestd = 0.00;
	model.pdf = @(data, g) (g)*unifpdf(data.errors(:),-180,180);
	model.start = [1;  % g
                 1;  % g
                 1]; % g
  
  model.generator = @(parameters,dims) (unifrnd(-180,180,dims));
end
