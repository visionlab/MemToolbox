% SLOTSPLUSRESOURCESMODEL returns a structure for the slots+resources model of
% Zhang & Luck (2008), though it assumes even allocation of the resource to
% whichever objects are assigned a slot. The model has two parameters: capacity,
% which is the number of available slots, and bestSD, which is the standard
% deviation of memory for an item when all of the resource is thrown at it.
% model with capacity K and precision sd.
%
% In addition to data.errors, this requires data.n (the set size for each
% trial). The model is not particularly well-formed unless you have tested
% multiple set sizes; with only a single set size you may be better off
% with a model that does not make predictions across set size, like
% StandardMixtureModel().
%
% Uses the capacity and bestSD to fit data across multiple sizes.
%
% A prior probability distribution can be specified in model.prior. Example
% priors are available in MemModels/Priors.
%
function model = SlotsPlusResourcesModel()
  model.name = 'Slot plus resouces model';
	model.paramNames = {'capacity', 'bestSD'};
	model.lowerbound = [0 0]; % Lower bounds for the parameters
	model.upperbound = [Inf Inf]; % Upper bounds for the parameters
	model.movestd = [0.1, 0.1];
	model.pdf = @slotpdf;
	model.start = [2, 20;  % g, sd
                   3, 60;  % g, sd
                   4, 5]; % g, sd

  % To specify a prior probability distribution, change and uncomment
  % the following line, where p is a vector of parameter values, arranged
  % in the same order that they appear in model.paramNames:
  % model.prior = @(p) (1);
end

function y = slotpdf(data,capacity,bestSD)

  numRepresented = min(capacity, data.n(:));
  g = 1 - numRepresented ./ data.n(:);
  sd = bestSD .* sqrt(numRepresented(:));

  y = (1-g).*vonmisespdf(data.errors(:),0,deg2k(sd(:))) + ...
        (g).*unifpdf(data.errors(:),-180,180);
end
