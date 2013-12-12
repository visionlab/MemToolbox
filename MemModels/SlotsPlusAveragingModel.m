% SLOTPLUSAVERAGINGMODEL returns a structure for the slots+averaging model of
% Zhang & Luck (2008). The model has two parameters: capacity, which is
% the number of available slots, and SD, which is the standard deviation
% of memory for an item that gets one slot.
%
% In addition to data.errors, requires data.n (the set size for each
% trial). The model is not particularly well-formed unless you have tested
% multiple set sizes; with only a single set size you may be better off
% with a model that does not make predictions across set size, like
% StandardMixtureModel().
%
% Uses the capacity and SD to fit data across multiple sizes.
%
% A prior probability distribution can be specified in model.prior. Example
% priors are available in MemModels/Priors.
%
function model = SlotsPlusAveragingModel()
  model.name = 'Slots+averaging model';
	model.paramNames = {'capacity', 'sd'};
	model.lowerbound = [1 0];     % Lower bounds for the parameters
	model.upperbound = [Inf Inf]; % Upper bounds for the parameters
	model.movestd = [0.1, 0.1];
	model.pdf = @slotpdf;
	model.start = [2, 5;    % capacity, sd
                 3, 10;
                 4, 100];

  % To specify a prior probability distribution, change and uncomment
  % the following line, where p is a vector of parameter values, arranged
  % in the same order that they appear in model.paramNames:
  % model.prior = @(p) (1);
end

function y = slotpdf(data,capacity,sd)

  % First compute the number of items that get at least one slot
  numRepresented = min(capacity, data.n(:));

  % ... which we can use to compute the guess rate
  g = 1 - numRepresented ./ data.n(:);

  % Then pass around the slots evenly and compute the sd
  slotsPerItemEvenly = floor(capacity ./ data.n(:));
  worseSD = sd ./ max(sqrt(slotsPerItemEvenly),1); % to avoid Infs

  % Count the items that get an extra slot and the resulting sd
  numItemsWithExtraSlot = mod(capacity, data.n(:));
  pExtraSlot = numItemsWithExtraSlot ./ numRepresented;
  betterSD = sd ./ sqrt(slotsPerItemEvenly+1);

  % Finally, compute probability
  y =  (g(:)).*(1/360) + ...
     (1-g(:)).*(pExtraSlot(:)) .* vonmisespdf(data.errors(:),0,deg2k(betterSD(:))) + ...
     (1-g(:)).*(1-pExtraSlot(:)).*vonmisespdf(data.errors(:),0,deg2k(worseSD(:)));
end
