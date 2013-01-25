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
                     
  % Example of a possible .priorForMC:
  % model.priorForMC = @(p) (lognpdf(deg2k(p(1)),2,0.5));
end
