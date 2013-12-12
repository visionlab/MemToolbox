%SLOTMODEL returns a structure for a two-component mixture model
% capacity K and precision sd. Capacity is the maximum number of independent
% representations. If the set size is greater than capacity some guesses will
% occur. For example, if participants can store 3 items but have to remember 6,
% participants will guess 50% of the time. Precision is the uncertainty of
% stored representations, and is assumed to be constant across set size.
%
% In addition to data.errors, requires data.n (the set size for each trial)
%
% A prior probability distribution can be specified in model.prior. Example
% priors are available in MemModels/Priors.
%
function model = SlotModel()
  model.name = 'Slot model';
	model.paramNames = {'capacity', 'sd'};
	model.lowerbound = [0 0];     % Lower bounds for the parameters
	model.upperbound = [Inf Inf]; % Upper bounds for the parameters
	model.movestd = [0.25, 0.1];
	model.pdf = @slotpdf;
	model.start = [1, 4;   % capacity, sd
                 4, 15;  % capacity, sd
                 6, 40]; % capacity, sd

  % To specify a prior probability distribution, change and uncomment
  % the following line, where p is a vector of parameter values, arranged
  % in the same order that they appear in model.paramNames:
  % model.prior = @(p) (1);
end

function y = slotpdf(data,capacity,sd)
  g = (1 - max(0,min(1,capacity./data.n(:))));

  y = (1-g).*vonmisespdf(data.errors(:),0,deg2k(sd)) + ...
        (g).*unifpdf(data.errors(:),-180,180);

end
