% NOGUESSINGMODEL returns a structure for a single component model. 
% This is the same as StandardMixtureModel, but without a guess state. 
% The probability distribution is a uniform distribution of error. 

function model = NoGuessingModel()
    model.name = 'No guessing model';
	model.paramNames = {'K'};
	model.lowerbound = [0]; % Lower bounds for the parameters
	model.upperbound = [Inf]; % Upper bounds for the parameters
	model.movestd = [0.1];
	model.pdf = @(data, K) (vonmisespdf(data.errors(:),0,K));
	model.start = [10;  % K
                   15;  % K
                   20]; % K
end
