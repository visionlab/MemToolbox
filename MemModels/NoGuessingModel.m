% NOGUESSINGMODEL returns a structure for a single component model.
% This is the same as StandardMixtureModel, but without a guess state.
% The probability distribution is a uniform distribution of error.
%
function model = NoGuessingModel()
  model.name = 'No guessing model';
	model.paramNames = {'sd'};
	model.lowerbound = 0; % Lower bounds for the parameters
	model.upperbound = Inf; % Upper bounds for the parameters
	model.movestd = 0.5;
	model.pdf = @(data, sd) (vonmisespdf(data.errors(:),0,deg2k(sd)));
	model.start = [ 3;  % sd
                 15;  % sd
                 75]; % sd

  % To specify a prior probability distribution, change and uncomment
  % the following line, where p is a vector of parameter values, arranged
  % in the same order that they appear in model.paramNames:
  % model.prior = @(p) (1);

end
